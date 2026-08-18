-- (CHAR-01) `id` used to be forwarded straight into core's InitiateCharacter
-- with no check -- any client could load any character (dollars/gold/
-- tokens/inventory included) by guessing its id. The ownership gate now
-- lives in feather-core (CharacterAPI.InitiateCharacter re-derives the
-- caller's owned characters from `src` and rejects anything else), so this
-- handler just needs to surface the failure instead of silently continuing
-- as if it had spawned.
RegisterServerEvent('feather-character:InitiateCharacter', function(id)
    local _source = source
    local ok = FeatherCore.Character.InitiateCharacter(_source, id)
    if not ok then
        NotifyClient(_source, "That character could not be loaded.", "error", 5000)
    end
end)

-- (CHAR-03) `id` was trusted at face value -- any client could read any
-- character's appearance data by id (IDOR read). Re-validated against the
-- caller's own owned-character list, same helper feather-core's
-- InitiateCharacter fix (CHAR-01) uses.
-- (CHAR-13) Was a raw TriggerServerEvent/TriggerClientEvent pair with no
-- ack -- the caller (selector.lua) had no way to know when the response
-- actually landed and instead blocked on a fixed Wait(250) per character,
-- reading whatever was in the SentClothing/SentAttributes/SentOverlays
-- globals at that point regardless of whether the fetch had actually
-- finished. Registered as an RPC instead so the client gets a real
-- per-call ack (RPCAPI's existing request/response/timeout machinery),
-- with no protocol change beyond swapping the transport.
FeatherCore.RPC.Register("GetCharactersData", function(params, res, player)
    local id = params.id

    if not FeatherCore.Character.IsCharacterOwnedByUser(player, id) then
        print(("[feather-character] Rejected GetCharactersData: src %s does not own character %s"):format(player, tostring(id)))
        return res(false)
    end

    local charApperanceData = CharControllers.GetCharApperanceData(id)
    if not charApperanceData then
        return res(false)
    end
    return res(true, charApperanceData.clothing, charApperanceData.attributes, charApperanceData.overlays, charApperanceData.clothingtints)
end)

-- (CHAR-02) `charId` was trusted at face value -- any client could write
-- appearance rows for any character. Re-validated the same way. Legitimate
-- callers (creationmenu.lua, right after SaveCharacterData) pass a charId
-- that already belongs to the caller's just-created character, so this
-- doesn't change the intended flow.
RegisterServerEvent('feather-character:UpdateAttributeDB', function(charId, attributes, clothing, overlays, tints)
    local _source = source

    if not FeatherCore.Character.IsCharacterOwnedByUser(_source, charId) then
        print(("[feather-character] Rejected UpdateAttributeDB: src %s does not own character %s"):format(_source, tostring(charId)))
        return
    end

    CharControllers.UpdateCharApperanceData(charId, attributes, clothing, overlays, tints)
end)

-- (CHAR-04) No cap existed here -- a client could call this RPC repeatedly
-- to create unlimited characters past Config.MaxAllowedChars, the limit the
-- character-select UI otherwise only enforces cosmetically (selector.lua
-- caps how many it *displays*, not how many exist). Re-derives the caller's
-- current character count from `src` the same way GetAvailableCharactersFromDB
-- does everywhere else, never trusting a client-supplied count.
-- (spawn-town fix) `townindex` picks which Config.SpawnCoords.towns entry to
-- persist as this character's starting position. Never trust a client-sent
-- town name or raw coordinates -- only ever accept an index and look the
-- real coordinates up server-side, same principle as CORE-05's discussion of
-- indexing into a trusted table rather than accepting the value itself.
-- Previously this always wrote towns[1] (Saint Denis) regardless of what the
-- player picked in the old post-creation SpawnSelect screen, since that
-- screen only ever drove a local cinematic and never told the server what
-- was chosen -- the DB-saved position (which Feather:Character:Spawn later
-- places the player at, authoritatively) never matched the cinematic's
-- destination. Town choice now happens once, here, at creation time.
-- (CHAR-09) `model`/`dob`/`desc`/`img`/`firstname`/`lastname` used to go
-- straight from params[1] to the DB with no whitelist, type check, or
-- length cap. `model` in particular is re-applied on every later character
-- select, so an unvalidated value was a permanent arbitrary-ped-model grant.
-- Rejects the same way the townindex check just above it does: print +
-- res(false), no partial/best-effort save.
local function ValidateCreationFields(fields)
    if type(fields.model) ~= "string" or not Config.Character.allowedModels[fields.model] then
        return false, ("invalid model %s"):format(tostring(fields.model))
    end
    if type(fields.firstname) ~= "string" or #fields.firstname < 1 or #fields.firstname > Config.Character.maxFirstNameLength then
        return false, ("invalid firstname length %s"):format(tostring(fields.firstname and #fields.firstname))
    end
    if type(fields.lastname) ~= "string" or #fields.lastname < 1 or #fields.lastname > Config.Character.maxLastNameLength then
        return false, ("invalid lastname length %s"):format(tostring(fields.lastname and #fields.lastname))
    end
    if type(fields.desc) ~= "string" or #fields.desc > Config.Character.maxDescLength then
        return false, ("invalid desc length %s"):format(tostring(fields.desc and #fields.desc))
    end
    if type(fields.img) ~= "string" or #fields.img > Config.Character.maxImgLength then
        return false, ("invalid img length %s"):format(tostring(fields.img and #fields.img))
    end
    -- "None" is creationmenu.lua's own placeholder for "no image supplied" --
    -- accept it alongside real http(s) URLs rather than forcing every
    -- creation to have one.
    if fields.img ~= "None" and not fields.img:match("^https?://") then
        return false, ("invalid img url %s"):format(fields.img)
    end

    local validDate = fields.dob and fields.dob:match("^%d%d%d%d%-%d%d%-%d%d$")
    if not validDate then
        return false, ("invalid dob format %s"):format(tostring(fields.dob))
    end
    if fields.dob < Config.defaults.dob.min or fields.dob > Config.defaults.dob.max then
        return false, ("dob out of range %s"):format(fields.dob)
    end

    return true
end

-- (TOCTOU) Two concurrent SaveCharacterData calls from the same src (double
-- click, no client debounce) used to interleave across the MySQL.query.await
-- yields below: both could read the same pre-insert existingChars count and
-- both pass the cap check, and both used to re-derive "the character I just
-- created" via a SELECT ... ORDER BY id DESC LIMIT 1 that could just as
-- easily return the *other* call's row (CHAR-07 reborn via genuine
-- concurrency, not just missing ORDER BY). This guard makes a second call
-- for the same src fail closed instead of racing; cleared on every exit path.
local CreationInFlight = {}

FeatherCore.RPC.Register("SaveCharacterData", function(params, res, player)
    local src = player

    if CreationInFlight[src] then
        print(("[feather-character] Rejected SaveCharacterData: src %s already has a creation in flight"):format(src))
        return res(false)
    end
    CreationInFlight[src] = true

    local function reject(reason)
        print(("[feather-character] Rejected SaveCharacterData: src %s %s"):format(src, reason))
        CreationInFlight[src] = nil
        return res(false)
    end

    local existingChars = FeatherCore.Character.GetAvailableCharactersFromDB(src)
    if #existingChars >= Config.MaxAllowedChars then
        return reject(("already has %s/%s characters"):format(#existingChars, Config.MaxAllowedChars))
    end

    local townindex = tonumber(params[1].townindex)
    if not townindex or townindex ~= math.floor(townindex) or townindex < 1 or townindex > #Config.SpawnCoords.towns then
        return reject(("sent invalid townindex %s"):format(tostring(params[1].townindex)))
    end
    local town = Config.SpawnCoords.towns[townindex]

    local validFields, reason = ValidateCreationFields(params[1])
    if not validFields then
        return reject("sent " .. reason)
    end

    local activeuser = FeatherCore.User.GetUserBySrc(src)
    -- charId now comes straight back from the INSERT (MySQL.insert.await's
    -- real insertId, see feather-core's CharacterController.CreateCharacter)
    -- instead of being re-derived with a second, racy SELECT.
    local charId = FeatherCore.Character.CreateCharacter(activeuser.id, 1, params[1].firstname, params[1].lastname, params[1].model, params[1].dob, json.encode(params[1].img), Config.defaults.money, Config.defaults.gold, Config.defaults.tokens, Config.defaults.xp, town.startcoords.x, town.startcoords.y, town.startcoords.z, Config.defaults.lang, params[1].desc)

    CreationInFlight[src] = nil
    return res(charId)
end)

-- A disconnect mid-creation (the INSERT is still in flight) would otherwise
-- leave that src's CreationInFlight entry set forever, permanently locking
-- out any future connection that reuses the same src id.
AddEventHandler('playerDropped', function()
    CreationInFlight[source] = nil
end)

RegisterServerEvent('feather-character:CheckForUsers', function()
    local _source = source
    local allChars = FeatherCore.Character.GetAvailableCharactersFromDB(_source)
    if #allChars > 0 then
        TriggerClientEvent('feather-character:SelectCharacterScreen', _source, allChars)
    else
        TriggerClientEvent('feather-character:CreateNewCharacter', _source)
    end
end)

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
RegisterServerEvent('feather-character:GetCharactersData', function(id)
    local _source = source

    if not FeatherCore.Character.IsCharacterOwnedByUser(_source, id) then
        print(("[feather-character] Rejected GetCharactersData: src %s does not own character %s"):format(_source, tostring(id)))
        return
    end

    local charApperanceData = CharControllers.GetCharApperanceData(id)
    if not charApperanceData then
        return
    end
    TriggerClientEvent('feather-character:SendCharactersData', _source, id, charApperanceData.clothing, charApperanceData.attributes, charApperanceData.overlays)
end)

-- (CHAR-02) `charId` was trusted at face value -- any client could write
-- appearance rows for any character. Re-validated the same way. Legitimate
-- callers (creationmenu.lua, right after SaveCharacterData) pass a charId
-- that already belongs to the caller's just-created character, so this
-- doesn't change the intended flow.
RegisterServerEvent('feather-character:UpdateAttributeDB', function(charId, attributes, clothing, overlays)
    local _source = source

    if not FeatherCore.Character.IsCharacterOwnedByUser(_source, charId) then
        print(("[feather-character] Rejected UpdateAttributeDB: src %s does not own character %s"):format(_source, tostring(charId)))
        return
    end

    CharControllers.UpdateCharApperanceData(charId, attributes, clothing, overlays)
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
FeatherCore.RPC.Register("SaveCharacterData", function(params, res, player)
    local src = player

    local existingChars = FeatherCore.Character.GetAvailableCharactersFromDB(src)
    if #existingChars >= Config.MaxAllowedChars then
        print(("[feather-character] Rejected SaveCharacterData: src %s already has %s/%s characters"):format(src, #existingChars, Config.MaxAllowedChars))
        return res(false)
    end

    local townindex = tonumber(params[1].townindex)
    if not townindex or townindex ~= math.floor(townindex) or townindex < 1 or townindex > #Config.SpawnCoords.towns then
        print(("[feather-character] Rejected SaveCharacterData: src %s sent invalid townindex %s"):format(src, tostring(params[1].townindex)))
        return res(false)
    end
    local town = Config.SpawnCoords.towns[townindex]

    local activeuser = FeatherCore.User.GetUserBySrc(src)
    FeatherCore.Character.CreateCharacter(activeuser.id, 1, params[1].firstname, params[1].lastname, params[1].model, params[1].dob, json.encode(params[1].img), Config.defaults.money, Config.defaults.gold, Config.defaults.tokens, Config.defaults.xp, town.startcoords.x, town.startcoords.y, town.startcoords.z, Config.defaults.lang, params[1].desc)
    local charId = CharControllers.GetCharIdFromUserId(activeuser.id)

    return res(charId)
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

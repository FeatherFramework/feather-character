CharacterContract1 = {}

local lifecycleGeneration = 0

local spawnPointIds = {
    [1] = 'saint_denis',
    [2] = 'rhodes',
    [3] = 'valentine',
    [4] = 'blackwater'
}

local function Call(route, payload)
    local result, transportError = FeatherCore.RPC.CallAsync(route, payload or {})
    if type(result) == 'table' and result.ok ~= nil then return result end
    return {
        ok = false,
        code = transportError and transportError.code or 'transport_error',
        message = transportError and transportError.message or ('No valid response from ' .. route)
    }
end

local function FailureMessage(result)
    return type(result) == 'table' and (result.message or (result.error and result.error.message))
        or 'Character operation failed.'
end

local function ApplyAppearance(document)
    document = type(document) == 'table' and document or {}
    local attributes = type(document.attributes) == 'table' and document.attributes or {}
    local clothing = type(document.clothing) == 'table' and document.clothing or {}
    local overlays = type(document.overlays) == 'table' and document.overlays or {}
    local tints = type(document.tints) == 'table' and document.tints or {}
    local albedo = 0

    for category, attribute in pairs(attributes) do
        if category == 'Albedo' and type(attribute) == 'table' then albedo = attribute.hash or 0 end
        if category ~= 'hairCategory' and category ~= 'hairVariant'
            and category ~= 'beardCategory' and category ~= 'beardVariant'
            and type(attribute) == 'table' and attribute.value ~= nil then
            SetCharExpression(PlayerPedId(), attribute.hash, attribute.value)
        elseif category ~= 'hairCategory' and category ~= 'hairVariant'
            and category ~= 'beardCategory' and category ~= 'beardVariant'
            and type(attribute) == 'table' and attribute.hash then
            AddComponent(PlayerPedId(), attribute.hash, category)
        end
    end
    local hair = attributes.hairVariant or attributes.hairCategory
    if type(hair) == 'table' and hair.hash then AddComponent(PlayerPedId(), hair.hash, 'hair') end
    local beard = attributes.beardVariant or attributes.beardCategory
    if type(beard) == 'table' and beard.hash then AddComponent(PlayerPedId(), beard.hash, 'beard') end
    for category, hash in pairs(clothing) do
        AddComponent(PlayerPedId(), hash, category, tints[category])
    end
    for category, overlay in pairs(overlays) do
        if type(overlay) == 'table' then
            ChangeOverlay(PlayerPedId(), category, 1, overlay.textureId, 0, 0, 0, 1.0, 0, 1,
                overlay.color1, overlay.color2, overlay.color3, overlay.variant, overlay.opacity, albedo)
        end
    end
end

local function NormalizeBirthDate(value)
    if type(value) ~= 'string' then return nil end
    local month, day, year = value:match('^%s*(%d%d)/(%d%d)/(%d%d%d%d)%s*$')
    month, day, year = tonumber(month), tonumber(day), tonumber(year)
    if not month or not day or not year or month < 1 or month > 12 then return nil end
    local days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if year % 400 == 0 or (year % 4 == 0 and year % 100 ~= 0) then days[2] = 29 end
    if day < 1 or day > days[month] then return nil end
    return ('%04d-%02d-%02d'):format(year, month, day)
end

local function SelectorRecord(profile)
    return {
        id = profile.characterId,
        characterId = profile.characterId,
        first_name = profile.firstName,
        last_name = profile.lastName,
        dob = profile.dateOfBirth,
        model = profile.model,
        description = profile.description or '',
        img = json.encode(profile.portraitUrl or 'None'),
        dollars = 0,
        gold = 0,
        exp = 0,
        tokens = 0
    }
end

local function CurrentPosition()
    local coords = GetEntityCoords(PlayerPedId())
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        heading = GetEntityHeading(PlayerPedId())
    }
end

local function StartPositionSync(characterId)
    lifecycleGeneration = lifecycleGeneration + 1
    local generation = lifecycleGeneration
    CreateThread(function()
        while generation == lifecycleGeneration and Characterid == characterId do
            Wait(Config.Contract1.positionSyncMs)
            if generation == lifecycleGeneration and Characterid == characterId then
                local result = Call('character.position.update.v1', { position = CurrentPosition() })
                if not result.ok and result.code ~= 'session_stale' then
                    print(('[feather-character] position sync failed code=%s'):format(tostring(result.code)))
                end
            end
        end
    end)
end

function CharacterContract1.GetAppearance(characterId)
    local result = Call('character.appearance.get.v1', { characterId = characterId })
    if not result.ok then return {}, result end
    return result.value.document or {}, result
end

function CharacterContract1.OpenSelector()
    local result
    for _ = 1, 10 do
        result = Call('character.list.v1', {})
        if result.ok or result.code ~= 'unauthenticated' then break end
        Wait(1000)
    end
    if not result or not result.ok then
        Notify(FailureMessage(result), 'error', 5000)
        return false
    end
    local records = {}
    for index, profile in ipairs(result.value or {}) do
        if type(profile.characterId) ~= 'string' or #profile.characterId ~= 36 then
            Notify('Character selection returned an invalid character identity.', 'error', 5000)
            return false
        end
        records[index] = SelectorRecord(profile)
    end
    if #records == 0 then
        TriggerEvent('feather-character:CreateNewCharacter')
    else
        TriggerEvent('feather-character:SelectCharacterScreen', records)
    end
    return true
end

function CharacterContract1.Activate(profile, arrivalTownIndex)
    local characterId = profile and (profile.characterId or profile.id)
    local result = Call('character.activate.v1', { characterId = characterId })
    if not result.ok then
        Notify(FailureMessage(result), 'error', 5000)
        return false
    end

    local value = result.value
    local publicProfile = value.profile
    local appearance = value.appearance and value.appearance.document or {}
    local spawn = value.spawn and value.spawn.position
    if type(publicProfile) ~= 'table' or type(spawn) ~= 'table' then
        Notify('Character activation returned an invalid spawn plan.', 'error', 5000)
        return false
    end

    Spawned = false
    CreatingCharacter = false
    DoScreenFadeOut(250)
    Wait(300)
    CleanupScript()
    LoadPlayer(publicProfile.model)
    ApplyAppearance(appearance)
    Characterid = publicProfile.characterId
    CharModel = publicProfile.model
    if arrivalTownIndex and CharacterArrival then
        CharacterArrival.Play(arrivalTownIndex, spawn)
    else
        SetEntityCoords(PlayerPedId(), spawn.x, spawn.y, spawn.z, false, false, false, false)
        SetEntityHeading(PlayerPedId(), spawn.heading or 0.0)
    end
    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityVisible(PlayerPedId(), true)
    DisplayRadar(true)

    local completed = Call('character.spawn.complete.v1', {})
    if not completed.ok then
        Call('character.logout.v1', {})
        Notify(FailureMessage(completed), 'error', 5000)
        if not IsScreenFadedIn() then DoScreenFadeIn(500) end
        return false
    end
    if not IsScreenFadedIn() then DoScreenFadeIn(500) end
    TriggerEvent('Feather:Character:Spawned', {
        id = publicProfile.characterId,
        characterId = publicProfile.characterId,
        first_name = publicProfile.firstName,
        last_name = publicProfile.lastName,
        model = publicProfile.model
    })
    StartPositionSync(publicProfile.characterId)
    return true
end

function CharacterContract1.Logout()
    if not Characterid then
        Notify(FeatherCore.Locale.translate(0, 'noActiveCharacter'), 'error', 4000)
        return false
    end
    local loggedOut = Call('character.logout.v1', { position = CurrentPosition() })
    if not loggedOut.ok then
        Notify(FailureMessage(loggedOut), 'error', 5000)
        return false
    end

    lifecycleGeneration = lifecycleGeneration + 1
    local previousCharacterId = Characterid
    Characterid = nil
    CharModel = nil
    TriggerEvent('Feather:Character:Logout', {
        characterId = previousCharacterId,
        reason = 'logout'
    })
    DoScreenFadeOut(250)
    Wait(300)
    CleanupScript()
    local opened = CharacterContract1.OpenSelector()
    if opened then DoScreenFadeIn(500) end
    return opened
end

function CharacterContract1.Create(data, appearance)
    local townIndex = tonumber(data.townindex) or 1
    local dateOfBirth = NormalizeBirthDate(data.dob)
    if not dateOfBirth then
        Notify(FeatherCore.Locale.translate(0, 'validDobRequired'), 'error', 5000)
        return false
    end
    local request = {
        idempotencyKey = ('create:%s:%s'):format(tostring(GetGameTimer()), tostring(math.random(100000, 999999))),
        character = {
            firstName = data.firstname,
            lastName = data.lastname,
            dateOfBirth = dateOfBirth,
            model = data.model,
            description = data.desc,
            portraitUrl = data.img ~= 'None' and data.img or nil,
            spawnPointId = spawnPointIds[townIndex],
            appearance = appearance
        }
    }
    local created = Call('character.create.v1', request)
    if not created.ok then
        Notify(FailureMessage(created), 'error', 5000)
        return false
    end

    CreatingCharacter = false
    local activated = CharacterContract1.Activate({ characterId = created.value.characterId }, townIndex)
    return activated, created.value.characterId
end

function CharacterContract1.Delete(profile, confirmed)
    local characterId = profile and (profile.characterId or profile.id)
    if confirmed ~= true then
        Notify(FeatherCore.Locale.translate(0, 'characterDeleteConfirmationRequired'), 'error', 5000)
        return false
    end
    local deleted = Call('character.delete.v1', {
        characterId = characterId,
        confirmed = true
    })
    if not deleted.ok then
        Notify(FailureMessage(deleted), 'error', 5000)
        return false
    end
    DoScreenFadeOut(250)
    Wait(300)
    CleanupScript()
    local opened = CharacterContract1.OpenSelector()
    if opened then DoScreenFadeIn(500) end
    return opened
end

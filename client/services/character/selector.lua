-- Character-select screen: for every UUID profile returned by Contract 1,
-- spawns a display ped dressed from its versioned appearance document
-- at a fixed camera spot, then lets the player page through them
-- (pagearrows below) and pick one. FetchedClothing/FetchedAttributes/
-- FetchedOverlays/FetchedTints are keyed by UUID character id.
local obj1, obj2, obj3, obj4
clothing, attributes, makeup, tints, spawnedPeds = {}, {}, {}, {}, {}
FetchedClothing, FetchedAttributes, FetchedOverlays, FetchedTints = {}, {}, {}, {}

function CleanupCharacterSelect()
    if obj1 then
        obj1:Remove()
        obj2:Remove()
        obj3:Remove()
        obj4:Remove()
    end
    for k, v in pairs(spawnedPeds) do
        v:Remove()
    end
    spawnedPeds = {}
    obj1, obj2, obj3, obj4 = nil, nil, nil, nil
    CharacterMenu:Close()
end

--------- Net Events ------
-- `data` is the account-scoped list returned by character.list.v1. Spawns
-- the selection-room props, requests
-- each character's saved appearance (SendCharactersData above), then poses
-- a display ped per character (capped to Config.MaxAllowedChars) and opens
-- the paged character-select menu.
RegisterNetEvent('feather-character:SelectCharacterScreen', function(data)
    clothing, attributes, makeup, tints, spawnedPeds = {}, {}, {}, {}, {}
    FetchedClothing, FetchedAttributes, FetchedOverlays, FetchedTints = {}, {}, {}, {}
    -- The client submits only selection intent. Character validates the
    -- connected account and asks feather-routing to join its server-owned,
    -- opaque selection route; no native bucket id crosses this boundary.
    local routingResult = FeatherCore.RPC.CallAsync('character.selection.route.enter.v1', {})
    if type(routingResult) ~= 'table' or routingResult.ok ~= true then
        print(('[feather-character] Character selection routing failed: %s'):format(
            type(routingResult) == 'table' and (routingResult.message or routingResult.code)
                or 'invalid response'))
        return
    end
    -- Spawning Props
    obj1 = CharacterRuntime.Object:Create(Config.SpawnProps.obj1.name, Config.SpawnProps.obj1.x, Config.SpawnProps.obj1.y, Config.SpawnProps.obj1.z, Config.SpawnProps.obj1.h, false)
    obj2 = CharacterRuntime.Object:Create(Config.SpawnProps.obj2.name, Config.SpawnProps.obj2.x, Config.SpawnProps.obj2.y, Config.SpawnProps.obj2.z, Config.SpawnProps.obj2.h, false)
    obj3 = CharacterRuntime.Object:Create(Config.SpawnProps.obj3.name, Config.SpawnProps.obj3.x, Config.SpawnProps.obj3.y, Config.SpawnProps.obj3.z, Config.SpawnProps.obj3.h, false)
    obj4 = CharacterRuntime.Object:Create(Config.SpawnProps.obj4.name, Config.SpawnProps.obj4.x, Config.SpawnProps.obj4.y, Config.SpawnProps.obj4.z, Config.SpawnProps.obj4.h, false)
    -- Preparing To Spawn Player
    SetEntityVisible(PlayerPedId(), false)
    DisplayRadar(false)
    SetEntityCoords(PlayerPedId(), Config.CameraCoords.selection.x, Config.CameraCoords.selection.y, Config.CameraCoords.selection.z)
    StartCam(Config.CameraCoords.selection.x, Config.CameraCoords.selection.y, Config.CameraCoords.selection.z, Config.CameraCoords.selection.h, Config.CameraCoords.selection.zoom)
    for k, v in pairs(data) do
        -- (CHAR-13) Blocks this coroutine on a real ack instead of a fixed
        -- Wait -- a slow fetch no longer risks reading not-yet-arrived
        -- appearance data, and a fast one no longer wastes load-screen time.
        -- A failed/timed-out fetch (RPCAPI's own 10s timeout, see
        -- Config.RPCRateLimit.timeoutMs) is logged and that character is
        -- spawned with no appearance applied below, rather than hanging the
        -- whole select screen on one bad fetch.
        local document, appearanceResult = CharacterContract1.GetAppearance(v.id)
        if appearanceResult.ok then
            FetchedClothing[v.id] = document.clothing or {}
            FetchedAttributes[v.id] = document.attributes or {}
            FetchedOverlays[v.id] = document.overlays or {}
            FetchedTints[v.id] = document.tints or {}
        else
            print(("[feather-character] Failed to fetch Contract 1 appearance for %s code=%s"):format(
                tostring(v.id), tostring(appearanceResult.code)))
        end
        FetchedClothing[v.id] = FetchedClothing[v.id] or {}
        FetchedAttributes[v.id] = FetchedAttributes[v.id] or {}
        FetchedOverlays[v.id] = FetchedOverlays[v.id] or {}
        FetchedTints[v.id] = FetchedTints[v.id] or {}
    end
    -- Spawning The players chars
    Spawned = true
    Maxchars = Config.MaxAllowedChars --Can only be an int value
    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.charspots[1].x, Config.SpawnCoords.charspots[1].y, Config.SpawnCoords.charspots[1].z, true, false, false, false)
    SetFocusEntity(PlayerPedId())
    for k, v in pairs(data) do
        if k > Maxchars then break end
        clothing[k] = FetchedClothing[v.id]
        attributes[k] = FetchedAttributes[v.id]
        makeup[k] = FetchedOverlays[v.id]
        tints[k] = FetchedTints[v.id] or {}
        CharModel = v.model
        CharAmount = k
        local ped = CharacterRuntime.Ped:Create(v.model, Config.SpawnCoords.charspots[k].x,
            Config.SpawnCoords.charspots[k].y, Config.SpawnCoords.charspots[k].z, 0)
        local RawPed = ped:GetPed()

        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, RawPed, 4, 0) -- outfits
        if v.model == 'mp_male' then
            DefaultPedSetup(RawPed, true)
        else
            DefaultPedSetup(RawPed, false)
        end
        ped:SetHeading(90.0)
        ped:Freeze(true)
        table.insert(spawnedPeds, ped)
        if clothing[k] ~= nil then
            for category, hash in pairs(clothing[k]) do
                AddComponent(RawPed, hash, category, tints[k][category])
            end
        end
        local previewAlbedo = 0
        if attributes[k] ~= nil then
            for category, attribute in pairs(attributes[k]) do
                if category == 'Albedo' then
                    previewAlbedo = attribute.hash or 0
                end
                if category ~= 'hairCategory' and category ~= 'hairVariant'
                    and category ~= 'beardCategory' and category ~= 'beardVariant'
                    and type(attribute) == 'table' and attribute.value ~= nil then
                    SetCharExpression(RawPed, attribute.hash, attribute.value)
                elseif category ~= 'hairCategory' and category ~= 'hairVariant'
                    and category ~= 'beardCategory' and category ~= 'beardVariant'
                    and type(attribute) == 'table' and attribute.hash then
                    AddComponent(RawPed, attribute.hash, category)
                end
            end
            local hair = attributes[k].hairVariant or attributes[k].hairCategory
            if type(hair) == 'table' and hair.hash then AddComponent(RawPed, hair.hash, 'hair') end
            local beard = attributes[k].beardVariant or attributes[k].beardCategory
            if type(beard) == 'table' and beard.hash then AddComponent(RawPed, beard.hash, 'beard') end
        end
        for category, overlay in pairs(makeup[k] or {}) do
            if type(overlay) == 'table' then
                ChangeOverlay(RawPed, category, 1, overlay.textureId, 0, 0, 0, 1.0, 0, 1,
                    overlay.color1, overlay.color2, overlay.color3, overlay.variant,
                    overlay.opacity, previewAlbedo)
            end
        end
    end
    TriggerEvent('feather-character:CharacterSelectMenu', data, 1, CharAmount, clothing, attributes, makeup, tints)
    SwitchCam(Config.CameraCoords.charcamera[1].x, Config.CameraCoords.charcamera[1].y, Config.CameraCoords.charcamera[1].z, Config.CameraCoords.charcamera[1].h, Config.CameraCoords.charcamera[1].zoom)
    while Spawned do
        Wait(5)
        SetEntityVisible(PlayerPedId(), false)
        FreezeEntityPosition(PlayerPedId(), true)
    end
end)

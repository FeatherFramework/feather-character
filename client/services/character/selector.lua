-- Character-select screen: for every character the server says this user
-- owns, spawns a display ped dressed in that character's saved appearance
-- at a fixed camera spot, then lets the player page through them
-- (pagearrows below) and pick one. FetchedClothing/FetchedAttributes/
-- FetchedOverlays/FetchedTints are keyed by character id and filled in by
-- the GetCharactersData RPC call in SelectCharacterScreen below (CHAR-13 --
-- a real per-call ack, not a fixed Wait).
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
    CharacterMenu:Close()
end

--------- Net Events ------
-- `data` is the server-verified list of characters this user owns (see
-- feather-character:CheckForUsers -> FeatherCore.Character.
-- GetAvailableCharactersFromDB). Spawns the selection-room props, requests
-- each character's saved appearance (SendCharactersData above), then poses
-- a display ped per character (capped to Config.MaxAllowedChars) and opens
-- the paged character-select menu.
RegisterNetEvent('feather-character:SelectCharacterScreen', function(data)
    -- (CHAR-05) Instance 123 is now allow-listed server-side
    -- (feather-core Config.PublicInstanceIds) specifically for this shared
    -- character-select room -- requesting any other id here would no
    -- longer be honored, closing the "any client can join any bucket by
    -- number" hole this hardcoded id used to ride on (CORE-03).
    FeatherCore.RPC.CallAsync("CreateInstance", { id = 123 })
    -- Spawning Props
    obj1 = FeatherCore.Object:Create(Config.SpawnProps.obj1.name, Config.SpawnProps.obj1.x, Config.SpawnProps.obj1.y, Config.SpawnProps.obj1.z, Config.SpawnProps.obj1.h, false, 'standard')
    obj2 = FeatherCore.Object:Create(Config.SpawnProps.obj2.name, Config.SpawnProps.obj2.x, Config.SpawnProps.obj2.y, Config.SpawnProps.obj2.z, Config.SpawnProps.obj2.h, false, 'standard')
    obj3 = FeatherCore.Object:Create(Config.SpawnProps.obj3.name, Config.SpawnProps.obj3.x, Config.SpawnProps.obj3.y, Config.SpawnProps.obj3.z, Config.SpawnProps.obj3.h, false, 'standard')
    obj4 = FeatherCore.Object:Create(Config.SpawnProps.obj4.name, Config.SpawnProps.obj4.x, Config.SpawnProps.obj4.y, Config.SpawnProps.obj4.z, Config.SpawnProps.obj4.h, false, 'standard')
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
        local ok, recClothing, recAttributes, recMakeup, recTints = FeatherCore.RPC.CallAsync("GetCharactersData", { id = v.id })
        if ok then
            FetchedClothing[v.id] = json.decode(recClothing)
            FetchedAttributes[v.id] = json.decode(recAttributes)
            FetchedOverlays[v.id] = json.decode(recMakeup)
            FetchedTints[v.id] = json.decode(recTints or '{}')
        else
            print(("[feather-character] Failed to fetch appearance for character %s"):format(v.id))
        end
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
        local ped = FeatherCore.Ped:Create(v.model, Config.SpawnCoords.charspots[k].x, Config.SpawnCoords.charspots[k].y, Config.SpawnCoords.charspots[k].z, 0, 'world', false, false)
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
        if attributes[k] ~= nil then
            for category, attribute in pairs(attributes[k]) do
                if category == 'Albedo' then
                    AlbedoHash = attribute.hash
                end
                if attribute.value then
                    SetCharExpression(RawPed, attribute.hash, attribute.value)
                else
                    AddComponent(RawPed, attribute.hash, category)
                end
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
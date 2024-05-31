local obj1, obj2, obj3, obj4
local clothing, attributes, makeup, spawnedPeds = {}, {}, {}, {}
SentClothing, SentAttributes, SentOverlays = {}, {}, {}
RegisterNetEvent('feather-character:SendCharactersData', function(id, recClothing, recAttributes, recMakeup)
    SentClothing[id] = json.decode(recClothing)
    SentAttributes[id] = json.decode(recAttributes)
    SentOverlays[id] = json.decode(recMakeup)
end)

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
    MyMenu:Close()
    MyMenu:Close()
end

--------- Net Events ------
RegisterNetEvent('feather-character:SelectCharacterScreen', function(data)
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
        TriggerServerEvent('feather-character:GetCharactersData', v.id)
        Wait(250)
    end
    -- Spawning The players chars
    Spawned = true
    Maxchars = Config.MaxAllowedChars --Can only be an int value
    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.charspots[1].x, Config.SpawnCoords.charspots[1].y, Config.SpawnCoords.charspots[1].z, true, false, false, false)
    SetFocusEntity(PlayerPedId())
    for k, v in pairs(data) do
        if k > Maxchars then break end
        clothing[k] = SentClothing[v.id]
        attributes[k] = SentAttributes[v.id]
        makeup[k] = SentOverlays[v.id]
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
                AddComponent(RawPed, hash, category)
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
    TriggerEvent('feather-character:CharacterSelectMenu', data, 1, CharAmount, clothing, attributes, makeup)
    SwitchCam(Config.CameraCoords.charcamera[1].x, Config.CameraCoords.charcamera[1].y, Config.CameraCoords.charcamera[1].z, Config.CameraCoords.charcamera[1].h, Config.CameraCoords.charcamera[1].zoom)
    while Spawned do
        Wait(5)
        SetEntityVisible(PlayerPedId(), false)
        FreezeEntityPosition(PlayerPedId(), true)
    end
end)
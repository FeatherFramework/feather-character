local Obj1, Obj2, Obj3, Obj4
SentClothing, SentAttributes, SentOverlays = {}, {}, {}
local spawnedPeds = {}
RegisterNetEvent('feather-character:SendCharactersData', function(id, clothing, attributes, makeup)
    SentClothing[id] = json.decode(clothing)
    SentAttributes[id] = json.decode(attributes)
    SentOverlays[id] = json.decode(makeup)
end)

function CleanupCharacterSelect()
    if Obj1 then
        Obj1:Remove()
        Obj2:Remove()
        Obj3:Remove()
        Obj4:Remove()
    end

    for k, v in pairs(spawnedPeds) do
        v:Remove()
    end

    spawnedPeds = {}
    MyMenu:Close({})
    CharInfoMenu:Close({})
end

function SpawnProps()
    Obj1 = FeatherCore.Object:Create(Config.SpawnProps.obj1.name, Config.SpawnProps.obj1.x, Config.SpawnProps.obj1.y,
        Config.SpawnProps.obj1.z, Config.SpawnProps.obj1.h, false, 'standard')
    Obj2 = FeatherCore.Object:Create(Config.SpawnProps.obj2.name, Config.SpawnProps.obj2.x, Config.SpawnProps.obj2.y,
        Config.SpawnProps.obj2.z, Config.SpawnProps.obj2.h, false, 'standard')
    Obj3 = FeatherCore.Object:Create(Config.SpawnProps.obj3.name, Config.SpawnProps.obj3.x, Config.SpawnProps.obj3.y,
        Config.SpawnProps.obj3.z, Config.SpawnProps.obj3.h, false, 'standard')
    Obj4 = FeatherCore.Object:Create(Config.SpawnProps.obj4.name, Config.SpawnProps.obj4.x, Config.SpawnProps.obj4.y,
        Config.SpawnProps.obj4.z, Config.SpawnProps.obj4.h, false, 'standard')
end

RegisterCommand('getdata', function(source)
    TriggerServerEvent('feather-character:GetCharactersData', PlayerId())
end)
local Clothing, Attributes, Makeup = {}, {}, {}

RegisterCommand('testspawn', function(source)
    local ped = FeatherCore.Ped:Create('mp_male', Config.SpawnCoords.charspots[1].x,
    Config.SpawnCoords.charspots[1].y,
    Config.SpawnCoords.charspots[1].z, 0, 'world', false, false)
    local RawPed = ped:GetPed()

    Citizen.InvokeNative(0x77FF8D35EEC6BBC4, RawPed, 4, 0) -- outfits
    DefaultPedSetup(RawPed, true)

    ChangeOverlay(RawPed, 'lipsticks', 1, 1, 0, 0, 0, 1.0, 0, 1, 1, 1, 1, 1, 1.0,
    (SelectedAttributeElements['Albedo'].hash))
end)



function SpawnCharacters(data)
    Spawned = true
    Maxchars = Config.MaxAllowedChars --Can only be an int value
    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.charspots[1].x,
        Config.SpawnCoords.charspots[1].y, Config.SpawnCoords.charspots[1].z, true, false, false, false)
    SetFocusEntity(PlayerPedId())
    for k, v in pairs(data) do
        if k > Maxchars then -- Have this first its more optimal, only run the code below if not maxchars
            break
        end

        Clothing[k] = SentClothing[v.id]
        Attributes[k] = SentAttributes[v.id]
        Makeup[k] = SentOverlays[v.id]
        CharModel = v.model
        CharAmount = k
        -- Creates a new ped
        local ped = FeatherCore.Ped:Create(v.model, Config.SpawnCoords.charspots[k].x,
            Config.SpawnCoords.charspots[k].y,
            Config.SpawnCoords.charspots[k].z, 0, 'world', false, false)
        --Get the rawpedid of the ped that was JUST created
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
        if Clothing[k] ~= nil then
            for category, hash in pairs(Clothing[k]) do
                AddComponent(RawPed, hash, category)
            end
        end
        if Attributes[k] ~= nil then
            for category, attribute in pairs(Attributes[k]) do
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
    TriggerEvent('feather-character:CharacterSelectMenu', data, 1, CharAmount, Clothing, Attributes,Makeup)
    SwitchCam(Config.CameraCoords.charcamera[1].x, Config.CameraCoords.charcamera[1].y,
        Config.CameraCoords.charcamera[1].z, Config.CameraCoords.charcamera[1].h,
        Config.CameraCoords.charcamera[1].zoom)
    while Spawned do
        Wait(0)
        SetEntityVisible(PlayerPedId(), false)
        FreezeEntityPosition(PlayerPedId(), true)
    end
end

--------- Net Events ------

RegisterNetEvent('feather-character:SelectCharacterScreen', function(data)
    FeatherCore.RPC.CallAsync("CreateInstance", { id = 123 })
    SpawnProps()
    SetEntityVisible(PlayerPedId(), false)
    DisplayRadar(false)
    SetEntityCoords(PlayerPedId(), Config.CameraCoords.selection.x, Config.CameraCoords.selection.y,
        Config.CameraCoords.selection.z)
    StartCam(Config.CameraCoords.selection.x, Config.CameraCoords.selection.y, Config.CameraCoords.selection.z,
        Config.CameraCoords.selection.h, Config.CameraCoords.selection.zoom)
    for k, v in pairs(data) do
        TriggerServerEvent('feather-character:GetCharactersData', v.id)
        Wait(250)
    end
    SpawnCharacters(data)
end)

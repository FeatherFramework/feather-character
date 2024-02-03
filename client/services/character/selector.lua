local Obj1, Obj2, Obj3, Obj4, ped
local firstprompt, secondprompt, thirdprompt
CharModel = nil


local spawnedPeds= {}
RegisterNetEvent('feather-character:SendCharactersData', function(clothing, attributes)
    SentClothing = json.decode(clothing)
    SentAttributes = json.decode(attributes)
    CleanupScript()
    LoadPlayer(CharModel)
    for category, hash in pairs(SentClothing) do
        AddComponent(PlayerPedId(), hash, category)
    end
    for category, hash in pairs(SentAttributes) do
        AddComponent(PlayerPedId(), hash, category)
    end
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

RegisterCommand('spawnped', function()
    local coords = GetEntityCoords(PlayerPedId())
    local ped = FeatherCore.Ped:Create('mp_male', coords.x, coords.y, coords.z, 0, 'world', false, false)
    local rawped = ped:GetPed()
    TriggerServerEvent('feather-character:GetCharactersData', rawped) 
    Citizen.InvokeNative(0x77FF8D35EEC6BBC4, rawped, 4, 1)            -- outfits
    DefaultPedSetup(rawped, true)
end)


function SpawnCharacters(data)
    Spawned = true
    local PromptGroup = FeatherCore.Prompt:SetupPromptGroup()                           --Setup Prompt Group
    local Clothing,Attributes,CharacterInfo = {},{},{}

    firstprompt = PromptGroup:RegisterPrompt("Left", 0x20190AB4, 1, 1, true, 'click')   --Register your first prompt
    secondprompt = PromptGroup:RegisterPrompt("Right", 0xC97792B7, 1, 1, true, 'click') --Register your first prompt
    thirdprompt = PromptGroup:RegisterPrompt("Enter", 0xC7B5340A, 1, 1, true, 'click')  --Register your first prompt

    local cameraspot = nil
    local charCamera = {}

    Maxchars = Config.MaxAllowedChars --Can only be an int value

    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.charspots[1].x,
        Config.SpawnCoords.charspots[1].y, Config.SpawnCoords.charspots[1].z, true, false, false, false)
    SetFocusEntity(PlayerPedId())


    for k, v in pairs(data) do
        if k > Maxchars then -- Have this first its more optimal, only run the code below if not maxchars
            break
        end
        charCamera[k] = v.id
        Clothing[k] = json.decode(v.clothing)
        Attributes[k] = json.decode(v.attributes)

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
            for category, hash in pairs(Attributes[k]) do
                AddComponent(RawPed, hash, category)
            end
        end
    end
    TriggerEvent('feather-character:CharacterSelectMenu', data,1,CharAmount,Clothing,Attributes)
    SwitchCam(Config.CameraCoords.charcamera[1].x, Config.CameraCoords.charcamera[1].y,
    Config.CameraCoords.charcamera[1].z, Config.CameraCoords.charcamera[1].h,
    Config.CameraCoords.charcamera[1].zoom)
    while Spawned do
        SetEntityVisible(PlayerPedId(), false)
        FreezeEntityPosition(PlayerPedId(), true)

        Wait(5)

        if cameraspot == nil then
            thirdprompt:TogglePrompt(false)
        elseif cameraspot > 0 then
            thirdprompt:TogglePrompt(true)
        end
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
    SpawnCharacters(data)
end)

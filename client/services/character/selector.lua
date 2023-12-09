local Obj1, Obj2, Obj3, Obj4, ped
local firstprompt, secondprompt, thirdprompt
local spawnedPeds = {}
local Clothing = {}
RegisterNetEvent('feather-character:SendCharactersData', function(clothing)
    SentClothing = json.decode(clothing)
end)

function CleanupCharacterSelect()
    Obj1:Remove()
    Obj2:Remove()
    Obj3:Remove()
    Obj4:Remove()
    for k, v in pairs(spawnedPeds) do
        v:Remove()
    end

    spawnedPeds = {}

    firstprompt:DeletePrompt()
    secondprompt:DeletePrompt()
    thirdprompt:DeletePrompt()
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
    TriggerServerEvent('feather-character:GetCharactersData', rawped) --trigger twice seems to put clothes on or else its weird
    Citizen.InvokeNative(0x77FF8D35EEC6BBC4, rawped, 4, 1)            -- outfits
    DefaultPedSetup(rawped, true)
end)


function SpawnCharacters(data)
    local spawned = true
    local PromptGroup = FeatherCore.Prompt:SetupPromptGroup()                           --Setup Prompt Group

    firstprompt = PromptGroup:RegisterPrompt("Left", 0x20190AB4, 1, 1, true, 'click')   --Register your first prompt
    secondprompt = PromptGroup:RegisterPrompt("Right", 0xC97792B7, 1, 1, true, 'click') --Register your first prompt
    thirdprompt = PromptGroup:RegisterPrompt("Enter", 0xC7B5340A, 1, 1, true, 'click')  --Register your first prompt

    local cameraspot = nil
    local charCamera = {}

    Maxchars = Config.MaxAllowedChars --Can only be an int value
    local repeatKey = 0

    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.charspots[1].x,
        Config.SpawnCoords.charspots[1].y, Config.SpawnCoords.charspots[1].z, true, false, false, false)
    SetFocusEntity(PlayerPedId())


    for k, v in pairs(data) do
        if k > Maxchars then -- Have this first its more optimal, only run the code below if not maxchars
            break
        end
    
        charCamera[k] = v.id
        Clothing[k] = json.decode(v.clothing)
    
        -- Creates a new ped
        local ped = FeatherCore.Ped:Create(v.model, Config.SpawnCoords.charspots[k].x,
            Config.SpawnCoords.charspots[k].y,
            Config.SpawnCoords.charspots[k].z, 0, 'world', false, false)
        --Get the rawpedid of the ped that was JUST created
        local RawPed = ped:GetPed()
    
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, RawPed, 4, 0) -- outfits
        DefaultPedSetup(RawPed, true)
        ped:SetHeading(90.0)
        ped:Freeze(true)
        table.insert(spawnedPeds, ped)
        for category, hash in pairs(Clothing[k]) do
            AddComponent(RawPed,hash,category)
        
        end
    end


    while spawned do
        SetEntityVisible(PlayerPedId(), false)
        FreezeEntityPosition(PlayerPedId(), true)

        Wait(5)
        PromptGroup:ShowGroup("Camera Controls")
        if firstprompt:HasCompleted() then
            if cameraspot == nil then
                cameraspot = 1
            elseif cameraspot <= Maxchars then
                cameraspot = cameraspot - 1
            end
            if cameraspot == 0 then
                cameraspot = Maxchars
            end
            Wait(250)
            SwitchCam(Config.CameraCoords.charcamera[cameraspot].x, Config.CameraCoords.charcamera[cameraspot].y,
                Config.CameraCoords.charcamera[cameraspot].z, Config.CameraCoords.charcamera[cameraspot].h,
                Config.CameraCoords.charcamera[cameraspot].zoom)
        end

        if secondprompt:HasCompleted() then
            if cameraspot == nil then
                cameraspot = Maxchars
            elseif cameraspot <= Maxchars then
                cameraspot = cameraspot + 1
            end
            if cameraspot > Maxchars then
                cameraspot = 1
            end
            SwitchCam(Config.CameraCoords.charcamera[cameraspot].x, Config.CameraCoords.charcamera[cameraspot].y,
                Config.CameraCoords.charcamera[cameraspot].z, Config.CameraCoords.charcamera[cameraspot].h,
                Config.CameraCoords.charcamera[cameraspot].zoom)
        end

        if thirdprompt:HasCompleted() then
            if cameraspot ~= nil then
                spawned = false
                CleanupScript()
                LoadPlayer()
                TriggerServerEvent('feather-character:InitiateCharacter', charCamera[cameraspot])
                TriggerServerEvent('feather-character:GetCharactersData',charCamera[cameraspot])
                for category, hash in pairs(Clothing[cameraspot]) do
                    AddComponent(PlayerPedId(),hash,category)
                end
                break
            end
        end

        if cameraspot == nil then
            thirdprompt:TogglePrompt(false)
        elseif cameraspot > 0 then
            thirdprompt:TogglePrompt(true)
        end
    end
end

--------- Net Events ------

RegisterNetEvent('feather-character:SelectCharacterScreen', function(data)
    SpawnProps()
    SetEntityVisible(PlayerPedId(), false)
    DisplayRadar(false)
    SetEntityCoords(PlayerPedId(), Config.CameraCoords.selection.x, Config.CameraCoords.selection.y,
        Config.CameraCoords.selection.z)
    StartCam(Config.CameraCoords.selection.x, Config.CameraCoords.selection.y, Config.CameraCoords.selection.z,
        Config.CameraCoords.selection.h, Config.CameraCoords.selection.zoom)
    SpawnCharacters(data)
    FeatherCore.RPC.CallAsync("CreateInstance", { id = 123 })
end)

local Obj1, Obj2, Obj3, Obj4, ped
local firstprompt, secondprompt, thirdprompt
local spawnedPeds = {}

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

function SpawnCharacters(data)
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
    SetEntityVisible(PlayerPedId(), false)
    FreezeEntityPosition(PlayerPedId(), true)
    SetFocusEntity(PlayerPedId())

    for k, v in pairs(data) do
        charCamera[k] = v.id
        ped = FeatherCore.Ped:Create(Config.tempclothhash[k], Config.SpawnCoords.charspots[k].x,
            Config.SpawnCoords.charspots[k].y,
            Config.SpawnCoords.charspots[k].z, 0, 'world', false, false)
        ped:SetHeading(90.0)
        ped:Freeze(true)
        local rawped = ped:GetPed()
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, rawped, 4, 0) -- outfits
        DefaultPedSetup(rawped, true)

        table.insert(spawnedPeds, ped)
    end

    while true do
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
                firstprompt:DeletePrompt()
                secondprompt:DeletePrompt()
                thirdprompt:DeletePrompt()
                print(charCamera[cameraspot])
                TriggerEvent('feather-character:SpawnSelect', cameraspot)
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
    print('Character(s) found going to select screen')
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

feather = exports['feather-core'].initiate()

local Obj1, Obj2, Obj3, Obj4, ped
local camera, show

local spawnedPeds = {}

local firstprompt, secondprompt, thirdprompt


if not IsDoorRegisteredWithSystem(3277501452) then
    Citizen.InvokeNative(0xD99229FE93B46286, 3277501452, 1, 1, 0, 0, 0, 0)
end
DoorSystemSetDoorState(3277501452, 0)

RegisterNetEvent('feather-character:SelectCharacterScreen', function(data)
    print('Character(s) found going to select screen')
    SpawnProps()
    SetEntityVisible(PlayerPedId(), false)
    SetEntityCoords(PlayerPedId(), Config.CameraCoords.selection.x, Config.CameraCoords.selection.y,
        Config.CameraCoords.selection.z)
    StartCam(Config.CameraCoords.selection.x, Config.CameraCoords.selection.y, Config.CameraCoords.selection.z,
        Config.CameraCoords.selection.h, Config.CameraCoords.selection.zoom)
    SpawnCharacters(data)
    feather.RPC.CallAsync("CreateInstance", { id = 123 })
end)

RegisterCommand('spawn', function()
    TriggerEvent('feather-character:SelectCharacterScreen')
end)

RegisterCommand('new', function()
    TriggerEvent('feather-character:CreateNewCharacter')
end)

RegisterCommand('teeth', function()
    RequestAnimDict("FACE_HUMAN@GEN_MALE@BASE")

    while not HasAnimDictLoaded("FACE_HUMAN@GEN_MALE@BASE") do
        Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), "FACE_HUMAN@GEN_MALE@BASE", "Face_Dentistry_Loop", 1090519040, -4, -1, 17, 0, 0, 0, 0, 0,
        0)
end)

RegisterCommand('check', function()
    TriggerServerEvent('feather-character:CheckForUsers')
end)

RegisterCommand('rc', function()
    local ismale = IsPedMale(PlayerPedId())
    local model
    if ismale then model = 'mp_male' else model = 'mp_female' end
    LoadModel(model)
    SetPlayerModel(PlayerId(), joaat(model), false)

    if ismale then
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 4, 0) -- outfits
        DefaultPedSetup(PlayerPedId(), ismale)
    else
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 3, 0) -- outfits
        DefaultPedSetup(PlayerPedId(), ismale)
    end
end)

RegisterCommand('test', function()
    DoScreenFadeIn(10000)
    Wait(2000)
    DoScreenFadeOut(10000)
    AnimpostfxPlay("cutscene_mar6_train")
    SpawnProps()
end)



RegisterCommand('spawn', function()
TriggerEvent('feather-character:SpawnSelect',1)

end)

RegisterCommand('endcam', function()
    EndCam()
end)

RegisterCommand('endscript', function()
    EndScript()
end)

RegisterNetEvent('feather-character:CreateNewCharacter', function()
    print('Character(s) not found going to new character screen')
    DoScreenFadeOut(500)
    Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.creation.x, Config.SpawnCoords.creation.y,
        Config.SpawnCoords.creation.z)
    CreateNewCharacter()
end)

function SpawnProps()
    Obj1 = feather.Object:Create(Config.SpawnProps.obj1.name, Config.SpawnProps.obj1.x, Config.SpawnProps.obj1.y,
        Config.SpawnProps.obj1.z, Config.SpawnProps.obj1.h, false, 'standard')
    Obj2 = feather.Object:Create(Config.SpawnProps.obj2.name, Config.SpawnProps.obj2.x, Config.SpawnProps.obj2.y,
        Config.SpawnProps.obj2.z, Config.SpawnProps.obj2.h, false, 'standard')
    Obj3 = feather.Object:Create(Config.SpawnProps.obj3.name, Config.SpawnProps.obj3.x, Config.SpawnProps.obj3.y,
        Config.SpawnProps.obj3.z, Config.SpawnProps.obj3.h, false, 'standard')
    Obj4 = feather.Object:Create(Config.SpawnProps.obj4.name, Config.SpawnProps.obj4.x, Config.SpawnProps.obj4.y,
        Config.SpawnProps.obj4.z, Config.SpawnProps.obj4.h, false, 'standard')
end

function StartCam(x, y, z, heading, zoom)
    Citizen.InvokeNative(0x17E0198B3882C2CB, PlayerPedId())
    DestroyAllCams(true)
    camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x, y, z, -10.0, 00.00, heading, zoom, true, 0)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 500, true, true)
end

function SwitchCam(x, y, z, heading, zoom)
    SetCamParams(camera, x, y, z, -10.0, 0.0, heading, zoom, 1500, 1, 3, 1)
end

function EndCam()
    RenderScriptCams(false, true, 1000, true, false)
    DestroyCam(camera, false)
    camera = nil
    DestroyAllCams(true)
end

function EndScript()
    RenderScriptCams(false, true, 1000, true, false)
    DestroyCam(camera, false)
    camera = nil
    DestroyAllCams(true)

    Obj1:Remove()
    Obj2:Remove()
    Obj3:Remove()
    Obj4:Remove()
    for k, v in pairs(spawnedPeds) do
        v:Remove()
    end
    show = false
    spawnedPeds = {}

    firstprompt:DeletePrompt()
    secondprompt:DeletePrompt()
    thirdprompt:DeletePrompt()


    Citizen.InvokeNative(0xD0AFAFF5A51D72F7, PlayerPedId())
    feather.RPC.CallAsync("LeaveInstance", { id = 123 })
    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityVisible(PlayerPedId(), true)
end

function SpawnCharacters(data)
    local PromptGroup = feather.Prompt:SetupPromptGroup()                               --Setup Prompt Group

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
    FreezeEntityPosition(PlayerPedId(),true)
    SetFocusEntity(PlayerPedId())

    for k, v in pairs(data) do 
        charCamera[k] = v.id
        ped = feather.Ped:Create(Config.tempclothhash[k], Config.SpawnCoords.charspots[k].x,
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
                TriggerEvent('feather-character:SpawnSelect',cameraspot)

            end
        end


        if cameraspot == nil then
            thirdprompt:TogglePrompt(false)
        elseif cameraspot > 0 then
            thirdprompt:TogglePrompt(true)
        end
    end
end

local current, coords, active

RegisterNetEvent("feather-character:SpawnSelect", function(current)
   -- DoScreenFadeOut(500)
    Wait(500)
    local spawncoords = Config.SpawnCoords.spawns[current].coords
    local PromptGroup2 = feather.Prompt:SetupPromptGroup()                               --Setup Prompt Group

    local leftprompt = PromptGroup2:RegisterPrompt("Left", 0xE6F612E4, 1, 1, true, 'click')   --Register your first prompt
    local rightprompt = PromptGroup2:RegisterPrompt("Right", 0x1CE6D9EB, 1, 1, true, 'click') --Register your first prompt
    local enterprompt = PromptGroup2:RegisterPrompt("Enter", 0x4F49CC4C, 1, 1, true, 'click')  --Register your first prompt
    while true do 
        Wait(0)
        PromptGroup2:ShowGroup("Spawn Select") --Show your prompt group        

    end

    StartCam(Config.SpawnCoords.spawns[current].cameracoords.x,Config.SpawnCoords.spawns[current].cameracoords.y,Config.SpawnCoords.spawns[current].cameracoords.z,
    Config.SpawnCoords.spawns[current].cameracoords.h,Config.SpawnCoords.spawns[current].cameracoords.zoom)
    StartPlayerTeleport(PlayerId(), spawncoords.x, spawncoords.y, spawncoords.z, 0.0, false, true, true)

    while IsPlayerTeleportActive() do
        Wait(100)
    end
    SetEntityVisible(PlayerPedId(), false, 0)

    DoScreenFadeIn(500)
        active = true
        while active do
            DisableAllControlActions(0)
            Wait(0)
            PromptGroup2:ShowGroup("Spawn Select") --Show your prompt group        

            if leftprompt:HasCompleted() then
                if current > 1 then
                    current = current - 1
                else
                    current = #Config.SpawnCoords.spawns
                end
                local coords = Config.SpawnCoords.spawns[current].coords
                DoScreenFadeOut(100)
                Wait(100)
                StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, 0.0, false, true, true)
                while IsPlayerTeleportActive() do
                    Wait(100)
                end
                SetEntityVisible(PlayerPedId(), false, 0)
                SwitchCam(Config.SpawnCoords.spawns[current].cameracoords.x,Config.SpawnCoords.spawns[current].cameracoords.y,Config.SpawnCoords.spawns[current].cameracoords.z,
                Config.SpawnCoords.spawns[current].cameracoords.h,Config.SpawnCoords.spawns[current].cameracoords.zoom)
                Wait(250)
                DoScreenFadeIn(100)
            end
    
            if rightprompt:HasCompleted() then
                if current > 1 then
                    current = current + 1
                else
                    current = #Config.SpawnCoords.spawns
                end
                local coords = Config.SpawnCoords.spawns[current].coords
                DoScreenFadeOut(100)
                Wait(100)
                StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, 0.0, false, true, true)
                while IsPlayerTeleportActive() do
                    Wait(100)
                end
                SetEntityVisible(PlayerPedId(), false, 0)
                SwitchCam(Config.SpawnCoords.spawns[current].cameracoords.x,Config.SpawnCoords.spawns[current].cameracoords.y,Config.SpawnCoords.spawns[current].cameracoords.z,
                Config.SpawnCoords.spawns[current].cameracoords.h,Config.SpawnCoords.spawns[current].cameracoords.zoom)
                Wait(250)
                DoScreenFadeIn(100)
            end
    
            if enterprompt:HasCompleted() then

            end


            local playerCoords = GetEntityCoords(PlayerPedId())
            --[[feather.Render:DrawText(vector2(0.7, 0.5),Config.SpawnCoords.spawns[current].name --'.\n' ..Config.Locales.arrive .. Config.SpawnCoords.spawns[current].arrival,
                { r = 255, g = 0, b = 0, a = 255 }, 1.0, false)
            if Config.SpawnCoords.spawns[current].tip ~= nil then
                feather.Render:DrawText(vector2(0.7, 0.7), Config.SpawnCoords.spawns[current].tip,
                    { r = 255, g = 0, b = 0, a = 255 }, 1.0, false)
            end
            feather.Render:DrawText(vector2(0.7, 0.9), Config.Locales.press, { r = 255, g = 0, b = 0, a = 255 }, 1.0, false)]]
            --DrawText(Config.Locales.where..'.\n'..Config.SpawnLocations[current].info..'.\n'..Config.SpawnLocations[current].name..' '..Config.Locales.by..' '..Config.SpawnLocations[current].arrive..'.\n'..Config.Locales.press, 0.5, 0.75, 0.7, 0.7, 255, 255, 255, 255, true, true)
           --[[ if IsDisabledControlJustReleased(0, 0x7065027D) then -- A
                if current > 1 then
                    current = current - 1
                    print(current)
                    print(Config.SpawnCoords.spawns[current].cameracoords.x,Config.SpawnCoords.spawns[current].cameracoords.y,Config.SpawnCoords.spawns[current].cameracoords.z,
                    Config.SpawnCoords.spawns[current].cameracoords.h,Config.SpawnCoords.spawns[current].cameracoords.zoom)

                else
                    current = #Config.SpawnCoords.spawns
                    print(current)
                    print(Config.SpawnCoords.spawns[current].cameracoords.x,Config.SpawnCoords.spawns[current].cameracoords.y,Config.SpawnCoords.spawns[current].cameracoords.z,
                    Config.SpawnCoords.spawns[current].cameracoords.h,Config.SpawnCoords.spawns[current].cameracoords.zoom)

                end
              --[[  coords = Config.SpawnCoords.spawns[current].coords
                DoScreenFadeOut(100)
                Wait(100)
                StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, 0.0, false, true, true)
                while IsPlayerTeleportActive() do
                    Wait(100)
                end
                SetEntityVisible(PlayerPedId(), false, 0)
                SwitchCam(cameracoords)
                Wait(250)
                DoScreenFadeIn(500)
            elseif IsDisabledControlJustReleased(0, 0xB4E465B4) then -- D
                if current < #Config.SpawnCoords.spawns then
                    current = current + 1
                    print(current)
                    print(Config.SpawnCoords.spawns[current].cameracoords.x,Config.SpawnCoords.spawns[current].cameracoords.y,Config.SpawnCoords.spawns[current].cameracoords.z,
                    Config.SpawnCoords.spawns[current].cameracoords.h,Config.SpawnCoords.spawns[current].cameracoords.zoom)
                else
                    current = 1
                    print(current)
                    print(Config.SpawnCoords.spawns[current].cameracoords.x,Config.SpawnCoords.spawns[current].cameracoords.y,Config.SpawnCoords.spawns[current].cameracoords.z,
                    Config.SpawnCoords.spawns[current].cameracoords.h,Config.SpawnCoords.spawns[current].cameracoords.zoom)

                end
                coords = Config.SpawnCoords.spawns[current].coords
                DoScreenFadeOut(100)
                Wait(100)
                StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, 0.0, false, true, true)
                while IsPlayerTeleportActive() do
                    Wait(100)
                end
                SetEntityVisible(PlayerPedId(), false, 0)
                SwitchCam(cameracoords)
                Wait(250)
                DoScreenFadeIn(500)]]
            if IsDisabledControlJustReleased(0, 0xC7B5340A) then -- ENTER
                DoScreenFadeOut(100)
                Wait(2000)
                EndCam()
                ClearFocus()
                DoScreenFadeIn(1000)
                SetEntityVisible(PlayerPedId(), true, 0)
                active = false
                current = 1
                break
            end
        end
end)

function DrawText(text, x, y, fontscale, fontsize, r, g, b, alpha, textcentred, shadow)
    local str = CreateVarString(10, "LITERAL_STRING", text)
    SetTextScale(fontscale, fontsize)
    SetTextColor(r, g, b, alpha)
    SetTextCentre(textcentred)
    if shadow then
        SetTextDropshadow(1, 0, 0, 255)
    end
    SetTextFontForCurrentCommand(6)
    DisplayText(str, x, y)
end

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('feather-character:CheckForUsers')
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        EndScript()
    end
end)

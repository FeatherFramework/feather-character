-- This is the main file for core character actions.

function CleanupScript()
    CleanupCam()
    CleanupCharacterSelect()

    DisplayRadar(true)
    Citizen.InvokeNative(0xD0AFAFF5A51D72F7, PlayerPedId())
    FeatherCore.RPC.CallAsync("LeaveInstance", { id = 123 })
    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityVisible(PlayerPedId(), true)
end

function LoadPlayer()
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
end

---------------- Registered Net Events ------------------
AddEventHandler('playerSpawned', function()
    print('testing')
    TriggerServerEvent('feather-character:CheckForUsers')
end)



AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CleanupScript()
    end
end)

-- Refresh Character
RegisterCommand('rc', function()
    LoadPlayer()
    TriggerServerEvent('feather-character:GetCharactersData', PlayerPedId())
end)



-- Devmode commands
if Config.DevMode == true then
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
        TaskPlayAnim(PlayerPedId(), "FACE_HUMAN@GEN_MALE@BASE", "Face_Dentistry_Loop", 1090519040, -4, -1, 17, 0, 0, 0, 0,
            0,
            0)
    end)

    RegisterCommand('check', function()
        TriggerServerEvent('feather-character:CheckForUsers')
    end)

    RegisterCommand('cutscene', function()
        DoScreenFadeIn(10000)
        Wait(2000)
        DoScreenFadeOut(10000)
        AnimpostfxPlay("cutscene_mar6_train")
        SpawnProps()
    end)

    RegisterCommand('spawn', function()
        TriggerEvent('feather-character:SpawnSelect', 1)
    end)

    RegisterCommand('endcam', function()
        EndCam()
    end)

    RegisterCommand('endscript', function()
        CleanupScript()
    end)
end

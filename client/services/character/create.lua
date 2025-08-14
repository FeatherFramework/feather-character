local function createNewCharacter()

    Albedo = (CharacterConfig.General.DefaultChar[GetGender()][1].HeadTexture[1])

    local function setSex(sex)
        ChangeOverlay(PlayerPedId(),'eyebrows', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, 1.0, Albedo)
        local function loadModel(model)
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(10) end
        end
        if sex == 'male' then
            loadModel('mp_male')
            SetPlayerModel(PlayerId(), joaat('mp_male'), false)
            Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 4, 0) -- outfits
            DefaultPedSetup(PlayerPedId(), true)
        else
            loadModel('mp_female')
            SetPlayerModel(PlayerId(), joaat('mp_female'), false)
            Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 2, 0) -- outfits
            DefaultPedSetup(PlayerPedId(), false)
        end
    end

    setSex('male')
    Wait(500)

    local ped  = PlayerPedId()
    local dest = Config.SpawnCoords.gotocoords
    local speed, stopRange = 0.5, 0.1

    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanPlayAmbientAnims(ped, false)
    SetPedCanPlayAmbientBaseAnims(ped, false)
    TaskFollowNavMeshToCoord(ped, dest.x, dest.y, dest.z, speed, -1, stopRange, 0, 0)

    Wait(3000)
    DoScreenFadeIn(1000)

    CharacterCamera = StartCam(
        Config.CameraCoords.creation.x,
        Config.CameraCoords.creation.y,
        Config.CameraCoords.creation.z,
        Config.CameraCoords.creation.h,
        Config.CameraCoords.creation.zoom
    )

    while true do
        Wait(5)
        local p = GetEntityCoords(ped)
        if GetDistanceBetweenCoords(p.x, p.y, p.z, dest.x, dest.y, dest.z, true) < 1.0 then
            ClearPedTasks(ped)
            TaskStandStill(ped, -1)
            TaskLookAtCoord(ped, Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, 1500, 0, 2, false)
            local faceHeading = (Config.CameraCoords.creation.h + 180.0) % 360.0
            SetEntityHeading(ped, faceHeading)

            TriggerEvent('feather-character:CreateCharacterMenu')
            CreatingCharacter = true
            while CreatingCharacter do
                Wait(5)
                DrawLightWithRange(dest.x, dest.y - 0.5, dest.z + 1.5, 250, 250, 250, 7.0, 50.0)
            end
            break
        end
    end
end

RegisterNetEvent('feather-character:CreateNewCharacter', function()
    Spawned = false
    CharacterMenu:Close()
    DisplayRadar(false)
    DoScreenFadeOut(500)

    Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.creation.x, Config.SpawnCoords.creation.y, Config.SpawnCoords.creation.z)
    SetEntityVisible(PlayerPedId(), true)
    FreezeEntityPosition(PlayerPedId(), false)
    createNewCharacter()
end)

local function createNewCharacter()
    Albedo = (CharacterConfig.General.DefaultChar[GetGender()][1].HeadTexture[1])
    local function setSex(sex) -- can likely remove this function in future just dont want to dig into how quite yet
        ChangeOverlay(PlayerPedId(),'eyebrows', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, 1.0, Albedo)
        local function loadModel(model)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(10)
            end
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
    local obj = FeatherCore.Object:Create('p_package09', Config.SpawnCoords.gotocoords.x, Config.SpawnCoords.gotocoords.y, Config.SpawnCoords.gotocoords.z-0.5, 0, true, 'standard')
    local tobj = obj:GetObj()
    SetFocusEntity(PlayerPedId())
    SetEntityAlpha(tobj, 0, true)
    TaskGoToEntity(PlayerPedId(), tobj, 10000, 0.2, 0.8, 1.0, 1)
    Wait(3000)
    DoScreenFadeIn(1000)
    CharacterCamera = StartCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y,
        Config.CameraCoords.creation.z,
        Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
    while true do
        Wait(5)
        local pcoords = GetEntityCoords(PlayerPedId())
        if GetDistanceBetweenCoords(pcoords.x, pcoords.y, pcoords.z, Config.SpawnCoords.gotocoords.x, Config.SpawnCoords.gotocoords.y,
                Config.SpawnCoords.gotocoords.z, true) < 1.0 then
            TriggerEvent('feather-character:CreateCharacterMenu')
            CreatingCharacter = true
            while CreatingCharacter do
                Wait(5)
                DrawLightWithRange(Config.SpawnCoords.gotocoords.x, Config.SpawnCoords.gotocoords.y-0.5,
                    Config.SpawnCoords.gotocoords.z+1.5, 250, 250, 250, 7.0, 50.0)
            end
            break
        end
    end
end

--------- Net Events ------
RegisterNetEvent('feather-character:CreateNewCharacter', function()
    Spawned = false
    MyMenu:Close()
    DisplayRadar(false)
    DoScreenFadeOut(500)

    Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.creation.x, Config.SpawnCoords.creation.y,
        Config.SpawnCoords.creation.z)
    SetEntityVisible(PlayerPedId(), true)
    FreezeEntityPosition(PlayerPedId(), false)
    createNewCharacter()
end)

function CreateNewCharacter()
    Albedo = (CharacterConfig.General.DefaultChar[Gender][1].HeadTexture[1])
    SetSex('male')
    Wait(500)
    local obj = FeatherCore.Object:Create('p_package09', Config.SpawnCoords.gotocoords.x, Config.SpawnCoords.gotocoords
        .y,
        Config.SpawnCoords.gotocoords.z-0.5, 0, true, 'standard')
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
        Wait(0)
        local pcoords = GetEntityCoords(PlayerPedId())
        if GetDistanceBetweenCoords(pcoords.x, pcoords.y, pcoords.z, Config.SpawnCoords.gotocoords.x, Config.SpawnCoords.gotocoords.y,
                Config.SpawnCoords.gotocoords.z, true) < 1.0 then
            TriggerEvent('feather-character:CreateCharacterMenu')
            CreatingCharacter = true
            while CreatingCharacter do
                Wait(0)
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
    MyMenu:Close({})
    print('Character(s) not found going to new character screen')
    DisplayRadar(false)
    DoScreenFadeOut(500)

    Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.creation.x, Config.SpawnCoords.creation.y,
        Config.SpawnCoords.creation.z)
    SetEntityVisible(PlayerPedId(), true)
    FreezeEntityPosition(PlayerPedId(), false)
    CreateNewCharacter()
end)

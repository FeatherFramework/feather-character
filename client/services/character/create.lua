function CreateNewCharacter()
    local playerPed = PlayerPedId()
    SetFocusEntity(playerPed)
    Wait(500)
    local obj = FeatherCore.Object:Create('p_package09', Config.SpawnCoords.gotocoords.x, Config.SpawnCoords.gotocoords.y,
        Config.SpawnCoords.gotocoords.z, 0, true, 'standard')
    local tobj = obj:GetObj()
    SetEntityAlpha(tobj, 0, true)
    TaskGoToEntity(playerPed, tobj, 10000, 0.2, 0.8, 1.0, 1)
    Wait(3000)
    DoScreenFadeIn(1000)
    SetFocusEntity(tobj)
    StartCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
        Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
    ToggleUIState()
end

--------- Net Events ------

RegisterNetEvent('feather-character:CreateNewCharacter', function()
    print('Character(s) not found going to new character screen')
    DisplayRadar(false)
    DoScreenFadeOut(500)
    Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.creation.x, Config.SpawnCoords.creation.y,
        Config.SpawnCoords.creation.z)
    CreateNewCharacter()
end)
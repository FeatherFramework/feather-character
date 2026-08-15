-- Final step before spawning a freshly-created character: plays the
-- arrival cinematic for the town chosen back in creationmenu.lua (no second
-- choice screen here anymore -- `townIndex` is already known and already
-- persisted to the DB by SaveCharacterData, so this just has to agree with
-- it) and calls InitiateCharacter with `CharInfo` (the id SaveCharacterData
-- just returned). The character-select screen (selector.lua) spawns
-- directly via InitiateCharacter and never goes through this event.
RegisterNetEvent("feather-character:SpawnSelect", function(CharInfo, townIndex)
    CharacterMenu:Close()

    local town = Config.SpawnCoords.towns[townIndex] or Config.SpawnCoords.towns[1]

    CharSpawnCoords = vector4(town.startcoords.x, town.startcoords.y, town.startcoords.z, town.startcoords.h)
    GotoCoords = vector4(town.gotocoords.x, town.gotocoords.y, town.gotocoords.z, town.gotocoords.h)
    ArrivalMethod = town.arrival

    SetFocusPosAndVel(town.cameracoords.x, town.cameracoords.y, town.cameracoords.z, 0, 0, 0)
    DoScreenFadeOut(250)
    Wait(750)
    StartCam(town.cameracoords.x, town.cameracoords.y, town.cameracoords.z, town.cameracoords.h, town.cameracoords.zoom)

    TriggerServerEvent('feather-character:InitiateCharacter', CharInfo)
    SetEntityCoords(PlayerPedId(), CharSpawnCoords.x + 5.0, CharSpawnCoords.y, CharSpawnCoords.z, true, false, false, false)
    CleanupScript()
    SpawnMethod(ArrivalMethod, CharSpawnCoords, GotoCoords)
end)

-- Plays out the chosen town's arrival cinematic: 'Train' spawns/boards a
-- train and rides it to GotoCoords, 'Wagon' drives a spawned coach there,
-- 'Horse' mounts a spawned horse and rides there. Each branch cleans up its
-- spawned vehicle/mount once the player arrives.
function SpawnMethod(Method, CharSpawnCoords,GotoCoords)
    if Method == 'Train' then
        local cars = Citizen.InvokeNative(0x635423d55ca84fc8, 1495948496)             -- GetNumCarsFromTrainConfig
        for index = 0, cars - 1 do
            local model = Citizen.InvokeNative(0x8df5f6a19f99f0d5, 1495948496, index) -- GetTrainModelFromTrainConfigByCarIndex
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(10)
            end
        end
        ArriveMethod = Citizen.InvokeNative(0xC239DBD9A57D2A71, 1495948496, CharSpawnCoords.x, CharSpawnCoords.y,
            CharSpawnCoords.z, 1, true, false, true)
            SetTrainCruiseSpeed(ArriveMethod, 0.0)
            SetModelAsNoLongerNeeded(1495948496)
        SetTimeout(1000, function()
            Wait(1000)
            ClearPedTasksImmediately(PlayerPedId())
            local scenario = Citizen.InvokeNative(0xF533D68FF970D190, GetEntityCoords(PlayerPedId()), -447259824, 50.0)
            DoScreenFadeIn(500)
            TaskUseScenarioPoint(PlayerPedId(), scenario, 0, 0, 0, 1, 0, 0, -1082130432, 0)
            Wait(250)
            local sitting = Citizen.InvokeNative(0x9C54041BB66BCF9E,PlayerPedId(), scenario)
            if sitting then
                Citizen.InvokeNative(0xE6C5E2125EB210C1, GetHashKey('TRAINS_NB1'), 1, 1)
                SetTrainCruiseSpeed(ArriveMethod, 10.0)
            end
        end)
        while true do
            Wait(5)
            local pcoords = vector3(GetEntityCoords(PlayerPedId()))
            if GetDistanceBetweenCoords(pcoords,GotoCoords,true) <5.0 then
                SetTrainCruiseSpeed(ArriveMethod, 0.0)
                ClearPedTasks(PlayerPedId())
                Wait(20000)
                SetTrainCruiseSpeed(ArriveMethod, 10.0)
                Wait(20000)
                DeleteMissionTrain(ArriveMethod)
            end
        end
    elseif Method == 'Wagon' then
        Wait(500)
        DoScreenFadeIn(500)
        ArriveMethod = CreateVehicle(GetHashKey('coach5'),CharSpawnCoords.x, CharSpawnCoords.y, CharSpawnCoords.z, CharSpawnCoords.h, false, false, false, false)
        TaskEnterVehicle(PlayerPedId(),ArriveMethod,-1,-1,3,4,0)
        TaskVehicleDriveToCoord(PlayerPedId(),ArriveMethod,GotoCoords.x, GotoCoords.y, GotoCoords.z,5.0,1,GetHashKey('coach5'),67108864,5.0,50)
        Wait(20000)
        DeleteEntity(ArriveMethod)
    elseif Method == 'Horse' then
        local obj = FeatherCore.Object:Create('p_package09', GotoCoords.x, GotoCoords.y, GotoCoords.z, 0, false, 'standard')
        SetEntityAlpha(obj:GetObj())
        Wait(500)
        DoScreenFadeIn(500)
        ArriveMethod = FeatherCore.Horse:Create('a_c_horse_americanstandardbred_black', CharSpawnCoords.x, CharSpawnCoords.y, CharSpawnCoords.z,CharSpawnCoords.h, 'male')
        ArriveMethod:SetComponentEnabled(0x150D0DAA)
        ArriveMethod:SetComponentEnabled(0x127E0412)
        Mount = ArriveMethod:GetHorse()
        TaskMountAnimal(PlayerPedId(), Mount, 1, -1, 5.0, 1, 0, 0)
        Wait(250)
        TaskGoToCoordAnyMeans(PlayerPedId(),GotoCoords.x, GotoCoords.y, GotoCoords.z,15.0,0,0,786603,0xbf800000)
        while true do
            Wait(5)
            local pcoords = vector3(GetEntityCoords(PlayerPedId()))
            if GetDistanceBetweenCoords(pcoords,GotoCoords,true) <5.0 then
                TaskDismountAnimal(PlayerPedId(),0,0,0,0,0)
                Wait(5000)
                TaskFleePed(Mount,PlayerPedId(),4,-1,-1,-1,0)
                Wait(15000)
                ArriveMethod:Remove()
            end
        end
    end
end
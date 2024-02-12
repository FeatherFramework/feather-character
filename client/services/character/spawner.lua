local current, coords, active

SpawnSelectInfo = FeatherMenu:RegisterMenu('feather:spawnselect:menu', {
    top = '5%',
    left = '5%',
    ['720width'] = '500px',
    ['1080width'] = '600px',
    ['2kwidth'] = '700px',
    ['4kwidth'] = '900px',
    style = {
    },
    contentslot = {
        style = { --This style is what is currently making the content slot scoped and scrollable. If you delete this, it will make the content height dynamic to its inner content.
            ['height'] = '700px',
            ['width'] = '300px',
            ['min-height'] = '300px'
        }
    },
    draggable = false,
    canclose = true
})

local SpawnSelectPage = SpawnSelectInfo:RegisterPage('spawnselect:page')

local Header1, CityTextDisplay, SpawnButton

RegisterNetEvent("feather-character:SpawnSelect", function(CharInfo)
    if Header1 then
        Header1:unRegister()
        CityTextDisplay:unRegister()
        CityTextDisplay2:unRegister()
        SpawnButton:unRegister()
    end
    Header1 = SpawnSelectPage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })

    CityTextDisplay = SpawnSelectPage:RegisterElement('textdisplay', {
        value = "Choose your starting city",
        style = {}
    })

    SpawnSelectPage:RegisterElement('bottomline', {
        slot = "content",
    })

    CityTextDisplay2 = SpawnSelectPage:RegisterElement('textdisplay', {
        value = " ",
        style = {}
    })

    for k, v in pairs(Config.SpawnCoords.towns) do
        SpawnButton = SpawnSelectPage:RegisterElement('button', {
            label = v.name,
            style = {

            },
        }, function()
            CityTextDisplay2:update({
                value = "You will arrive by " .. v.arrival,
            })
            CharSpawnCoords = vector4(v.startcoords.x, v.startcoords.y, v.startcoords.z,v.startcoords.h)
            GotoCoords = vector4(v.gotocoords.x,v.gotocoords.y,v.gotocoords.z,v.gotocoords.h)
            ArrivalMethod = v.arrival
            SetFocusPosAndVel(v.cameracoords.x, v.cameracoords.y, v.cameracoords.z, 0, 0, 0)
            DoScreenFadeOut(250)
            Wait(750)
            DoScreenFadeIn(250)
            StartCam(v.cameracoords.x, v.cameracoords.y, v.cameracoords.z, v.cameracoords.h, v.cameracoords.zoom)
        end)
    end

    SpawnSelectPage:RegisterElement('button', {
        label = "Spawn",
        style = {

        },

    }, function()
        DoScreenFadeOut(250)
        TriggerServerEvent('feather-character:InitiateCharacter', CharInfo)
        TriggerServerEvent('feather-character:GetCharactersData', CharInfo)
        SetEntityCoords(PlayerPedId(), CharSpawnCoords.x+5.0, CharSpawnCoords.y, CharSpawnCoords.z, true, false, false,
            false)
        CleanupScript()
        SpawnMethod(ArrivalMethod, CharSpawnCoords,GotoCoords)
    end)

    SpawnSelectInfo:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = SpawnSelectPage,
    })
end)


function LoadTrainCars(trainHash)
    local cars = Citizen.InvokeNative(0x635423d55ca84fc8, trainHash)             -- GetNumCarsFromTrainConfig
    for index = 0, cars - 1 do
        local model = Citizen.InvokeNative(0x8df5f6a19f99f0d5, trainHash, index) -- GetTrainModelFromTrainConfigByCarIndex
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(10)
        end
    end
end

function SpawnMethod(Method, CharSpawnCoords,GotoCoords)
    if Method == 'Train' then
        LoadTrainCars(1495948496)
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
            Wait(0)
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
        print(GotoCoords)
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
            Wait(0)
            local pcoords = vector3(GetEntityCoords(PlayerPedId()))
            if GetDistanceBetweenCoords(pcoords,GotoCoords,true) <5.0 then
                TaskDismountAnimal(PlayerPedId(),0,0,0,0,0)
                Wait(5000)
                TaskFleePed(Mount,PlayerPedId,4,-1,-1,-1,0)
            end
        end
    elseif Method == 'Boat' then

    end
end

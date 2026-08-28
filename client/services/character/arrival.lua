-- First-spawn arrival presentation. Character creation selects and persists
-- the destination; this client-only service presents the trip after the
-- server has authorized the new character's Contract 1 activation.

CharacterArrival = CharacterArrival or {}

local activeEntity

local function LoadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelValid(hash) then return nil end
    RequestModel(hash)
    local deadline = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < deadline do Wait(10) end
    if not HasModelLoaded(hash) then return nil end
    return hash
end

local function RemoveEntity(entity)
    if entity and DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, true, true)
        DeleteEntity(entity)
    end
end

local function WaitForArrival(destination, timeoutMs)
    local deadline = GetGameTimer() + timeoutMs
    while GetGameTimer() < deadline do
        local position = GetEntityCoords(PlayerPedId())
        if #(position - vector3(destination.x, destination.y, destination.z)) < 7.5 then
            return true
        end
        Wait(100)
    end
    return false
end

local function TravelByVehicle(model, start, destination, speed, cameraDistance, cameraHeight)
    local hash = LoadModel(model)
    if not hash then return false end
    activeEntity = CreateVehicle(hash, start.x, start.y, start.z, start.h, false, false, false, false)
    SetModelAsNoLongerNeeded(hash)
    if not activeEntity or activeEntity == 0 then return false end

    SetPedIntoVehicle(PlayerPedId(), activeEntity, -1)
    FollowCam(activeEntity, cameraDistance, cameraHeight)
    TaskVehicleDriveToCoord(PlayerPedId(), activeEntity, destination.x, destination.y, destination.z,
        speed, 1, hash, 67108864, 5.0, 50.0)
    local arrived = WaitForArrival(destination, 90000)
    ClearPedTasksImmediately(PlayerPedId())
    RemoveEntity(activeEntity)
    activeEntity = nil
    return arrived
end

local function TravelByHorse(start, destination)
    local wrapper = CharacterRuntime.Ped:Create('a_c_horse_americanstandardbred_black',
        start.x, start.y, start.z, start.h, nil, nil, nil, nil, false)
    if not wrapper then return false end
    activeEntity = wrapper:GetPed()
    Citizen.InvokeNative(0xD3A7B003ED343FD9, activeEntity, 0x150D0DAA, true, true, true)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, activeEntity, 0x127E0412, true, true, true)
    TaskMountAnimal(PlayerPedId(), activeEntity, -1, -1, 5.0, 1, 0, 0)
    Wait(750)
    FollowCam(activeEntity, 7.0, 3.0)
    TaskGoToCoordAnyMeans(PlayerPedId(), destination.x, destination.y, destination.z,
        15.0, 0, 0, 786603, -1.0)
    local arrived = WaitForArrival(destination, 90000)
    TaskDismountAnimal(PlayerPedId(), 0, 0, 0, 0, 0)
    Wait(750)
    wrapper:Remove()
    activeEntity = nil
    return arrived
end

function CharacterArrival.Play(townIndex, authorizedDestination)
    local town = Config.SpawnCoords.towns[tonumber(townIndex) or 1]
    if not town then return false end

    local start = town.startcoords
    -- The town selects only the presentation. Final placement always comes
    -- from the server-authorized Contract 1 spawn plan.
    local destination = authorizedDestination or town.gotocoords
    DoScreenFadeOut(250)
    Wait(300)
    SetFocusPosAndVel(town.cameracoords.x, town.cameracoords.y, town.cameracoords.z, 0.0, 0.0, 0.0)
    SetEntityCoords(PlayerPedId(), start.x, start.y, start.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), start.h or 0.0)
    DisplayRadar(false)
    StartCam(town.cameracoords.x, town.cameracoords.y, town.cameracoords.z,
        town.cameracoords.h, town.cameracoords.zoom)
    DoScreenFadeIn(500)

    local arrived = false
    if town.arrival == 'Wagon' then
        arrived = TravelByVehicle(town.vehicleModel or 'coach5', start, destination, 5.0, 11.0, 5.0)
    elseif town.arrival == 'Horse' then
        arrived = TravelByHorse(start, destination)
    elseif town.arrival == 'Boat' then
        arrived = TravelByVehicle(town.vehicleModel or 'rowboat', start, destination, 6.0, 10.0, 4.0)
    end

    DoScreenFadeOut(250)
    Wait(300)
    RemoveEntity(activeEntity)
    activeEntity = nil
    EndCam()
    SetEntityCoords(PlayerPedId(), destination.x, destination.y, destination.z,
        false, false, false, false)
    SetEntityHeading(PlayerPedId(), destination.h or 0.0)
    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityVisible(PlayerPedId(), true)
    DisplayRadar(true)
    SetFocusEntity(PlayerPedId())
    return arrived
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        RemoveEntity(activeEntity)
        activeEntity = nil
    end
end)

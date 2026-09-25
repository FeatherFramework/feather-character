-- Optional first-spawn presentations. Each adapter owns every entity and
-- camera it creates, returns a bounded result, and leaves direct placement as
-- the caller's fallback.
CharacterV2Arrival = {}

local activeHorse
local activeCamera
local generation = 0
local controlsLocked = false

local function Ok(value)
    return CharacterV2Result.Ok(value)
end

local function Fail(code, message)
    return CharacterV2Result.Err(code, message)
end

local function Log(stage, detail)
    print(('[feather-character-v2] arrival: %s%s'):format(stage,
        detail and (' ' .. tostring(detail)) or ''))
end

local function DeleteOwnedHorse()
    local horse = activeHorse
    activeHorse = nil
    if horse and horse ~= 0 and DoesEntityExist(horse) then
        SetEntityAsMissionEntity(horse, true, true)
        DeletePed(horse)
    end
end

local function DestroyOwnedCamera(ease)
    local camera = activeCamera
    activeCamera = nil
    if camera and camera ~= 0 then
        RenderScriptCams(false, ease == true, ease and 500 or 0, true, false, 0)
        if DoesCamExist(camera) then DestroyCam(camera, false) end
    end
end

function CharacterV2Arrival.Cleanup()
    generation = generation + 1
    controlsLocked = false
    DestroyOwnedCamera(false)
    local playerPed = PlayerPedId()
    if playerPed and playerPed ~= 0 and IsPedOnMount(playerPed) then
        ClearPedTasksImmediately(playerPed)
    end
    DeleteOwnedHorse()
    DisplayRadar(true)
end

local function LoadModel(model, timeoutMs)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelValid(hash) then return nil end
    RequestModel(hash)
    local deadline = GetGameTimer() + timeoutMs
    while not HasModelLoaded(hash) and GetGameTimer() < deadline do Wait(0) end
    if not HasModelLoaded(hash) then return nil end
    return hash
end

local function LoadCollision(position, ped, timeoutMs)
    RequestCollisionAtCoord(position.x, position.y, position.z)
    local deadline = GetGameTimer() + timeoutMs
    while GetGameTimer() < deadline do
        RequestCollisionAtCoord(position.x, position.y, position.z)
        if HasCollisionLoadedAroundEntity(ped) then return true end
        Wait(0)
    end
    return false
end

local function CreateFollowCamera(horse, spec)
    local camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    if not camera or camera == 0 or not DoesCamExist(camera) then return false end
    activeCamera = camera
    AttachCamToEntity(camera, horse, spec.offsetX, spec.offsetY, spec.offsetZ, true)
    PointCamAtEntity(camera, horse, 0.0, 0.0, 1.0, true)
    SetCamFov(camera, spec.fov)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 500, true, true, 0)
    return true
end

local function BeginFleeCleanup(horse, spec)
    local ticket = generation
    SetEntityInvincible(horse, false)
    SetBlockingOfNonTemporaryEvents(horse, false)
    SetPedCanRagdoll(horse, true)
    Citizen.InvokeNative(0x22B0D0E37CCB840D,
        horse,
        PlayerPedId(),
        spec.fleeDistance,
        spec.fleeTimeoutMs,
        spec.fleeType,
        spec.fleeSpeed
    )
    Log('horse fleeing', ('ped=%s fadeAfterMs=%s'):format(horse, spec.fadeAfterMs))
    CreateThread(function()
        Wait(spec.fadeAfterMs)
        if ticket ~= generation or horse ~= activeHorse or not DoesEntityExist(horse) then return end
        local started = GetGameTimer()
        while ticket == generation and horse == activeHorse and DoesEntityExist(horse) do
            local progress = math.min((GetGameTimer() - started) / spec.fadeDurationMs, 1.0)
            SetEntityAlpha(horse, math.floor(255 * (1.0 - progress)), false)
            if progress >= 1.0 then break end
            Wait(0)
        end
        if ticket == generation and horse == activeHorse then
            DeleteOwnedHorse()
            Log('horse cleanup complete')
        end
    end)
end

local function PlayHorse(townKey, town, playerPed)
    local horseSpec = town.horse
    if not IsScreenFadedOut() then
        DoScreenFadeOut(250)
        while not IsScreenFadedOut() do Wait(0) end
    end
    local hash = LoadModel(horseSpec.model, CharacterV2Config.arrivals.modelTimeoutMs)
    if not hash then return Fail('arrival_model_timeout', 'The arrival horse model did not load.') end

    local playerSpawn = town.playerSpawn
    RequestCollisionAtCoord(playerSpawn.x, playerSpawn.y, playerSpawn.z)
    SetEntityCoords(playerPed, playerSpawn.x, playerSpawn.y, playerSpawn.z,
        false, false, false, false)
    SetEntityHeading(playerPed, playerSpawn.heading or 0.0)
    if not LoadCollision(playerSpawn, playerPed, CharacterV2Config.arrivals.collisionTimeoutMs) then
        SetModelAsNoLongerNeeded(hash)
        return Fail('arrival_collision_timeout',
            ('The %s arrival collision did not load.'):format(townKey))
    end
    PlaceEntityOnGroundProperly(playerPed)

    local spawn = town.horseSpawn
    local horse = CreatePed(hash, spawn.x, spawn.y, spawn.z, spawn.heading or 0.0,
        false, true, false, false)
    SetModelAsNoLongerNeeded(hash)
    if not horse or horse == 0 or not DoesEntityExist(horse) then
        return Fail('arrival_horse_create_failed', 'The arrival horse could not be created.')
    end
    activeHorse = horse
    SetEntityAsMissionEntity(horse, true, true)
    SetEntityVisible(horse, false)
    SetEntityInvincible(horse, true)
    SetBlockingOfNonTemporaryEvents(horse, true)
    SetPedCanRagdoll(horse, false)
    if not LoadCollision(spawn, horse, CharacterV2Config.arrivals.collisionTimeoutMs) then
        return Fail('arrival_horse_collision_timeout', 'The arrival horse collision did not load.')
    end
    Citizen.InvokeNative(0x58A850EAEE20FAA3, horse)
    Citizen.InvokeNative(0x9587913B9E772D29, horse, true)
    SetEntityHeading(horse, spawn.heading or 0.0)
    Citizen.InvokeNative(0x283978A15512B2FE, horse, true)
    for _, componentHash in ipairs(horseSpec.components or {}) do
        Citizen.InvokeNative(0xD3A7B003ED343FD9, horse, componentHash, true, true, true)
    end
    Citizen.InvokeNative(0xAAB86462966168CE, horse, true)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, horse, false, true, true, true, false)

    SetEntityVisible(horse, true)
    SetEntityVisible(playerPed, true)
    ResetEntityAlpha(playerPed)
    FreezeEntityPosition(playerPed, false)
    DisplayRadar(false)
    controlsLocked = true
    if not CreateFollowCamera(horse, town.camera) then
        return Fail('arrival_camera_failed', 'The arrival camera could not be created.')
    end
    Wait(horseSpec.preMountDelayMs)

    Log('mounting player', ('player=%s horse=%s'):format(playerPed, horse))
    Citizen.InvokeNative(0x92DB0739813C5186,
        playerPed,
        horse,
        horseSpec.mountTimeoutMs,
        -1,
        5.0,
        1,
        0,
        0
    )
    local mountDeadline = GetGameTimer() + horseSpec.mountTimeoutMs
    while not Citizen.InvokeNative(0x95CBC65780DE7EB1, playerPed, false)
        and GetGameTimer() < mountDeadline do
        Wait(10)
    end
    if not Citizen.InvokeNative(0x95CBC65780DE7EB1, playerPed, false) then
        return Fail('arrival_mount_failed',
            'The player did not finish mounting the arrival horse.')
    end
    Log('player fully mounted', ('horse=%s'):format(horse))
    Wait(horseSpec.postMountDelayMs)

    local destination = town.destination
    Citizen.InvokeNative(0x79482C12482A860D,
        playerPed,
        horseSpec.travelSpeed,
        destination.x,
        destination.y,
        destination.z,
        0
    ) -- TaskMoveFollowRoadUsingNavmesh
    Log('horse started', ('town=%s horse=%s'):format(townKey, horse))
    DoScreenFadeIn(500)

    local deadline = GetGameTimer() + horseSpec.routeTimeoutMs
    local arrived = false
    while GetGameTimer() < deadline and DoesEntityExist(horse) do
        local coords = GetEntityCoords(playerPed)
        local dx, dy, dz = coords.x - destination.x, coords.y - destination.y, coords.z - destination.z
        if math.sqrt(dx * dx + dy * dy + dz * dz) <= horseSpec.arrivalRadius then
            arrived = true
            break
        end
        Wait(100)
    end
    if not arrived then
        return Fail('arrival_route_timeout',
            ('The arrival horse did not reach its %s destination.'):format(townKey))
    end
    Log('destination reached', ('town=%s'):format(townKey))

    ClearPedTasks(playerPed)
    if Citizen.InvokeNative(0x460BC76A0E10655E, playerPed) then
        Citizen.InvokeNative(0x48E92D3DDE23C23A, playerPed, 0, 0, 0, 0, horse)
        local dismountDeadline = GetGameTimer() + horseSpec.dismountTimeoutMs
        while not Citizen.InvokeNative(0x01FEE67DB37F59B2, playerPed)
            and GetGameTimer() < dismountDeadline do
            Wait(10)
        end
    end
    if not Citizen.InvokeNative(0x01FEE67DB37F59B2, playerPed) then
        return Fail('arrival_dismount_timeout',
            'The player did not finish dismounting the arrival horse.')
    end
    Log('player fully dismounted', ('horse=%s'):format(horse))

    ClearPedTasks(playerPed)
    DestroyOwnedCamera(true)
    DisplayRadar(true)
    controlsLocked = false
    BeginFleeCleanup(horse, horseSpec.cleanup)
    Log('horse complete', ('town=%s'):format(townKey))
    return Ok({ played = true, type = 'horse', town = townKey })
end

function CharacterV2Arrival.Play(townKey, playerPed, requestedType)
    CharacterV2Arrival.Cleanup()
    local settings = CharacterV2Config.arrivals
    local town = settings and settings.enabled and settings.towns[townKey]
    if not town then return Fail('arrival_unavailable', 'No enabled arrival exists for this town.') end
    local arrivalType = requestedType or town.type
    if arrivalType ~= 'horse' then
        return Fail('arrival_unsupported', 'This arrival type is not implemented yet.')
    end
    local ok, result = xpcall(function() return PlayHorse(townKey, town, playerPed) end, debug.traceback)
    if not ok then
        if not IsScreenFadedOut() then
            DoScreenFadeOut(250)
            Wait(300)
        end
        CharacterV2Arrival.Cleanup()
        return Fail('arrival_failed', tostring(result))
    end
    if type(result) ~= 'table' or not result.ok then
        local failure = result or Fail('arrival_failed', 'The arrival failed without a result.')
        if not IsScreenFadedOut() then
            DoScreenFadeOut(250)
            Wait(300)
        end
        CharacterV2Arrival.Cleanup()
        return failure
    end
    return result
end

AddEventHandler('onClientResourceStop', function(resource)
    if resource == GetCurrentResourceName() then CharacterV2Arrival.Cleanup() end
end)

CreateThread(function()
    while true do
        if controlsLocked then
            DisableAllControlActions(0)
            Wait(0)
        else
            Wait(250)
        end
    end
end)

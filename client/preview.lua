-- Selector presentation owns a disposable clone. Character creation edits the
-- live player ped so RedM's metaped head-overlay pipeline behaves normally.
CharacterV2Preview = {}

local activePed
local outgoingPed
local selectorPool = {}
local activeCamera
local activeView
local activeSelectorGround
local generation = 0
local rotationGeneration = 0

local function NativeTrue(value)
    return value == true or value == 1
end

local function ValidModel(model)
    return model == 'mp_male' or model == 'mp_female'
end

local function PrepareBaseMetaped(ped, model)
    local preset = CharacterV2Config.playerBasePreset[model]
    if type(preset) ~= 'number' then return false end
    Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, preset, false)
    Citizen.InvokeNative(0xAAB86462966168CE, ped, true)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    local deadline = GetGameTimer() + CharacterV2Config.preview.modelTimeoutMs
    while GetGameTimer() < deadline do
        if NativeTrue(Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)) then return true end
        Wait(0)
    end
    return false
end

local function DeleteOwnedPed(ped)
    if ped and ped ~= 0 and ped ~= PlayerPedId() and DoesEntityExist(ped) then
        SetEntityAsMissionEntity(ped, true, true)
        DeletePed(ped)
    end
end

function CharacterV2Preview.Close(preserveCamera)
    generation = generation + 1
    rotationGeneration = rotationGeneration + 1
    if activeCamera and not preserveCamera then
        RenderScriptCams(false, true, 250, true, false, 0)
        if DoesCamExist(activeCamera) then DestroyCam(activeCamera, false) end
        activeCamera = nil
    end
    DeleteOwnedPed(activePed)
    DeleteOwnedPed(outgoingPed)
    for _, ped in pairs(selectorPool) do DeleteOwnedPed(ped) end
    selectorPool = {}
    activePed = nil
    outgoingPed = nil
    if not preserveCamera then activeView = nil end
    activeSelectorGround = nil
    return CharacterV2Result.Ok(true)
end

function CharacterV2Preview.Open(viewName, model)
    local view = CharacterV2Config.preview[viewName]
    if type(view) ~= 'table' or type(view.ped) ~= 'table'
        or (type(view.camera) ~= 'table' and type(view.views) ~= 'table') then
        return CharacterV2Result.Err('invalid_view', 'Unknown character preview view.')
    end
    if not ValidModel(model) then
        return CharacterV2Result.Err('invalid_model', 'Only supported player models can be previewed.')
    end

    local preserveCamera = activeView == viewName
        and activeCamera ~= nil and DoesCamExist(activeCamera)
    if preserveCamera and viewName == 'selector' then
        generation = generation + 1
        rotationGeneration = rotationGeneration + 1
        DeleteOwnedPed(outgoingPed)
        outgoingPed = activePed
        activePed = nil
    else
        CharacterV2Preview.Close(preserveCamera)
    end
    local ticket = generation
    local position = view.ped
    local framing = view.camera or (view.views and view.views[view.defaultView])
    local hash = joaat(model)
    if not IsModelValid(hash) then
        return CharacterV2Result.Err('invalid_model', 'The preview model is unavailable.')
    end
    RequestModel(hash)
    local modelDeadline = GetGameTimer() + CharacterV2Config.preview.modelTimeoutMs
    while not HasModelLoaded(hash) and GetGameTimer() < modelDeadline and ticket == generation do
        Wait(0)
    end
    if ticket ~= generation or not HasModelLoaded(hash) then
        SetModelAsNoLongerNeeded(hash)
        return CharacterV2Result.Err('model_timeout', 'The preview model did not load.')
    end

    local playerPed = PlayerPedId()
    if GetEntityModel(playerPed) ~= hash then
        SetPlayerModel(PlayerId(), hash, false)
        playerPed = PlayerPedId()
    end
    SetModelAsNoLongerNeeded(hash)

    if not playerPed or playerPed == 0 or not DoesEntityExist(playerPed) then
        return CharacterV2Result.Err('preview_create_failed', 'The player metaped was not created.')
    end
    -- Model replacement can expose the new base metaped for a frame. Keep it
    -- fully hidden until its preset and saved/default appearance are complete.
    SetEntityVisible(playerPed, false)
    SetEntityAlpha(playerPed, 0, false)
    if not PrepareBaseMetaped(playerPed, model) then
        return CharacterV2Result.Err('preview_render_timeout', 'The player metaped did not initialize.')
    end

    local ped
    if viewName == 'selector' then
        -- The in-place v2 selector proved this stage position using the live
        -- player. Resolve that same transform before cloning so the disposable
        -- ped inherits a real grounded matrix instead of being teleported from
        -- an unrelated spawn position.
        SetEntityVisible(playerPed, false)
        FreezeEntityPosition(playerPed, false)
        if not activeSelectorGround then
            RequestCollisionAtCoord(position.x, position.y, position.z)
            SetEntityCoords(playerPed, position.x, position.y, position.z,
                false, false, false, false)
            local sourceCollisionDeadline = GetGameTimer()
                + CharacterV2Config.preview.collisionTimeoutMs
            while ticket == generation and GetGameTimer() < sourceCollisionDeadline do
                RequestCollisionAtCoord(position.x, position.y, position.z)
                if HasCollisionLoadedAroundEntity(playerPed) then break end
                Wait(0)
            end
            if ticket ~= generation or not HasCollisionLoadedAroundEntity(playerPed) then
                return CharacterV2Result.Err('preview_timeout',
                    'The selector stage collision did not load.')
            end
            SetEntityHeading(playerPed, position.heading or 0.0)
            PlaceEntityOnGroundProperly(playerPed)
            Wait(100)
            local resolved = GetEntityCoords(playerPed)
            activeSelectorGround = { x = resolved.x, y = resolved.y, z = resolved.z }
        end

        local ground = activeSelectorGround
        -- Clone away from the visible carousel. Both the hidden source and
        -- selector clones are presentation-only and never participate in
        -- physics, eliminating the one-frame shove during neighbor warming.
        SetEntityCollision(playerPed, false, false)
        SetEntityCoords(playerPed, ground.x, ground.y, ground.z + 10.0,
            false, false, false, false)

        ped = ClonePed(playerPed, false, true, true)
        if not ped or ped == 0 or ped == playerPed or not DoesEntityExist(ped) then
            return CharacterV2Result.Err('preview_clone_failed', 'The selector preview clone was not created.')
        end
        SetEntityCollision(ped, false, false)
        SetEntityCoords(ped, ground.x, ground.y, ground.z,
            false, false, false, false)
        SetEntityHeading(ped, position.heading or 0.0)
        if outgoingPed and DoesEntityExist(outgoingPed) then
            SetEntityNoCollisionEntity(ped, outgoingPed, false)
            SetEntityNoCollisionEntity(outgoingPed, ped, false)
        end
        for _, cachedPed in pairs(selectorPool) do
            if cachedPed ~= ped and DoesEntityExist(cachedPed) then
                SetEntityNoCollisionEntity(ped, cachedPed, false)
                SetEntityNoCollisionEntity(cachedPed, ped, false)
            end
        end
        FreezeEntityPosition(playerPed, true)
    else
        ped = playerPed
        SetEntityCollision(ped, true, true)
    end
    activePed = ped
    RequestCollisionAtCoord(position.x, position.y, position.z)
    if viewName ~= 'selector' then
        SetEntityCoords(ped, position.x, position.y, position.z + 1.0,
            false, false, false, false)
    end
    SetEntityAlpha(ped, 255, false)
    FreezeEntityPosition(ped, viewName == 'creator')
    SetEntityVisible(ped, false)
    local collisionDeadline = GetGameTimer() + CharacterV2Config.preview.collisionTimeoutMs
    while ticket == generation and GetGameTimer() < collisionDeadline do
        RequestCollisionAtCoord(position.x, position.y, position.z)
        if HasCollisionLoadedAroundEntity(ped)
            and NativeTrue(Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)) then break end
        Wait(0)
    end
    if ticket ~= generation or not HasCollisionLoadedAroundEntity(ped)
        or not NativeTrue(Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)) then
        if ticket == generation then CharacterV2Preview.Close() else DeleteOwnedPed(ped) end
        return CharacterV2Result.Err('preview_timeout', 'The preview ped was not ready.')
    end
    if viewName ~= 'selector' then
        local grounded = PlaceEntityOnGroundProperly(ped)
        if grounded == false then
            CharacterV2Preview.Close()
            return CharacterV2Result.Err('preview_ground_failed', 'The preview ped could not be grounded.')
        end
    end
    SetEntityHeading(ped, position.heading or 0.0)

    local camera = preserveCamera and activeCamera
        or CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    if not camera or camera == 0 or not DoesCamExist(camera) then
        CharacterV2Preview.Close()
        return CharacterV2Result.Err('camera_create_failed', 'The preview camera was not created.')
    end
    activeCamera = camera
    activeView = viewName
    SetCamCoord(camera, framing.x, framing.y, framing.z)
    SetCamRot(camera, framing.rotX, framing.rotY, framing.rotZ, 2)
    SetCamFov(camera, framing.fov)
    SetCamActive(camera, true)
    if preserveCamera then
        RenderScriptCams(true, false, 0, true, true, 0)
    else
        RenderScriptCams(true, true, 350, true, true, 0)
    end
    return CharacterV2Result.Ok({ ped = ped, camera = camera, view = viewName })
end

function CharacterV2Preview.StashSelector(key)
    if activeView ~= 'selector' or type(key) ~= 'string'
        or not activePed or not DoesEntityExist(activePed) then
        return CharacterV2Result.Err('preview_unavailable',
            'A prepared selector preview is required.')
    end
    local prepared = activePed
    local replaced = selectorPool[key]
    if replaced and replaced ~= prepared then DeleteOwnedPed(replaced) end
    selectorPool[key] = prepared
    -- Inactive carousel clones stay non-physical. The selected clone is
    -- grounded only after the outgoing clone has left the stage.
    SetEntityCollision(prepared, false, false)
    SetEntityVisible(prepared, false)
    ResetEntityAlpha(prepared)
    activePed = outgoingPed
    outgoingPed = nil
    return CharacterV2Result.Ok(true)
end

function CharacterV2Preview.ActivateSelector(key)
    local nextPed = selectorPool[key]
    if activeView ~= 'selector' or not nextPed or not DoesEntityExist(nextPed) then
        return CharacterV2Result.Err('preview_unavailable',
            'The selected character preview is not prepared.')
    end
    local previous = activePed
    if previous == nextPed then return CharacterV2Result.Ok(true) end
    generation = generation + 1
    local ticket = generation
    if previous and DoesEntityExist(previous) then
        local started = GetGameTimer()
        while ticket == generation and DoesEntityExist(previous) do
            local progress = math.min((GetGameTimer() - started) / 350, 1.0)
            SetEntityAlpha(previous, math.floor(255 * (1.0 - progress)), false)
            if progress >= 1.0 then break end
            Wait(0)
        end
        SetEntityVisible(previous, false)
        ResetEntityAlpha(previous)
        SetEntityCollision(previous, false, false)
    end
    activePed = nextPed
    local ground = activeSelectorGround or CharacterV2Config.preview.selector.ped
    SetEntityCoords(nextPed, ground.x, ground.y, ground.z,
        false, false, false, false)
    SetEntityHeading(nextPed,
        CharacterV2Config.preview.selector.ped.heading or 0.0)
    SetEntityCollision(nextPed, true, true)
    PlaceEntityOnGroundProperly(nextPed)
    Wait(100)
    local choices = CharacterV2Config.preview.selector.scenarios or {}
    local scenario = #choices > 0 and choices[math.random(1, #choices)] or nil
    local poseActive = false
    local poseOrigin = GetEntityCoords(nextPed)
    if scenario then
        ClearPedTasksImmediately(nextPed)
        local scenarioHash = joaat(scenario)
        Citizen.InvokeNative(0x524B54361229154F,
            nextPed, scenarioHash, -1, true, scenarioHash, -1.0, false)
        local poseDeadline = GetGameTimer() + 1500
        local activeAt
        while GetGameTimer() < poseDeadline do
            if NativeTrue(IsPedUsingAnyScenario(nextPed)) then
                poseActive = true
                activeAt = activeAt or GetGameTimer()
                if GetGameTimer() - activeAt >= 350 then break end
            end
            Wait(0)
        end
    end
    local poseSettled = GetEntityCoords(nextPed)
    print(('[feather-character-v2] selector scenario character=%s scenario=%s active=%s shift=(%.4f,%.4f,%.4f)'):format(
        tostring(key), tostring(scenario), tostring(poseActive),
        poseSettled.x - poseOrigin.x, poseSettled.y - poseOrigin.y,
        poseSettled.z - poseOrigin.z))
    SetEntityAlpha(nextPed, 0, false)
    SetEntityVisible(nextPed, true)
    local started = GetGameTimer()
    while ticket == generation and activePed == nextPed and DoesEntityExist(nextPed) do
        local progress = math.min((GetGameTimer() - started) / 350, 1.0)
        SetEntityAlpha(nextPed, math.floor(255 * progress), false)
        if progress >= 1.0 then break end
        Wait(0)
    end
    if ticket ~= generation or activePed ~= nextPed or not DoesEntityExist(nextPed) then
        return CharacterV2Result.Err('preview_replaced',
            'Selector preview changed during activation.')
    end
    ResetEntityAlpha(nextPed)
    return CharacterV2Result.Ok({ scenario = scenario })
end

function CharacterV2Preview.EvictSelector(key)
    local ped = selectorPool[key]
    if not ped then return CharacterV2Result.Ok(false) end
    if ped == activePed then
        return CharacterV2Result.Err('preview_active',
            'The active selector preview cannot be evicted.')
    end
    selectorPool[key] = nil
    DeleteOwnedPed(ped)
    return CharacterV2Result.Ok(true)
end

function CharacterV2Preview.FadeOut()
    if not activePed or not DoesEntityExist(activePed) then
        return CharacterV2Result.Ok(false)
    end
    local ped = activePed
    local ticket = generation
    local started = GetGameTimer()
    local duration = 350
    while ticket == generation and ped == activePed and DoesEntityExist(ped) do
        local progress = math.min((GetGameTimer() - started) / duration, 1.0)
        SetEntityAlpha(ped, math.floor(255 * (1.0 - progress)), false)
        if progress >= 1.0 then break end
        Wait(0)
    end
    if ticket ~= generation or ped ~= activePed or not DoesEntityExist(ped) then
        return CharacterV2Result.Err('preview_replaced',
            'Preview changed before fade-out completed.')
    end
    SetEntityVisible(ped, false)
    return CharacterV2Result.Ok(true)
end

function CharacterV2Preview.Reveal()
    if not activePed or not DoesEntityExist(activePed) then
        return CharacterV2Result.Err('preview_unavailable', 'Preview is not active.')
    end
    local ped = activePed
    local ticket = generation
    local previous = outgoingPed
    if previous and DoesEntityExist(previous) then
        local fadeStarted = GetGameTimer()
        local fadeDuration = 350
        while ticket == generation and ped == activePed
            and DoesEntityExist(previous) do
            local progress = math.min((GetGameTimer() - fadeStarted) / fadeDuration, 1.0)
            SetEntityAlpha(previous, math.floor(255 * (1.0 - progress)), false)
            if progress >= 1.0 then break end
            Wait(0)
        end
        SetEntityVisible(previous, false)
        DeleteOwnedPed(previous)
        if outgoingPed == previous then outgoingPed = nil end
    end
    SetEntityAlpha(ped, 0, false)
    SetEntityVisible(ped, true)
    local started = GetGameTimer()
    local duration = 350
    while ticket == generation and ped == activePed
        and DoesEntityExist(ped) do
        local progress = math.min((GetGameTimer() - started) / duration, 1.0)
        SetEntityAlpha(ped, math.floor(255 * progress), false)
        if progress >= 1.0 then break end
        Wait(0)
    end
    if ticket ~= generation or ped ~= activePed or not DoesEntityExist(ped) then
        return CharacterV2Result.Err('preview_replaced', 'Preview changed before reveal completed.')
    end
    ResetEntityAlpha(ped)
    return CharacterV2Result.Ok(true)
end

function CharacterV2Preview.PoseSelector()
    if activeView ~= 'selector' or not activePed or not DoesEntityExist(activePed) then
        return CharacterV2Result.Err('preview_unavailable', 'Selector preview is not active.')
    end
    local choices = CharacterV2Config.preview.selector.scenarios or {}
    if #choices == 0 then
        return CharacterV2Result.Err('scenario_unavailable', 'No selector poses are configured.')
    end
    local ped = activePed
    local ticket = generation
    local position = CharacterV2Config.preview.selector.ped
    local scenario = choices[math.random(1, #choices)]
    FreezeEntityPosition(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, false)
    SetEntityInvincible(ped, true)
    SetPedCanRagdoll(ped, false)
    ClearPedTasksImmediately(ped)
    local ground = activeSelectorGround or position
    SetEntityCoords(ped, ground.x, ground.y, ground.z,
        false, false, false, false)
    SetEntityHeading(ped, position.heading or 0.0)
    Wait(100)
    local scenarioHash = joaat(scenario)
    Citizen.InvokeNative(0x524B54361229154F,
        ped, scenarioHash, -1, true, scenarioHash, -1.0, false)
    local deadline = GetGameTimer()
        + (tonumber(CharacterV2Config.preview.selector.scenarioSettleMs) or 1800)
    local activeAt
    while ticket == generation and ped == activePed and DoesEntityExist(ped)
        and GetGameTimer() < deadline do
        if NativeTrue(IsPedUsingAnyScenario(ped)) then
            activeAt = activeAt or GetGameTimer()
            if GetGameTimer() - activeAt >= 150 then break end
        end
        Wait(0)
    end
    if ticket ~= generation or ped ~= activePed or not DoesEntityExist(ped) then
        return CharacterV2Result.Err('preview_replaced', 'Selector preview changed before its pose settled.')
    end
    local settled = GetEntityCoords(ped)
    return CharacterV2Result.Ok({ scenario = scenario,
        active = NativeTrue(IsPedUsingAnyScenario(ped)),
        groundZ = ground.z, z = settled.z })
end

function CharacterV2Preview.SetCamera(viewKey, fov)
    if activeView ~= 'creator' or not activeCamera or not DoesCamExist(activeCamera) then
        return CharacterV2Result.Err('preview_unavailable', 'Creator camera is not active.')
    end
    local view = CharacterV2Config.preview.creator.views[viewKey]
    if type(view) ~= 'table' then
        return CharacterV2Result.Err('invalid_view', 'Unknown creator camera view.')
    end
    local nextFov = tonumber(fov) or view.fov
    SetCamParams(activeCamera, view.x, view.y, view.z,
        view.rotX, view.rotY, view.rotZ, nextFov, 650, 1, 1, 2, 1, 1)
    return CharacterV2Result.Ok({ view = viewKey, fov = nextFov })
end

function CharacterV2Preview.Rotate(amount)
    if activeView ~= 'creator' or not activePed or not DoesEntityExist(activePed) then
        return CharacterV2Result.Err('preview_unavailable', 'Creator preview is not active.')
    end
    local delta = tonumber(amount) or 0.0
    rotationGeneration = rotationGeneration + 1
    local ticket = rotationGeneration
    local ped = activePed
    local start = GetEntityHeading(ped)
    local duration = 450
    CreateThread(function()
        local started = GetGameTimer()
        while ticket == rotationGeneration and ped == activePed and DoesEntityExist(ped) do
            local progress = math.min(1.0, (GetGameTimer() - started) / duration)
            -- Smoothstep avoids the abrupt start/stop of a linear heading jump.
            local eased = progress * progress * (3.0 - (2.0 * progress))
            SetEntityHeading(ped, (start + (delta * eased)) % 360.0)
            if progress >= 1.0 then break end
            Wait(0)
        end
    end)
    return CharacterV2Result.Ok({ heading = (start + delta) % 360.0, durationMs = duration })
end

function CharacterV2Preview.Current()
    if not activePed or not DoesEntityExist(activePed) then return nil end
    return { ped = activePed, camera = activeCamera }
end

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then CharacterV2Preview.Close() end
end)

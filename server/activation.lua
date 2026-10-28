local function medicalEnabled()
    local state = GetResourceState('feather-medical')
    if state == 'missing' then return false end
    if state ~= 'started' then return nil end
    local called, health = pcall(function() return exports['feather-medical']:GetHealth() end)
    if not called or type(health) ~= 'table' or type(health.enabled) ~= 'boolean' then return nil end
    if health.enabled == false then return false end
    if health.state ~= 'ready' then return nil end
    return true
end

-- The server owns selection routing, sessions, wallet provisioning and spawn
-- coordinates. Both new and existing characters activate through this path.
CharacterV2Activation = {}

local selectionRouteId
local pending = {}
local active = {}

local function Fail(code, message)
    return CharacterV2Result.Err(code, message)
end

local function Publish(name, source, accountId, characterId, sessionId)
    return exports['feather-core']:PublishEvent(name, {
        source = source, accountId = accountId,
        characterId = characterId, sessionId = sessionId
    })
end

function CharacterV2Activation.EnterSelection(source)
    if not selectionRouteId then
        local created = exports['feather-routing']:CreateRoute({
            key = 'character-v2-selection', mode = 'strict', populationEnabled = false
        })
        if type(created) ~= 'table' or not created.ok then return created end
        selectionRouteId = created.value.routeId
    end
    local joined = exports['feather-routing']:JoinRoute(selectionRouteId, source)
    if type(joined) ~= 'table' or not joined.ok then return joined end
    return CharacterV2Result.Ok({ routed = true })
end

function CharacterV2Activation.LeaveSelection(source)
    if pending[source] then return Fail('conflict', 'An activation is still pending.') end
    local left = exports['feather-routing']:LeaveRoute(source)
    if type(left) ~= 'table' or not left.ok then return left end
    return CharacterV2Result.Ok({ routed = false })
end

-- Pending spawn routes remain private through model setup, ride and collision readiness.
local function CurrentRoute(source, expected)
    local result = exports['feather-routing']:GetPlayerRoute(source)
    return result and result.ok and result.value and result.value.routeId == expected.routeId
end

local function DeleteSpawnRoute(source, expected, recover)
    if not expected or not expected.routeId then return end
    if recover and CurrentRoute(source, expected) then
        local ped = GetPlayerPed(source)
        local point = expected.position
        if ped ~= 0 and point then
            SetEntityCoords(ped, point.x, point.y, point.z, false, false, false, false)
        end
    end
    -- Delete only this activation's handle; never LeaveRoute against a newer owner.
    exports['feather-routing']:DeleteRoute(expected.routeId)
    expected.routeId = nil
end

function CharacterV2Activation.PrepareSpawn(source, context, payload)
    local expected = pending[source]
    if not expected or expected.sessionId ~= context.sessionId
        or exports['feather-core']:IsSessionCurrent(source, context.sessionId, context.characterId) ~= true then
        return Fail('session_stale', 'No current pending spawn exists.')
    end
    if expected.routeId then return CharacterV2Result.Ok({ isolated = true }) end
    if payload.town ~= nil then
        if not CharacterV2Config.debug or not CharacterV2Config.debug.selectorSpawnSequence
            or not CharacterV2Config.spawnPoints[payload.town] then
            return Fail('spawn_invalid', 'Debug destination is not authorized.')
        end
        expected.position = CharacterV2Config.spawnPoints[payload.town]
        expected.town = payload.town
    end
    local created = exports['feather-routing']:CreateRoute({
        key = 'character-arrival-' .. tostring(source) .. '-' .. tostring(context.sessionId),
        mode = 'relaxed', populationEnabled = false
    })
    if not created or not created.ok then return created end
    expected.routeId = created.value.routeId
    local joined = exports['feather-routing']:JoinRoute(expected.routeId, source)
    if not joined or not joined.ok then DeleteSpawnRoute(source, expected); return joined end
    SetTimeout(180000, function()
        if pending[source] ~= expected or not expected.routeId then return end
        TriggerClientEvent('feather-character:spawnExpired', source, expected.sessionId)
        -- Return to selection privately before deleting the expired arrival route.
        if CurrentRoute(source, expected) then CharacterV2Activation.EnterSelection(source) end
        DeleteSpawnRoute(source, expected)
        if pending[source] == expected then CharacterV2Activation.Abort(source) end
    end)
    return CharacterV2Result.Ok({ isolated = true })
end

local function Occupied(source, point)
    for _, other in ipairs(GetPlayers()) do
        other = tonumber(other)
        if other ~= source and GetPlayerRoutingBucket(other) == 0 then
            local ped = GetPlayerPed(other)
            if ped ~= 0 then
                local pos = GetEntityCoords(ped)
                if (pos.x-point.x)^2 + (pos.y-point.y)^2 + (pos.z-point.z)^2 < 9 then return true end
            end
        end
    end
    for other, entry in pairs(pending) do
        if other ~= source and entry.reveal then
            local pos = entry.reveal
            if (pos.x-point.x)^2 + (pos.y-point.y)^2 + (pos.z-point.z)^2 < 9 then return true end
        end
    end
    return false
end

function CharacterV2Activation.PrepareReveal(source, context, payload)
    local expected = pending[source]
    if not expected or expected.sessionId ~= context.sessionId or not expected.routeId
        or not CurrentRoute(source, expected)
        or exports['feather-core']:IsSessionCurrent(source, context.sessionId, context.characterId) ~= true then
        return Fail('session_stale', 'The private spawn route is no longer current.')
    end
    if expected.reveal then return CharacterV2Result.Ok({ position = expected.reveal }) end
    -- Use server-configured coordinates only. If occupied, wait privately and fail boundedly.
    local point = expected.position
    local town = CharacterV2Config.arrivals.towns[expected.town]
    if payload.arrived and town and not Occupied(source, town.destination) then
        point = town.destination
    end
    if Occupied(source, point) then return Fail('spawn_occupied', 'The spawn position is occupied.') end
    expected.reveal = { x = point.x, y = point.y, z = point.z, heading = point.heading }
    return CharacterV2Result.Ok({ position = expected.reveal })
end

local function EndSession(source, sessionId, reason)
    local leaving = exports['feather-core']:BeginSessionLeaving(source, reason)
    if type(leaving) == 'table' and leaving.ok and leaving.value.sessionId == sessionId then
        exports['feather-core']:CompleteSessionLeaving(source, sessionId)
    end
    active[source] = nil
end

function CharacterV2Activation.Activate(source, accountId, characterId)
    if pending[source] then return Fail('conflict', 'An activation is already pending.') end
    local profile = CharacterV2Profiles.Get(accountId, characterId)
    if not profile.ok then return profile end
    local appearance = CharacterV2Profiles.GetAppearance(accountId, characterId)
    if not appearance.ok then return appearance end
    local spawn = CharacterV2Profiles.GetSpawnState(accountId, characterId)
    if not spawn.ok then return spawn end
    local point = CharacterV2Config.spawnPoints[spawn.value.spawnPointId]
    local position = spawn.value.mode == 'last_position' and spawn.value.position or point
    if type(position) ~= 'table' then return Fail('spawn_invalid', 'The saved spawn point is unavailable.') end
    local medical

    local economy = exports['feather-economy']:AwaitReady(30000)
    if type(economy) ~= 'table' or not economy.ok then
        return Fail('economy_unavailable', 'Economy is not ready.')
    end
    local account = exports['feather-core']:GetAccountContext(source)
    if type(account) ~= 'table' or not account.ok or account.value.accountId ~= accountId then
        return Fail('session_stale', 'Account changed during activation.')
    end
    local session = exports['feather-core']:ActivateSession(source, characterId)
    if type(session) ~= 'table' or not session.ok then return session end
    local sessionId = session.value.sessionId
    active[source] = { accountId = accountId, characterId = characterId, sessionId = sessionId }
    local wallets = exports['feather-economy']:EnsureCharacterWallets({ characterId = characterId })
    if type(wallets) ~= 'table' or not wallets.ok then
        EndSession(source, sessionId, 'wallet_provision_failed')
        return Fail('wallet_provision_failed', 'Character wallets could not be provisioned.')
    end
    if exports['feather-core']:IsSessionCurrent(source, sessionId, characterId) ~= true then
        return Fail('session_stale', 'Character session changed during activation.')
    end
    local medicalEnabledNow = medicalEnabled()
    if medicalEnabledNow == nil then
        EndSession(source, sessionId, 'medical_unavailable')
        return Fail('medical_unavailable', 'Medical is installed but unavailable.')
    end
    if medicalEnabledNow then
        local called, result = pcall(function() return exports['feather-medical']:PrepareCharacter(characterId, source, sessionId) end)
        if not called or type(result) ~= 'table' or not result.ok then
            local detail = not called and tostring(result) or type(result) == 'table' and tostring(result.code) or 'invalid_result'
            print('[feather-character] Medical preparation failed: ' .. detail)
            EndSession(source, sessionId, 'medical_provision_failed')
            return Fail('medical_unavailable', 'Medical enrollment or restoration is unavailable (' .. (called and type(result) == 'table' and tostring(result.code) or 'export_failed') .. ').')
        end
        medical = result.value
    end
    if exports['feather-core']:IsSessionCurrent(source, sessionId, characterId) ~= true then
        return Fail('session_stale', 'Character session changed during Medical restoration.')
    end
    local announced = Publish('character.ready.v1', source, accountId, characterId, sessionId)
    if type(announced) ~= 'table' or not announced.ok then
        EndSession(source, sessionId, 'ready_event_failed')
        return Fail('event_failed', 'Character readiness could not be announced.')
    end
    pending[source] = { accountId = accountId, characterId = characterId, sessionId = sessionId,
        position = position, town = spawn.value.spawnPointId }
    return CharacterV2Result.Ok({
        session = session.value, profile = profile.value, appearance = appearance.value, medical = medical,
        spawn = { characterId = characterId, sessionId = sessionId,
            mode = spawn.value.mode, spawnPointId = spawn.value.spawnPointId,
            position = { x = position.x, y = position.y, z = position.z, heading = position.heading } }
    })
end

exports('GetMedicalReadySession', function(source)
    local key = active[source] and source or active[tonumber(source)] and tonumber(source) or tostring(source)
    local expected = active[key]
    if pending[key] or not expected
        or exports['feather-core']:IsSessionCurrent(source, expected.sessionId, expected.characterId) ~= true then
        return {ok = false, code = 'not_ready'}
    end
    return {ok = true, value = {characterId = expected.characterId, sessionId = expected.sessionId}}
end)

exports('GetMedicalRecoveryDestination', function(key)
    if GetInvokingResource() ~= 'feather-medical' then return {ok = false, code = 'forbidden'} end
    key = key or 'valentine'
    local point = CharacterV2Config.spawnPoints[key]
    if not point then return {ok = false, code = 'spawn_invalid'} end
    return {ok = true, value = {id = key, x = point.x, y = point.y, z = point.z, heading = point.heading}}
end)

function CharacterV2Activation.CompleteSpawn(source, context)
    local expected = pending[source]
    if not expected or expected.sessionId ~= context.sessionId
        or expected.characterId ~= context.characterId
        or exports['feather-core']:IsSessionCurrent(source, context.sessionId, context.characterId) ~= true then
        return Fail('session_stale', 'No current pending spawn exists.')
    end
    if not expected.reveal or not CurrentRoute(source, expected) then
        return Fail('spawn_not_ready', 'Private spawn placement is required.')
    end
    local ped = GetPlayerPed(source)
    local coords = ped ~= 0 and GetEntityCoords(ped)
    local point = expected.reveal
    if not coords or (coords.x-point.x)^2 + (coords.y-point.y)^2 + (coords.z-point.z)^2 > 25
        or Occupied(source, point) then
        return Fail('spawn_not_ready', 'Authorized reveal position is not ready.')
    end
    local left = exports['feather-routing']:LeaveRoute(source)
    if not left or not left.ok then return left end
    DeleteSpawnRoute(source, expected)
    pending[source] = nil
    local announced = Publish('character.spawned.v1', source, context.accountId,
        context.characterId, context.sessionId)
    if type(announced) ~= 'table' or not announced.ok then
        return Fail('event_failed', 'Character spawn could not be announced.')
    end
    return CharacterV2Result.Ok({ spawned = true, sessionId = context.sessionId })
end

function CharacterV2Activation.Abort(source, sessionId)
    local expected = pending[source]
    if not expected then return CharacterV2Result.Ok({ aborted = false }) end
    if sessionId and sessionId ~= expected.sessionId then return Fail('session_stale', 'Activation changed.') end
    if expected.routeId and CurrentRoute(source, expected) then
        local selected = CharacterV2Activation.EnterSelection(source)
        if not selected or not selected.ok then return selected end
    end
    DeleteSpawnRoute(source, expected)
    pending[source] = nil
    local leaving = exports['feather-core']:BeginSessionLeaving(source, 'activation_failed')
    if type(leaving) ~= 'table' or not leaving.ok then return leaving end
    Publish('character.leaving.v1', source, expected.accountId,
        expected.characterId, expected.sessionId)
    local completed = exports['feather-core']:CompleteSessionLeaving(source, expected.sessionId)
    if type(completed) ~= 'table' or not completed.ok then return completed end
    active[source] = nil
    Publish('character.left.v1', source, expected.accountId,
        expected.characterId, expected.sessionId)
    return CharacterV2Result.Ok({ aborted = true })
end

function CharacterV2Activation.Logout(source, context, position, reason)
    if exports['feather-core']:IsSessionCurrent(source, context.sessionId, context.characterId) ~= true then
        return Fail('session_stale', 'The character session is no longer current.')
    end
    if pending[source] then return Fail('conflict', 'Finish or abort activation before logout.') end
    local saved = CharacterV2Profiles.UpdatePosition(context.accountId, context.characterId, position)
    if not saved.ok then return saved end
    if pending[source] then return Fail('conflict', 'Finish or abort activation before logout.') end
    local leaving = exports['feather-core']:BeginSessionLeaving(source, reason or 'logout')
    if type(leaving) ~= 'table' or not leaving.ok then return leaving end
    Publish('character.leaving.v1', source, context.accountId, context.characterId, context.sessionId)
    local completed = exports['feather-core']:CompleteSessionLeaving(source, context.sessionId)
    if type(completed) ~= 'table' or not completed.ok then return completed end
    active[source] = nil
    Publish('character.left.v1', source, context.accountId, context.characterId, context.sessionId)
    return CharacterV2Result.Ok({ left = true, sessionId = context.sessionId })
end

function CharacterV2Activation.Quit(source, context, position)
    local loggedOut = CharacterV2Activation.Logout(source, context, position, 'save_quit')
    if not loggedOut.ok then return loggedOut end
    CreateThread(function()
        Wait(250)
        DropPlayer(source, 'Character saved. Goodbye.')
    end)
    return CharacterV2Result.Ok({ saved = true, disconnecting = true })
end

AddEventHandler('playerDropped', function()
    DeleteSpawnRoute(source, pending[source])
    pending[source] = nil
    active[source] = nil
end)
AddEventHandler('onResourceStop', function(resource)
    if resource == 'feather-routing' then
        selectionRouteId = nil
        for playerSource, expected in pairs(pending) do
            TriggerClientEvent('feather-character:spawnExpired', playerSource, expected.sessionId)
            local ped = GetPlayerPed(playerSource)
            if ped ~= 0 then SetEntityCoords(ped, expected.position.x, expected.position.y, expected.position.z, false, false, false, false) end
            expected.routeId = nil
        end
    end
    if resource ~= GetCurrentResourceName() then return end
    for playerSource, expected in pairs(pending) do DeleteSpawnRoute(playerSource, expected, true) end
    for playerSource, context in pairs(active) do
        Publish('character.leaving.v1', playerSource, context.accountId,
            context.characterId, context.sessionId)
        EndSession(playerSource, context.sessionId, 'character_resource_stopped')
        Publish('character.left.v1', playerSource, context.accountId,
            context.characterId, context.sessionId)
        pending[playerSource] = nil
    end
end)

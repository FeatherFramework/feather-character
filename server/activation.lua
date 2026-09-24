-- The server owns selection routing, sessions, wallet provisioning and spawn
-- coordinates. Both new and existing characters activate through this path.
CharacterV2Activation = {}

local selectionRouteId
local pending = {}

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
    local left = exports['feather-routing']:LeaveRoute(source)
    if type(left) ~= 'table' or not left.ok then return left end
    return CharacterV2Result.Ok({ routed = false })
end

local function EndSession(source, sessionId, reason)
    local leaving = exports['feather-core']:BeginSessionLeaving(source, reason)
    if type(leaving) == 'table' and leaving.ok and leaving.value.sessionId == sessionId then
        exports['feather-core']:CompleteSessionLeaving(source, sessionId)
    end
end

function CharacterV2Activation.Activate(source, accountId, characterId)
    local profile = CharacterV2Profiles.Get(accountId, characterId)
    if not profile.ok then return profile end
    local appearance = CharacterV2Profiles.GetAppearance(accountId, characterId)
    if not appearance.ok then return appearance end
    local spawn = CharacterV2Profiles.GetSpawnState(accountId, characterId)
    if not spawn.ok then return spawn end
    local point = CharacterV2Config.spawnPoints[spawn.value.spawnPointId]
    local position = spawn.value.mode == 'last_position' and spawn.value.position or point
    if type(position) ~= 'table' then return Fail('spawn_invalid', 'The saved spawn point is unavailable.') end

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
    local wallets = exports['feather-economy']:EnsureCharacterWallets({ characterId = characterId })
    if type(wallets) ~= 'table' or not wallets.ok then
        EndSession(source, sessionId, 'wallet_provision_failed')
        return Fail('wallet_provision_failed', 'Character wallets could not be provisioned.')
    end
    if exports['feather-core']:IsSessionCurrent(source, sessionId, characterId) ~= true then
        return Fail('session_stale', 'Character session changed during activation.')
    end
    local announced = Publish('character.ready.v1', source, accountId, characterId, sessionId)
    if type(announced) ~= 'table' or not announced.ok then
        EndSession(source, sessionId, 'ready_event_failed')
        return Fail('event_failed', 'Character readiness could not be announced.')
    end
    pending[source] = { accountId = accountId, characterId = characterId, sessionId = sessionId }
    return CharacterV2Result.Ok({
        session = session.value, profile = profile.value, appearance = appearance.value,
        spawn = { characterId = characterId, sessionId = sessionId,
            mode = spawn.value.mode, spawnPointId = spawn.value.spawnPointId,
            position = { x = position.x, y = position.y, z = position.z, heading = position.heading } }
    })
end

function CharacterV2Activation.CompleteSpawn(source, context)
    local expected = pending[source]
    if not expected or expected.sessionId ~= context.sessionId
        or expected.characterId ~= context.characterId
        or exports['feather-core']:IsSessionCurrent(source, context.sessionId, context.characterId) ~= true then
        return Fail('session_stale', 'No current pending spawn exists.')
    end
    pending[source] = nil
    local announced = Publish('character.spawned.v1', source, context.accountId,
        context.characterId, context.sessionId)
    if type(announced) ~= 'table' or not announced.ok then
        return Fail('event_failed', 'Character spawn could not be announced.')
    end
    return CharacterV2Result.Ok({ spawned = true, sessionId = context.sessionId })
end

function CharacterV2Activation.Abort(source)
    local expected = pending[source]
    if not expected then return Fail('not_found', 'No pending activation exists.') end
    pending[source] = nil
    local leaving = exports['feather-core']:BeginSessionLeaving(source, 'activation_failed')
    if type(leaving) ~= 'table' or not leaving.ok then return leaving end
    Publish('character.leaving.v1', source, expected.accountId,
        expected.characterId, expected.sessionId)
    local completed = exports['feather-core']:CompleteSessionLeaving(source, expected.sessionId)
    if type(completed) ~= 'table' or not completed.ok then return completed end
    Publish('character.left.v1', source, expected.accountId,
        expected.characterId, expected.sessionId)
    return CharacterV2Result.Ok({ aborted = true })
end

function CharacterV2Activation.Logout(source, context, position, reason)
    if exports['feather-core']:IsSessionCurrent(source, context.sessionId, context.characterId) ~= true then
        return Fail('session_stale', 'The character session is no longer current.')
    end
    local saved = CharacterV2Profiles.UpdatePosition(context.accountId, context.characterId, position)
    if not saved.ok then return saved end
    pending[source] = nil
    local leaving = exports['feather-core']:BeginSessionLeaving(source, reason or 'logout')
    if type(leaving) ~= 'table' or not leaving.ok then return leaving end
    Publish('character.leaving.v1', source, context.accountId, context.characterId, context.sessionId)
    local completed = exports['feather-core']:CompleteSessionLeaving(source, context.sessionId)
    if type(completed) ~= 'table' or not completed.ok then return completed end
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

AddEventHandler('playerDropped', function() pending[source] = nil end)
AddEventHandler('onResourceStop', function(resource)
    if resource == 'feather-routing' then selectionRouteId = nil end
end)

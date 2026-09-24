local health = { state = 'starting', phase = 'migration', contract = 1 }

local function Empty(payload)
    return type(payload) == 'table' and next(payload) == nil, 'No payload fields are accepted.'
end

local function Character(payload)
    return type(payload) == 'table' and type(payload.characterId) == 'string',
        'characterId is required.'
end

local function Position(payload)
    return type(payload) == 'table' and type(payload.position) == 'table',
        'position is required.'
end

local function Account(context)
    return type(context) == 'table' and type(context.accountId) == 'string'
end

local function Guard(stage, fn, ...)
    local called, result = pcall(fn, ...)
    if not called then
        print(('[feather-character-v2] %s failed: %s'):format(stage, tostring(result)))
        return CharacterV2Result.Err('database_unavailable', 'Character storage is unavailable.')
    end
    return result
end

local function Route(name, callback, validate, bytes, characterRequired)
    local result = exports['feather-core']:RegisterRpc(name, callback, {
        contract = 1, direction = 'client_to_server', requireCharacter = characterRequired == true,
        windowMs = 5000, maxCalls = 8, maxPayloadBytes = bytes or 256,
        maxDepth = 12, maxNodes = 2048, validatePayload = validate
    })
    if type(result) ~= 'table' or not result.ok then
        error(('RPC registration %s failed: %s'):format(name,
            type(result) == 'table' and tostring(result.code) or 'invalid_result'))
    end
end

local function Start()
    local oldState = GetResourceState('feather-character')
    if GetCurrentResourceName() ~= 'feather-character'
        and (oldState == 'started' or oldState == 'starting') then
        error('Stop feather-character before starting feather-character-v2; both own character.*.v1 routes.')
    end
    local migration = CharacterV2Migration.Run()
    if not migration.ok then error(('Migration failed: %s'):format(migration.code)) end
    health.phase = 'registering'
    for _, name in ipairs({ 'character.ready.v1', 'character.spawned.v1',
        'character.leaving.v1', 'character.left.v1' }) do
        local event = exports['feather-core']:DeclareEvent(name, {
            contract = 1, maxPayloadBytes = 1024, maxDepth = 4, maxNodes = 24
        })
        if type(event) ~= 'table' or not event.ok then
            error(('Event registration %s failed'):format(name))
        end
    end
    Route('character.list.v1', function(_, _, context)
        if not Account(context) then return CharacterV2Result.Err('unauthenticated', 'Account required.') end
        return Guard('list', CharacterV2Profiles.List, context.accountId)
    end, Empty, 64)
    Route('character.get.v1', function(payload, _, context)
        if not Account(context) then return CharacterV2Result.Err('unauthenticated', 'Account required.') end
        return Guard('get', CharacterV2Profiles.Get, context.accountId, payload.characterId)
    end, Character, 128)
    Route('character.appearance.get.v1', function(payload, _, context)
        if not Account(context) then return CharacterV2Result.Err('unauthenticated', 'Account required.') end
        return Guard('appearance get', CharacterV2Profiles.GetAppearance,
            context.accountId, payload.characterId)
    end, Character, 128)
    Route('character.create.v1', function(payload, _, context)
        if not Account(context) then return CharacterV2Result.Err('unauthenticated', 'Account required.') end
        return Guard('create', CharacterV2Profiles.Create,
            context.accountId, payload.idempotencyKey, payload.character)
    end, function(payload)
        return type(payload) == 'table' and type(payload.idempotencyKey) == 'string'
            and type(payload.character) == 'table', 'idempotencyKey and character are required.'
    -- Creation carries the complete bounded appearance document. Keep this
    -- route aligned with that document ceiling plus its small profile envelope.
    end, CharacterV2Config.appearance.maxDocumentBytes + 4096)
    Route('character.delete.v1', function(payload, _, context)
        if not Account(context) then
            return CharacterV2Result.Err('unauthenticated', 'Account required.')
        end
        return Guard('delete', CharacterV2Profiles.Delete,
            context.accountId, payload.characterId)
    end, Character, 128)
    Route('character.selection.route.enter.v1', function(_, source, context)
        if not Account(context) then return CharacterV2Result.Err('unauthenticated', 'Account required.') end
        return CharacterV2Activation.EnterSelection(source)
    end, Empty, 64)
    Route('character.selection.route.leave.v1', function(_, source)
        return CharacterV2Activation.LeaveSelection(source)
    end, Empty, 64)
    Route('character.activate.v1', function(payload, source, context)
        if not Account(context) then return CharacterV2Result.Err('unauthenticated', 'Account required.') end
        return CharacterV2Activation.Activate(source, context.accountId, payload.characterId)
    end, Character, 128)
    Route('character.spawn.complete.v1', function(_, source, context)
        return CharacterV2Activation.CompleteSpawn(source, context)
    end, Empty, 64, true)
    Route('character.activation.abort.v1', function(_, source)
        return CharacterV2Activation.Abort(source)
    end, Empty, 64)
    Route('character.position.update.v1', function(payload, source, context)
        if exports['feather-core']:IsSessionCurrent(source, context.sessionId, context.characterId) ~= true then
            return CharacterV2Result.Err('session_stale', 'Character session changed.')
        end
        return CharacterV2Profiles.UpdatePosition(context.accountId, context.characterId, payload.position)
    end, Position, 256, true)
    Route('character.logout.v1', function(payload, source, accountContext)
        local session = exports['feather-core']:GetSessionContext(source)
        if type(session) ~= 'table' or not session.ok then
            return CharacterV2Result.Err('character_required', 'A current character is required.')
        end
        if Account(accountContext) and session.value.accountId ~= accountContext.accountId then
            return CharacterV2Result.Err('session_stale', 'Account changed.')
        end
        return CharacterV2Activation.Logout(source, session.value, payload.position)
    end, Position, 256)
    Route('character.quit.v1', function(payload, source, accountContext)
        local session = exports['feather-core']:GetSessionContext(source)
        if type(session) ~= 'table' or not session.ok then
            return CharacterV2Result.Err('character_required', 'A current character is required.')
        end
        if Account(accountContext) and session.value.accountId ~= accountContext.accountId then
            return CharacterV2Result.Err('session_stale', 'Account changed.')
        end
        return CharacterV2Activation.Quit(source, session.value, payload.position)
    end, Position, 256)
    local provider = {
        GetIdentity = function(characterId)
            local row = MySQL.single.await([[
                SELECT `character_id`, `account_id`, `status` FROM `fc2_characters`
                WHERE `character_id` = ? LIMIT 1
            ]], { characterId })
            if not row then return CharacterV2Result.Err('not_found', 'Character not found.') end
            return CharacterV2Result.Ok({ characterId = row.character_id,
                accountId = row.account_id, status = row.status })
        end,
        GetProfile = function(characterId)
            local row = MySQL.single.await([[
                SELECT `account_id` FROM `fc2_characters`
                WHERE `character_id` = ? AND `status` = 'active' LIMIT 1
            ]], { characterId })
            if not row then return CharacterV2Result.Err('not_found', 'Character not found.') end
            return CharacterV2Profiles.Get(row.account_id, characterId)
        end,
        ListProfiles = CharacterV2Profiles.List,
        OwnsCharacter = function(accountId, characterId)
            local result = CharacterV2Profiles.Get(accountId, characterId)
            if result.ok then return CharacterV2Result.Ok({ owned = true }) end
            if result.code == 'not_found' then return CharacterV2Result.Ok({ owned = false }) end
            return result
        end,
        GetCurrentProfile = function(source)
            local session = exports['feather-core']:GetSessionContext(source)
            if type(session) ~= 'table' or not session.ok then
                return CharacterV2Result.Err('character_required', 'Current character required.')
            end
            return CharacterV2Profiles.Get(session.value.accountId, session.value.characterId)
        end
    }
    local registered = exports['feather-core']:RegisterProvider(
        'character-profile', GetCurrentResourceName(), provider, {
            contract = 1, capabilities = {
                profiles = 1, ownership = 1, currentProfile = 1, identity = 1
            },
            default = true, health = function() return CharacterV2Result.Ok({ state = health.state }) end
        })
    if type(registered) ~= 'table' or not registered.ok then
        error('Character profile provider registration failed.')
    end
    health.state, health.phase = 'ready', 'first_playable'
    print('[feather-character-v2] first-playable server contracts ready')
end

exports('GetHealth', function() return CharacterV2Result.Ok(health) end)
exports('GetCapabilities', function()
    return CharacterV2Result.Ok({ resource = GetCurrentResourceName(), state = health.state,
        contract = 1, features = health.state == 'ready' and {
            profiles = 1, creation = 1, activation = 1, spawn = 1
        } or {} })
end)

RegisterCommand('CharacterV2Status', function(source)
    if source ~= 0 then return end
    print(('[feather-character-v2] state=%s phase=%s contract=%s failure=%s'):format(
        tostring(health.state), tostring(health.phase), tostring(health.contract),
        tostring(health.failure or 'none')))
end, true)

CreateThread(function()
    local ok, failure = xpcall(Start, debug.traceback)
    if not ok then
        health.state, health.phase = 'failed', 'startup_failed'
        health.failure = tostring(failure)
        print(('[feather-character-v2] startup failed: %s'):format(tostring(failure)))
    end
end)

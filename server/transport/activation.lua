CharacterActivationTransport = {}

local installed = false

local function CharacterPayload(payload)
    if type(payload) ~= 'table' or type(payload.characterId) ~= 'string' then
        return false, 'characterId is required.'
    end
    for key in pairs(payload) do
        if key ~= 'characterId' then return false, 'Only characterId is accepted.' end
    end
    return true
end

local function EmptyPayload(payload)
    return type(payload) == 'table' and next(payload) == nil, 'This route does not accept payload fields.'
end

local function PositionPayload(payload)
    if type(payload) ~= 'table' or type(payload.position) ~= 'table' then
        return false, 'position is required.'
    end
    for key in pairs(payload) do
        if key ~= 'position' then return false, 'Only position is accepted.' end
    end
    for key in pairs(payload.position) do
        if key ~= 'x' and key ~= 'y' and key ~= 'z' and key ~= 'heading' then
            return false, 'Unknown position field.'
        end
    end
    return true
end

function CharacterActivationTransport.Install()
    if installed then return CharacterResults.Err('conflict', 'Character activation transport is already installed.') end
    local eventNames = {
        'character.ready.v1', 'character.spawned.v1', 'character.leaving.v1', 'character.left.v1'
    }
    for _, name in ipairs(eventNames) do
        local declared = exports['feather-core']:DeclareEvent(name, {
            contract = 1, maxPayloadBytes = 1024, maxDepth = 4, maxNodes = 24
        })
        if type(declared) ~= 'table' or not declared.ok then
            return CharacterResults.Err('registration_failed', 'A Character lifecycle event could not be declared.', {
                event = name, code = type(declared) == 'table' and declared.code or 'invalid_result'
            })
        end
    end

    local routes = {
        exports['feather-core']:RegisterRpc('character.activate.v1', function(payload, source, context)
            if not context or not context.accountId then
                return CharacterResults.Err('unauthenticated', 'A connected account is required.')
            end
            return CharacterActivation.Activate(source, context.accountId, payload.characterId)
        end, {
            contract = 1, direction = 'client_to_server', requireCharacter = false,
            windowMs = 5000, maxCalls = 3, maxPayloadBytes = 128, maxDepth = 2, maxNodes = 4,
            validatePayload = CharacterPayload
        }),
        exports['feather-core']:RegisterRpc('character.spawn.complete.v1', function(_, source, context)
            return CharacterActivation.CompleteSpawn(source, context)
        end, {
            contract = 1, direction = 'client_to_server', requireCharacter = true,
            windowMs = 5000, maxCalls = 3, maxPayloadBytes = 64, maxDepth = 2, maxNodes = 4,
            validatePayload = EmptyPayload
        }),
        exports['feather-core']:RegisterRpc('character.position.update.v1', function(payload, source, context)
            if not exports['feather-core']:IsSessionCurrent(source, context.sessionId, context.characterId) then
                return CharacterResults.Err('session_stale', 'The character session is no longer current.')
            end
            return CharacterSpawn.UpdatePosition(context.characterId, payload.position)
        end, {
            contract = 1, direction = 'client_to_server', requireCharacter = true,
            windowMs = 10000, maxCalls = 4, maxPayloadBytes = 256, maxDepth = 3, maxNodes = 10,
            validatePayload = PositionPayload
        }),
        exports['feather-core']:RegisterRpc('character.logout.v1', function(payload, source, accountContext)
            local session = exports['feather-core']:GetSessionContext(source)
            if type(session) ~= 'table' or not session.ok then
                return CharacterResults.Err('character_required', 'A current character session is required.')
            end
            local context = session.value
            if accountContext and accountContext.accountId
                and context.accountId ~= accountContext.accountId then
                return CharacterResults.Err('session_stale', 'The character session account is no longer current.')
            end
            return CharacterActivation.Logout(source, context, payload.position)
        end, {
            contract = 1, direction = 'client_to_server', requireCharacter = false,
            windowMs = 10000, maxCalls = 2, maxPayloadBytes = 256, maxDepth = 3, maxNodes = 10,
            validatePayload = PositionPayload
        })
    }
    for _, result in ipairs(routes) do
        if type(result) ~= 'table' or not result.ok then
            return CharacterResults.Err('registration_failed', 'A Character activation route could not be registered.', {
                code = type(result) == 'table' and result.code or 'invalid_result'
            })
        end
    end
    installed = true
    return CharacterResults.Ok({ routes = #routes, events = #eventNames })
end

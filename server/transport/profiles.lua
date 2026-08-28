CharacterProfileTransport = {}

local installed = false

local function EmptyPayload(payload)
    return type(payload) == 'table' and next(payload) == nil, 'This route does not accept payload fields.'
end

local function CharacterIdPayload(payload)
    if type(payload) ~= 'table' or type(payload.characterId) ~= 'string' then
        return false, 'characterId is required.'
    end
    for key in pairs(payload) do
        if key ~= 'characterId' then return false, 'Only characterId is accepted.' end
    end
    return true
end

local function CreatePayload(payload)
    if type(payload) ~= 'table' or type(payload.idempotencyKey) ~= 'string' or type(payload.character) ~= 'table' then
        return false, 'idempotencyKey and character are required.'
    end
    for key in pairs(payload) do
        if key ~= 'idempotencyKey' and key ~= 'character' then return false, 'Unknown creation field.' end
    end
    return true
end

local function DeletePayload(payload)
    if type(payload) ~= 'table' or type(payload.characterId) ~= 'string'
        or payload.confirmed ~= true then
        return false, 'characterId and confirmed=true are required.'
    end
    for key in pairs(payload) do
        if key ~= 'characterId' and key ~= 'confirmed' then
            return false, 'Unknown deletion field.'
        end
    end
    return true
end

local provider = {
    GetProfile = function(characterId)
        return CharacterProfiles.Get(characterId)
    end,
    ListProfiles = function(accountId)
        return CharacterProfiles.List(accountId)
    end,
    OwnsCharacter = function(accountId, characterId)
        return CharacterProfiles.Owns(accountId, characterId)
    end,
    GetCurrentProfile = function(source)
        local session = exports['feather-core']:GetSessionContext(source)
        if type(session) ~= 'table' or session.ok ~= true then
            return CharacterResults.Err('character_required', 'A current character session is required.')
        end
        return CharacterProfiles.Get(session.value.characterId)
    end
}

function CharacterProfileTransport.Install()
    if installed then return CharacterResults.Err('conflict', 'Character profile transport is already installed.') end

    local deletedEvent = exports['feather-core']:DeclareEvent('character.deleted.v1', {
        contract = 1, maxPayloadBytes = 512, maxDepth = 3, maxNodes = 12
    })
    if type(deletedEvent) ~= 'table' or deletedEvent.ok ~= true then
        return CharacterResults.Err('registration_failed', 'The Character deletion event could not be declared.', {
            code = type(deletedEvent) == 'table' and deletedEvent.code or 'invalid_result'
        })
    end

    local registrations = {
        exports['feather-core']:RegisterRpc('character.list.v1', function(_, _, context)
            if not context or not context.accountId then
                return CharacterResults.Err('unauthenticated', 'A connected account is required.')
            end
            return CharacterProfiles.List(context.accountId)
        end, {
            contract = 1, direction = 'client_to_server', requireCharacter = false,
            windowMs = 2000, maxCalls = 4, maxPayloadBytes = 64, maxDepth = 2, maxNodes = 4,
            validatePayload = EmptyPayload
        }),
        exports['feather-core']:RegisterRpc('character.get.v1', function(payload, _, context)
            if not context or not context.accountId then
                return CharacterResults.Err('unauthenticated', 'A connected account is required.')
            end
            local ownership = CharacterProfiles.Owns(context.accountId, payload.characterId)
            if not ownership.ok then return ownership end
            if not ownership.value.owned then return CharacterResults.Err('not_found', 'Character was not found.') end
            return CharacterProfiles.Get(payload.characterId)
        end, {
            contract = 1, direction = 'client_to_server', requireCharacter = false,
            windowMs = 2000, maxCalls = 8, maxPayloadBytes = 128, maxDepth = 2, maxNodes = 4,
            validatePayload = CharacterIdPayload
        }),
        exports['feather-core']:RegisterRpc('character.create.v1', function(payload, _, context)
            if not context or not context.accountId then
                return CharacterResults.Err('unauthenticated', 'A connected account is required.')
            end
            return CharacterProfiles.Create(context.accountId, payload.character, payload.idempotencyKey)
        end, {
            contract = 1, direction = 'client_to_server', requireCharacter = false,
            windowMs = 10000, maxCalls = 2, maxPayloadBytes = 70000, maxDepth = 12, maxNodes = 2048,
            validatePayload = CreatePayload
        }),
        exports['feather-core']:RegisterRpc('character.delete.v1', function(payload, source, context)
            if not context or not context.accountId then
                return CharacterResults.Err('unauthenticated', 'A connected account is required.')
            end
            local session = exports['feather-core']:GetSessionContext(source)
            local activeCharacterId = type(session) == 'table' and session.ok == true
                and session.value.characterId or nil
            local deleted = CharacterProfiles.SoftDelete(context.accountId, payload.characterId,
                payload.confirmed, activeCharacterId)
            if not deleted.ok then return deleted end
            local published = exports['feather-core']:PublishEvent('character.deleted.v1', {
                source = source,
                accountId = context.accountId,
                characterId = payload.characterId
            })
            if type(published) ~= 'table' or published.ok ~= true then
                return CharacterResults.Err('post_commit_event_failed',
                    'Character was deleted, but its lifecycle event could not be published.', {
                        characterId = payload.characterId
                    })
            end
            return deleted
        end, {
            contract = 1, direction = 'client_to_server', requireCharacter = false,
            windowMs = 10000, maxCalls = 2, maxPayloadBytes = 256, maxDepth = 2, maxNodes = 6,
            validatePayload = DeletePayload
        })
    }

    for _, result in ipairs(registrations) do
        if type(result) ~= 'table' or result.ok ~= true then
            return CharacterResults.Err('registration_failed', 'A Character RPC route could not be registered.', {
                code = type(result) == 'table' and result.code or 'invalid_result'
            })
        end
    end

    local providerResult = exports['feather-core']:RegisterProvider('character-profile', 'feather-character', provider, {
        contract = 1,
        capabilities = { profiles = 1, ownership = 1, currentProfile = 1 },
        default = true,
        health = function()
            local health = CharacterFoundation.GetHealth()
            if health.state ~= 'ready' and health.state ~= 'starting' then
                return CharacterResults.Err('provider_unavailable', 'Character profile provider is not ready.')
            end
            return CharacterResults.Ok({ state = health.state })
        end
    })
    if type(providerResult) ~= 'table' or providerResult.ok ~= true then
        return CharacterResults.Err('registration_failed', 'Character profile provider could not be registered.', {
            code = type(providerResult) == 'table' and providerResult.code or 'invalid_result'
        })
    end

    installed = true
    return CharacterResults.Ok({ routes = #registrations, provider = providerResult.value })
end

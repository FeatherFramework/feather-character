CharacterAppearanceTransport = {}

local installed = false

local function GetPayload(payload)
    if type(payload) ~= 'table' or type(payload.characterId) ~= 'string' then
        return false, 'characterId is required.'
    end
    for key in pairs(payload) do
        if key ~= 'characterId' then return false, 'Only characterId is accepted.' end
    end
    return true
end

local function UpdatePayload(payload)
    if type(payload) ~= 'table' or type(payload.expectedRevision) ~= 'number'
        or type(payload.document) ~= 'table' then
        return false, 'expectedRevision and document are required.'
    end
    for key in pairs(payload) do
        if key ~= 'expectedRevision' and key ~= 'document' then return false, 'Unknown appearance field.' end
    end
    return true
end

function CharacterAppearanceTransport.Install()
    if installed then return CharacterResults.Err('conflict', 'Character appearance transport is already installed.') end
    local registrations = {
        exports['feather-core']:RegisterRpc('character.appearance.get.v1', function(payload, _, context)
            if not context or not context.accountId then
                return CharacterResults.Err('unauthenticated', 'A connected account is required.')
            end
            local ownership = CharacterProfiles.Owns(context.accountId, payload.characterId)
            if not ownership.ok then return ownership end
            if not ownership.value.owned then return CharacterResults.Err('not_found', 'Character was not found.') end
            return CharacterAppearance.Get(payload.characterId)
        end, {
            contract = 1, direction = 'client_to_server', requireCharacter = false,
            windowMs = 2000, maxCalls = 12, maxPayloadBytes = 128, maxDepth = 2, maxNodes = 4,
            validatePayload = GetPayload
        }),
        exports['feather-core']:RegisterRpc('character.appearance.update.v1', function(payload, _, context)
            if not context or not context.characterId or not context.sessionId then
                return CharacterResults.Err('character_required', 'A current character session is required.')
            end
            if not exports['feather-core']:IsSessionCurrent(context.source, context.sessionId, context.characterId) then
                return CharacterResults.Err('session_stale', 'The character session is no longer current.')
            end
            return CharacterAppearance.Update(context.characterId, payload.expectedRevision, payload.document)
        end, {
            contract = 1, direction = 'client_to_server', requireCharacter = true,
            windowMs = 5000, maxCalls = 4,
            maxPayloadBytes = Config.Contract1.appearance.maxDocumentBytes + 1024,
            maxDepth = 12, maxNodes = 2200, validatePayload = UpdatePayload
        })
    }
    for _, result in ipairs(registrations) do
        if type(result) ~= 'table' or result.ok ~= true then
            return CharacterResults.Err('registration_failed', 'A Character appearance route could not be registered.', {
                code = type(result) == 'table' and result.code or 'invalid_result'
            })
        end
    end
    installed = true
    return CharacterResults.Ok({ routes = #registrations })
end

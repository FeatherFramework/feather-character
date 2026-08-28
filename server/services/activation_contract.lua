CharacterActivation = {}

local function Publish(name, payload)
    local result = exports['feather-core']:PublishEvent(name, payload)
    if type(result) ~= 'table' or result.ok ~= true then
        return CharacterResults.Err('internal_error', 'Character lifecycle event could not be published.', {
            event = name,
            code = type(result) == 'table' and result.code or 'invalid_result'
        })
    end
    return CharacterResults.Ok(true)
end

function CharacterActivation.Activate(source, accountId, characterId)
    local ownership = CharacterProfiles.Owns(accountId, characterId)
    if not ownership.ok then return ownership end
    if not ownership.value.owned then return CharacterResults.Err('not_found', 'Character was not found.') end

    local profile = CharacterProfiles.Get(characterId)
    if not profile.ok then return profile end
    local appearance = CharacterAppearance.Get(characterId)
    if not appearance.ok then return appearance end

    local session = exports['feather-core']:ActivateSession(source, characterId)
    if type(session) ~= 'table' or session.ok ~= true then
        return type(session) == 'table' and session
            or CharacterResults.Err('dependency_unavailable', 'Core session activation is unavailable.')
    end
    local spawn = CharacterSpawn.BuildPlan(characterId, session.value.sessionId)
    if not spawn.ok then
        local leaving = exports['feather-core']:BeginSessionLeaving(source, 'activation_failed')
        if leaving and leaving.ok then
            exports['feather-core']:CompleteSessionLeaving(source, leaving.value.sessionId)
        end
        return spawn
    end

    local event = Publish('character.ready.v1', {
        source = source,
        accountId = accountId,
        characterId = characterId,
        sessionId = session.value.sessionId
    })
    if not event.ok then
        local leaving = exports['feather-core']:BeginSessionLeaving(source, 'activation_event_failed')
        if leaving and leaving.ok then
            exports['feather-core']:CompleteSessionLeaving(source, leaving.value.sessionId)
        end
        return event
    end
    return CharacterResults.Ok({
        session = session.value,
        profile = profile.value,
        appearance = appearance.value,
        spawn = spawn.value
    })
end

function CharacterActivation.CompleteSpawn(source, context)
    if not exports['feather-core']:IsSessionCurrent(source, context.sessionId, context.characterId) then
        return CharacterResults.Err('session_stale', 'The character session is no longer current.')
    end
    local event = Publish('character.spawned.v1', {
        source = source,
        accountId = context.accountId,
        characterId = context.characterId,
        sessionId = context.sessionId
    })
    if not event.ok then return event end
    return CharacterResults.Ok({ spawned = true, sessionId = context.sessionId })
end

function CharacterActivation.Logout(source, context, position)
    if not exports['feather-core']:IsSessionCurrent(source, context.sessionId, context.characterId) then
        return CharacterResults.Err('session_stale', 'The character session is no longer current.')
    end
    local saved = CharacterSpawn.UpdatePosition(context.characterId, position)
    if not saved.ok then return saved end
    local leaving = exports['feather-core']:BeginSessionLeaving(source, 'logout')
    if type(leaving) ~= 'table' or not leaving.ok then return leaving end
    local announced = Publish('character.leaving.v1', {
        source = source, accountId = context.accountId, characterId = context.characterId,
        sessionId = context.sessionId, reason = 'logout'
    })
    if not announced.ok then
        exports['feather-core']:CompleteSessionLeaving(source, context.sessionId)
        return announced
    end
    local completed = exports['feather-core']:CompleteSessionLeaving(source, context.sessionId)
    if type(completed) ~= 'table' or not completed.ok then return completed end
    local left = Publish('character.left.v1', {
        source = source, accountId = context.accountId, characterId = context.characterId,
        sessionId = context.sessionId, reason = 'logout'
    })
    if not left.ok then return left end
    return CharacterResults.Ok({
        left = true,
        sessionId = context.sessionId,
        positionRevision = saved.value.revision
    })
end

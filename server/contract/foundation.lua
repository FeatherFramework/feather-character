CharacterFoundation = {}

local resourceName = GetCurrentResourceName()
local resourceVersion = GetResourceMetadata(resourceName, 'version', 0) or '0.0.0'
local logger = CharacterLogging.Create('foundation')
local health = {
    state = 'stopped',
    phase = 'not_started',
    contract = 1,
    version = resourceVersion,
    startedAt = os.time(),
    readyAt = nil,
    failure = nil,
    checks = {}
}

local function Copy(value)
    if type(value) ~= 'table' then return value end
    local output = {}
    for key, child in pairs(value) do output[key] = Copy(child) end
    return output
end

local function SetState(state, phase, failure)
    health.state = state
    health.phase = phase or state
    health.failure = failure and Copy(failure) or nil
    if state == 'ready' then health.readyAt = os.time() end
    logger.Info('lifecycle.changed', { state = state, phase = health.phase })
end

local function ValidateConfig()
    local contract = Config and Config.Contract1
    if type(contract) ~= 'table' or contract.enabled ~= true then
        return CharacterResults.Err('invalid_config', 'Config.Contract1.enabled must be true.')
    end
    if tonumber(contract.contract) ~= 1 then
        return CharacterResults.Err('invalid_config', 'Config.Contract1.contract must be 1.')
    end
    if type(Config.MaxAllowedChars) ~= 'number' or Config.MaxAllowedChars < 1
        or Config.MaxAllowedChars ~= math.floor(Config.MaxAllowedChars) then
        return CharacterResults.Err('invalid_config', 'Config.MaxAllowedChars must be a positive integer.')
    end
    local deletion = Config.Character and Config.Character.deletion
    if type(deletion) ~= 'table' or type(deletion.requireConfirmation) ~= 'boolean'
        or type(deletion.minimumAgeHours) ~= 'number' or deletion.minimumAgeHours < 0
        or type(deletion.recoveryDays) ~= 'number' or deletion.recoveryDays < 1 then
        return CharacterResults.Err('invalid_config', 'Config.Character.deletion is invalid.')
    end
    local bytes = contract.appearance and contract.appearance.maxDocumentBytes
    if type(bytes) ~= 'number' or bytes < 1024 then
        return CharacterResults.Err('invalid_config', 'Appearance maxDocumentBytes must be at least 1024.')
    end
    if type(contract.positionSyncMs) ~= 'number' or contract.positionSyncMs < 5000 then
        return CharacterResults.Err('invalid_config', 'Contract 1 positionSyncMs must be at least 5000.')
    end
    if type(contract.spawnPoints) ~= 'table' or next(contract.spawnPoints) == nil then
        return CharacterResults.Err('invalid_config', 'Config.Contract1.spawnPoints must define at least one spawn point.')
    end
    for spawnPointId, point in pairs(contract.spawnPoints) do
        if type(spawnPointId) ~= 'string' or type(point) ~= 'table'
            or type(point.x) ~= 'number' or type(point.y) ~= 'number' or type(point.z) ~= 'number'
            or type(point.heading) ~= 'number' then
            return CharacterResults.Err('invalid_config', 'A Contract 1 spawn point is invalid.', {
                spawnPointId = tostring(spawnPointId)
            })
        end
    end
    health.checks.configuration = { ok = true, checkedAt = os.time() }
    return CharacterResults.Ok(true)
end

function CharacterFoundation.BeginStartup()
    SetState('booting', 'validating_configuration')
    local config = ValidateConfig()
    if not config.ok then
        SetState('failed', 'configuration_failed', config)
        return config
    end
    SetState('migrating', 'database_migrations')
    return CharacterResults.Ok(true)
end

function CharacterFoundation.MarkMigrationsComplete(details)
    health.checks.migrations = { ok = true, checkedAt = os.time(), details = Copy(details or {}) }
    SetState('starting', 'starting_services')
end

function CharacterFoundation.MarkReady()
    SetState('ready', 'ready')
    return CharacterResults.Ok(CharacterFoundation.GetHealth())
end

function CharacterFoundation.MarkFailed(code, message, details)
    local result = CharacterResults.Err(code, message, details)
    SetState('failed', 'startup_failed', result)
    logger.Error('startup.failed', result)
    return result
end

function CharacterFoundation.GetHealth()
    return Copy(health)
end

function CharacterFoundation.GetCapabilities()
    return CharacterResults.Ok({
        resource = resourceName,
        contract = 1,
        version = resourceVersion,
        state = health.state,
        features = {
            lifecycle = 1,
            health = 1,
            migrations = 1,
            profiles = 1,
            creation = 1,
            appearance = 1,
            activation = 1,
            spawn = 1,
            provider = 1
        }
    })
end

function CharacterFoundation.AwaitReady(timeoutMs)
    timeoutMs = tonumber(timeoutMs) or 10000
    if timeoutMs < 0 or timeoutMs > 60000 then
        return CharacterResults.Err('invalid_input', 'timeoutMs must be between 0 and 60000.')
    end
    local deadline = GetGameTimer() + timeoutMs
    while health.state ~= 'ready' and health.state ~= 'failed' and GetGameTimer() < deadline do Wait(0) end
    if health.state == 'ready' then return CharacterResults.Ok(CharacterFoundation.GetHealth()) end
    if health.state == 'failed' then
        return CharacterResults.Err('not_ready', 'Feather Character failed to start.', { health = CharacterFoundation.GetHealth() })
    end
    return CharacterResults.Err('timeout', 'Timed out waiting for Feather Character readiness.')
end

exports('GetCapabilities', CharacterFoundation.GetCapabilities)
exports('GetHealth', function() return CharacterResults.Ok(CharacterFoundation.GetHealth()) end)
exports('AwaitReady', CharacterFoundation.AwaitReady)

AddEventHandler('onResourceStop', function(resource)
    if resource == resourceName then SetState('stopped', 'resource_stopped') end
end)

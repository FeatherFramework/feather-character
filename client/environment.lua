-- Optional presentation consumer. Weather remains the sole native/environment owner.
CharacterV2Environment = {}
local E = CharacterV2Environment
local handle, view, status, nextRefresh = nil, nil, 'idle', 0
local generation = 0
local lastDetail
local resource = GetCurrentResourceName()

local function Log(nextStatus, detail)
    if status == nextStatus and lastDetail == detail then return end
    status = nextStatus
    lastDetail = detail
    print(('[feather-character-v2] environment: %s%s'):format(status, detail and (' ' .. detail) or ''))
end
local function Call(action, spec)
    local ok, result = pcall(function()
        if action == 'acquire' then return exports['feather-weather']:AcquireOverride(spec) end
        if action == 'update' then return exports['feather-weather']:UpdateOverride(handle, spec) end
        if action == 'release' then return exports['feather-weather']:ReleaseOverride(handle) end
        return exports['feather-weather']:GetLocalState()
    end)
    if not ok then return {ok=false, code='export_failure', message=tostring(result)} end
    if type(result) ~= 'table' or type(result.ok) ~= 'boolean' then
        return {ok=false, code='invalid_result', message='Weather returned an invalid result envelope.'}
    end
    return result
end
local function Config()
    local c = CharacterV2Config.sceneEnvironment
    if c == nil or (type(c) == 'table' and c.enabled == false) then return nil end
    local function number(value, low, high)
        return type(value) == 'number' and value == value and value >= low and value <= high
    end
    if type(c) ~= 'table' or c.enabled ~= true
        or not number(c.priority, 0, 100) or c.priority % 1 ~= 0
        or not number(c.ttlSeconds, 2, 3600)
        or not number(c.renewIntervalMs, 1000, c.ttlSeconds * 500)
        or not number(c.readyTimeoutMs, 0, 10000)
        or not number(c.transitionSeconds, 0, 300) then
        Log('invalid_config', 'Invalid sceneEnvironment limits; shared environment retained.')
        return nil
    end
    for _, key in ipairs({'selector','creator'}) do
        local preset = c[key]
        if type(preset) ~= 'table' or not number(preset.clock, 0, 604800) or preset.clock >= 604800
            or type(preset.weather) ~= 'string' or #preset.weather < 1 or #preset.weather > 32 then
            Log('invalid_config', 'Invalid ' .. key .. ' scene preset; shared environment retained.')
            return nil
        end
    end
    return c
end
local function Spec()
    local c = Config()
    local preset = c and c[view]
    if type(preset) ~= 'table' then return nil end
    return { clock=preset.clock, weather={name=preset.weather, transitionSeconds=c.transitionSeconds},
        wind={direction=0, speed=0}, snow=false, priority=c.priority, ttlSeconds=c.ttlSeconds }
end
local function Due(now, before) return (now - before) % 4294967296 end
local function OwnsChannels(state)
    local effective = type(state) == 'table' and state.effective
    local channels = type(effective) == 'table' and effective.channels
    if type(channels) ~= 'table' then return false end
    for _, channel in ipairs({'clock','weather','wind','snow'}) do
        local winner = channels[channel]
        if type(winner) ~= 'table' or winner.owner ~= resource
            or type(winner.token) ~= 'string' or winner.token:sub(1, #handle + 1) ~= handle .. ':' then return false end
    end
    local spec = Spec()
    return spec and effective.clock == spec.clock and type(effective.weather) == 'table'
        and effective.weather.name == spec.weather.name and type(effective.wind) == 'table'
        and effective.wind.direction == 0 and effective.wind.speed == 0 and effective.snow == false
end

-- No yielding in Poll: the foreground wait and renewal worker cannot overlap acquisition.
local function Poll(force)
    if not view then return false end
    local c = Config()
    if not c then if status ~= 'invalid_config' then Log('disabled') end; return false end
    if GetResourceState('feather-weather') ~= 'started' then
        handle = nil
        nextRefresh = GetGameTimer()
        Log('waiting_provider', 'Shared environment retained until Weather becomes available.')
        return false
    end
    local spec = Spec()
    if not spec then Log('invalid_config', 'No environment preset for ' .. view); return false end
    local now = GetGameTimer()
    if force or Due(now, nextRefresh) < 2147483648 then
        local result = Call(handle and 'update' or 'acquire', spec)
        if not result.ok and handle and result.code == 'not_found' then
            handle = nil
            result = Call('acquire', spec)
        end
        if not result.ok then
            nextRefresh = (now + 1000) % 4294967296
            Log(result.code or 'unavailable', result.message)
            return false
        end
        if type(result.value) ~= 'table' or type(result.value.handle) ~= 'string' then
            Log('invalid_result', 'Weather did not return an override handle.')
            return false
        end
        handle = result.value.handle
        nextRefresh = (now + c.renewIntervalMs) % 4294967296
    end
    if not handle then return false end
    local state = Call('state')
    if not state.ok then Log(state.code or 'unavailable', state.message); return false end
    if OwnsChannels(state.value) then Log('active', view); return true end
    Log('waiting_application', view)
    return false
end

function E.Enter(nextView)
    if nextView ~= 'selector' and nextView ~= 'creator' then return false end
    local changed = view ~= nextView
    view = nextView
    generation = generation + 1
    local ticket, c = generation, Config()
    if not c then if status ~= 'invalid_config' then Log('disabled') end; return false end
    local started = GetGameTimer()
    if Poll(changed) then return true end
    -- Bounded wait before reveal. Weather absent/denied must never prevent character use.
    if GetResourceState('feather-weather') ~= 'started' or status == 'denied' or status == 'invalid_config' then return false end
    while ticket == generation and view == nextView and Due(GetGameTimer(), started) < c.readyTimeoutMs do
        Wait(100)
        if ticket ~= generation or view ~= nextView then return false end
        if Poll(false) then return true end
        if status == 'denied' or GetResourceState('feather-weather') ~= 'started' then return false end
    end
    if ticket == generation then Log('degraded', 'Continuing presentation; background recovery remains enabled.') end
    return false
end

function E.Leave(reason)
    generation = generation + 1
    view = nil -- Clear intent first, so no worker/retry reacquires during activation.
    if handle and GetResourceState('feather-weather') == 'started' then
        local result = Call('release')
        if not result.ok then
            -- Retain the handle for bounded background release retries; TTL is the final safety net.
            Log('release_pending', result.message)
            return false
        end
    end
    handle = nil
    Log('idle', reason)
    return true
end

function E.State()
    return {view=view, status=status, hasHandle=handle ~= nil, generation=generation}
end

CreateThread(function()
    while true do
        Wait(1000)
        if view then Poll(false)
        elseif handle then E.Leave('release_retry') end
    end
end)
AddEventHandler('onClientResourceStop', function(name)
    if name == 'feather-weather' then
        handle = nil
        nextRefresh = GetGameTimer()
        if view then Log('waiting_provider', 'Weather stopped; scene will reacquire after readiness.') end
    elseif name == resource then
        E.Leave('resource_stop')
    end
end)
RegisterCommand('characterWeatherStatus', function()
    print('[feather-character-v2] environment: ' .. json.encode(E.State()))
end, false)

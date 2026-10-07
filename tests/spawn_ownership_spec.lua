-- Run from the resource root: lua tests/spawn_ownership_spec.lua
local handlers, threads, logs = {}, {}, {}
local state, enabled, callback = 'stopped', true, nil
local fail = false
local writes = 0
local nativeSpawns = 0
exports = { spawnmanager = {
    setAutoSpawnCallback = function(_, value)
        if fail then error('export unavailable') end
        callback, enabled = value, true
        writes = writes + 1
    end,
    setAutoSpawn = function(_, value) enabled = value end
} }
function GetResourceState() return state end
function GetCurrentResourceName() return 'feather-character' end
function AddEventHandler(name, fn) handlers[name] = fn end
function CreateThread(fn) threads[#threads + 1] = coroutine.create(fn) end
function Wait() coroutine.yield() end
function print(message) logs[#logs + 1] = message end
local function Step(thread)
    local ok, problem = coroutine.resume(thread)
    assert(ok, problem)
end
local function SpawnmanagerTick()
    if enabled then
        if callback then callback() else nativeSpawns = nativeSpawns + 1 end
    end
end

dofile('client/spawn_ownership.lua')
assert(writes == 0, 'Unavailable manager must not be called')
state = 'started'
handlers.onClientResourceStart('spawnmanager')
Step(threads[#threads])
Step(threads[#threads])
assert(enabled == false and type(callback) == 'function')
-- basic-gamemode enables spawning and force-respawns on a map start. The
-- retained callback must block replacement even before the deferred guard.
enabled = true
SpawnmanagerTick()
assert(nativeSpawns == 0, 'Generic timer must not replace the selected ped')
handlers.onClientMapStart()
Step(threads[#threads])
Step(threads[#threads])
assert(enabled == false)
-- Manager restart loses all globals, including the callback.
state, callback, enabled = 'stopped', nil, false
assert(CharacterV2SpawnOwnership.Enforce() == false)
state = 'started'
assert(CharacterV2SpawnOwnership.Enforce())
enabled = true
SpawnmanagerTick()
assert(nativeSpawns == 0)
-- Failures are visible and deduplicated; retries recover.
fail = true
assert(not CharacterV2SpawnOwnership.Enforce())
assert(not CharacterV2SpawnOwnership.Enforce())
assert(#logs == 1)
fail = false
assert(CharacterV2SpawnOwnership.Enforce())
-- Polling reclaims the guard if a competing resource replaces the callback.
callback, enabled = nil, true
Step(threads[1])
Step(threads[1])
assert(enabled == false and type(callback) == 'function')
handlers.onClientResourceStop('unrelated')
assert(type(callback) == 'function')
handlers.onClientResourceStop('feather-character')
assert(callback == nil and enabled == false)
io.write('spawn ownership checks passed\n')

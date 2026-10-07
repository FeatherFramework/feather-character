-- Character owns initial spawning and recovery. Generic map spawns must never
-- replace the selected metaped, including after map/spawnmanager restarts.
CharacterV2SpawnOwnership = {}

local lastFailure
local function SuppressGenericSpawn()
    -- Deliberately retain the current ped. Recovery must be authorized by the
    -- character condition lifecycle, not by spawnmanager's death timer.
end

function CharacterV2SpawnOwnership.Enforce()
    if GetResourceState('spawnmanager') ~= 'started' then return false end
    local ok, problem = pcall(function()
        -- setAutoSpawnCallback also enables auto-spawn. Disable it afterwards;
        -- keeping the callback protects against another resource enabling it.
        exports.spawnmanager:setAutoSpawnCallback(SuppressGenericSpawn)
        exports.spawnmanager:setAutoSpawn(false)
    end)
    if not ok then
        local message = tostring(problem)
        if message ~= lastFailure then
            print(('[feather-character] Cannot claim spawn ownership: %s'):format(message))
            lastFailure = message
        end
        return false
    end
    lastFailure = nil
    return true
end

CharacterV2SpawnOwnership.Enforce()

AddEventHandler('onClientMapStart', function()
    -- Other map-start handlers can enable spawning after our handler returns.
    CreateThread(function()
        Wait(0)
        CharacterV2SpawnOwnership.Enforce()
    end)
end)

AddEventHandler('onClientResourceStart', function(resource)
    if resource == 'spawnmanager' then
        CreateThread(function()
            Wait(0)
            CharacterV2SpawnOwnership.Enforce()
        end)
    end
end)

CreateThread(function()
    while true do
        Wait(250)
        CharacterV2SpawnOwnership.Enforce()
    end
end)

AddEventHandler('onClientResourceStop', function(resource)
    if resource ~= GetCurrentResourceName()
        or GetResourceState('spawnmanager') ~= 'started' then return end
    -- Remove our function reference without returning control to random map
    -- spawns. A coordinated restart is required for Character updates.
    pcall(function()
        exports.spawnmanager:setAutoSpawnCallback(nil)
        exports.spawnmanager:setAutoSpawn(false)
    end)
end)

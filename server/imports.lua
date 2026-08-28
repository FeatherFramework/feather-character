local ready = exports['feather-core']:AwaitReady(30000)
if type(ready) ~= 'table' or ready.ok ~= true then
    local code = type(ready) == 'table' and ready.code or 'dependency_unavailable'
    local message = type(ready) == 'table' and ready.message or 'feather-core readiness is unavailable'
    error(('[feather-character] feather-core startup failed: [%s] %s'):format(tostring(code), tostring(message)))
end

local capabilities = exports['feather-core']:GetCapabilities()
if type(capabilities) ~= 'table' or capabilities.ok ~= true or type(capabilities.value) ~= 'table' then
    error('[feather-character] feather-core capabilities are unavailable')
end

local coreContract = tonumber(capabilities.value.contract) or 0
local features = type(capabilities.value.features) == 'table' and capabilities.value.features or {}
local requiredFeatures = { 'lifecycle', 'accountContext', 'sessions', 'rpc' }
if coreContract < 1 then
    error(('[feather-character] feather-core contract %s is unsupported (requires 1)'):format(tostring(coreContract)))
end
for _, feature in ipairs(requiredFeatures) do
    if (tonumber(features[feature]) or 0) < 1 then
        error(('[feather-character] feather-core feature %s is unavailable'):format(feature))
    end
end

FeatherCoreContract = capabilities.value
if type(FeatherCore) ~= 'table' or type(FeatherCore.RPC) ~= 'table' then
    error('[feather-character] named Core RPC adapter is unavailable')
end

CharacterRoutingTransport = {}

local installed = false
local selectionRouteId = nil
local selectionSources = {}

local function EmptyPayload(payload)
    return type(payload) == 'table' and next(payload) == nil,
        'This route does not accept payload fields.'
end

local function RoutingFailure(result, fallback)
    if type(result) == 'table' and result.ok == false then
        return CharacterResults.Err(result.code or 'routing_unavailable',
            result.message or fallback, result.details)
    end
    return CharacterResults.Err('routing_unavailable', fallback)
end

local function EnsureSelectionRoute()
    local called, created = pcall(function()
        return exports['feather-routing']:CreateRoute({
            key = 'character-selection',
            mode = 'strict',
            populationEnabled = false
        })
    end)
    if not called then
        selectionRouteId = nil
        return CharacterResults.Err('routing_unavailable',
            'The character-selection route provider is not callable.', {
                reason = tostring(created)
            })
    end
    if type(created) ~= 'table' or created.ok ~= true
        or type(created.value) ~= 'table' or type(created.value.routeId) ~= 'string' then
        selectionRouteId = nil
        return RoutingFailure(created, 'The character-selection route could not be created.')
    end
    selectionRouteId = created.value.routeId
    return CharacterResults.Ok({ routeId = selectionRouteId })
end

function CharacterRoutingTransport.Install()
    if installed then
        return CharacterResults.Err('conflict', 'Character routing transport is already installed.')
    end

    local capabilityCall, capabilities = pcall(function()
        return exports['feather-routing']:GetCapabilities()
    end)
    if not capabilityCall or type(capabilities) ~= 'table' or capabilities.ok ~= true
        or type(capabilities.value) ~= 'table'
        or tonumber(capabilities.value.contract) == nil
        or tonumber(capabilities.value.contract) < 1
        or type(capabilities.value.features) ~= 'table'
        or tonumber(capabilities.value.features.routes) == nil
        or tonumber(capabilities.value.features.routes) < 1 then
        return CharacterResults.Err('unsupported_contract',
            'feather-routing Contract 1 with route support is required.')
    end

    local created = EnsureSelectionRoute()
    if not created.ok then return created end

    local routes = {
        exports['feather-core']:RegisterRpc('character.selection.route.enter.v1', function(_, source, context)
            if not context or not context.accountId then
                return CharacterResults.Err('unauthenticated', 'A connected account is required.')
            end
            if not selectionRouteId then
                local ensured = EnsureSelectionRoute()
                if not ensured.ok then return ensured end
            end
            local called, joined = pcall(function()
                return exports['feather-routing']:JoinRoute(selectionRouteId, source)
            end)
            if not called or type(joined) ~= 'table' or joined.ok ~= true then
                return RoutingFailure(joined, 'The character-selection route could not be joined.')
            end
            selectionSources[source] = true
            return CharacterResults.Ok({ routed = true })
        end, {
            contract = 1, direction = 'client_to_server', requireCharacter = false,
            windowMs = 5000, maxCalls = 3, maxPayloadBytes = 64, maxDepth = 2, maxNodes = 4,
            validatePayload = EmptyPayload
        }),
        exports['feather-core']:RegisterRpc('character.selection.route.leave.v1', function(_, source)
            selectionSources[source] = nil
            local called, left = pcall(function()
                return exports['feather-routing']:LeaveRoute(source)
            end)
            if not called or type(left) ~= 'table' or left.ok ~= true then
                return RoutingFailure(left, 'The character-selection route could not be left.')
            end
            return CharacterResults.Ok({ routed = false })
        end, {
            contract = 1, direction = 'client_to_server', requireCharacter = false,
            windowMs = 5000, maxCalls = 3, maxPayloadBytes = 64, maxDepth = 2, maxNodes = 4,
            validatePayload = EmptyPayload
        })
    }

    for _, result in ipairs(routes) do
        if type(result) ~= 'table' or result.ok ~= true then
            return CharacterResults.Err('registration_failed',
                'A Character routing route could not be registered.', {
                    code = type(result) == 'table' and result.code or 'invalid_result'
                })
        end
    end

    installed = true
    return CharacterResults.Ok({ routes = #routes, routingContract = capabilities.value.contract })
end

AddEventHandler('onResourceStop', function(resource)
    if resource == 'feather-routing' then selectionRouteId = nil end
end)

AddEventHandler('playerDropped', function()
    selectionSources[source] = nil
end)

AddEventHandler('routing.ready.v1', function(capabilities)
    if not installed or GetResourceState('feather-routing') ~= 'started'
        or type(capabilities) ~= 'table' or tonumber(capabilities.contract) ~= 1 then return end
    CreateThread(function()
        -- Leave the ready-event call stack before calling back into the
        -- provider's export host; CFX function references are not re-entrant.
        Wait(0)
        local result = EnsureSelectionRoute()
        if not result.ok then
            print(('[feather-character] feather-routing recovery failed: %s'):format(
                result.message or result.code or 'unknown error'))
            return
        end
        for source in pairs(selectionSources) do
            if GetPlayerName(source) ~= nil then
                local called, joined = pcall(function()
                    return exports['feather-routing']:JoinRoute(selectionRouteId, source)
                end)
                if not called or type(joined) ~= 'table' or joined.ok ~= true then
                    print(('[feather-character] selection route recovery failed source=%s code=%s'):format(
                        tostring(source), called and type(joined) == 'table' and tostring(joined.code)
                            or 'provider_unavailable'))
                end
            else
                selectionSources[source] = nil
            end
        end
    end)
end)

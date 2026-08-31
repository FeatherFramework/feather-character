CharacterLogoutCheckpoints = {}

local registrations = {}

local function OwnerName()
    local owner = GetInvokingResource()
    if type(owner) ~= 'string' or owner == '' then owner = GetCurrentResourceName() end
    return owner
end

function CharacterLogoutCheckpoints.Register(name, exportName)
    if type(name) ~= 'string' or name == '' or type(exportName) ~= 'string' or exportName == '' then
        return { ok = false, code = 'invalid_registration', message = 'A name and export name are required.' }
    end
    local owner = OwnerName()
    local existing = registrations[name]
    if existing and existing.owner ~= owner then
        return { ok = false, code = 'conflict', message = 'That logout checkpoint is owned by another resource.' }
    end
    registrations[name] = { owner = owner, exportName = exportName }
    return { ok = true, value = { name = name, owner = owner, exportName = exportName } }
end

function CharacterLogoutCheckpoints.Run(context)
    for name, registration in pairs(registrations) do
        if GetResourceState(registration.owner) == 'started' then
            local called, result = pcall(function()
                return exports[registration.owner][registration.exportName](context or {})
            end)
            if not called or type(result) ~= 'table' or result.ok ~= true then
                return {
                    ok = false,
                    code = type(result) == 'table' and result.code or 'checkpoint_failed',
                    message = type(result) == 'table' and result.message or 'A logout checkpoint failed.',
                    details = { checkpoint = name, owner = registration.owner }
                }
            end
        else
            registrations[name] = nil
        end
    end
    return { ok = true }
end

exports('RegisterLogoutCheckpoint', CharacterLogoutCheckpoints.Register)

AddEventHandler('onClientResourceStop', function(resourceName)
    for name, registration in pairs(registrations) do
        if registration.owner == resourceName then registrations[name] = nil end
    end
end)

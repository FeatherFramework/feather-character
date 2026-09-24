-- Dependent resources may flush transient state before a voluntary logout.
CharacterV2Checkpoints = {}

local registrations = {}

exports('RegisterLogoutCheckpoint', function(name, exportName)
    if type(name) ~= 'string' or name == ''
        or type(exportName) ~= 'string' or exportName == '' then
        return CharacterV2Result.Err('invalid_registration', 'Name and export are required.')
    end
    local owner = GetInvokingResource()
    if type(owner) ~= 'string' or owner == '' then
        return CharacterV2Result.Err('invalid_registration', 'Calling resource is required.')
    end
    local existing = registrations[name]
    if existing and existing.owner ~= owner then
        return CharacterV2Result.Err('conflict', 'Checkpoint name belongs to another resource.')
    end
    registrations[name] = { owner = owner, exportName = exportName }
    return CharacterV2Result.Ok({ name = name, owner = owner, exportName = exportName })
end)

function CharacterV2Checkpoints.Run(context)
    for name, registration in pairs(registrations) do
        if GetResourceState(registration.owner) == 'started' then
            local called, result = pcall(function()
                return exports[registration.owner][registration.exportName](context)
            end)
            if not called or type(result) ~= 'table' or not result.ok then
                return CharacterV2Result.Err('checkpoint_failed',
                    ('Logout checkpoint %s failed.'):format(name))
            end
        else
            registrations[name] = nil
        end
    end
    return CharacterV2Result.Ok(true)
end

AddEventHandler('onClientResourceStop', function(resource)
    for name, registration in pairs(registrations) do
        if registration.owner == resource then registrations[name] = nil end
    end
end)

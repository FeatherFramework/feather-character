FeatherCore = {
    RPC = {
        CallAsync = function(name, params, source, timeoutMs)
            return exports['feather-core']:CallRPCAsync(name, params, source, timeoutMs)
        end
    },
    Locale = {
        register = function(locale, translations)
            return exports['feather-core']:RegisterLocale(locale, translations)
        end,
        translate = function(source, key, ...)
            local result = exports['feather-core']:TranslateLocale(source, key, ...)
            return type(result) == 'table' and result.ok == true and result.value
                or ('Translation [%s] is unavailable'):format(tostring(key))
        end
    }
}

if not IsDuplicityVersion() then
    FeatherCore.Notify = {
        Notify = function(message, duration)
            local called, result = pcall(function()
                return exports['feather-notify']:ShowNotification({
                    style = 'right', message = message, duration = duration
                })
            end)
            if called and type(result) == 'table' then return result end
            return { ok = false, code = 'provider_unavailable', message = 'Notification presentation is unavailable.' }
        end
    }
    FeatherCore.Teleport = {
        ToCoords = function(coords, options)
            return CharacterTeleport:ToCoords(coords, options)
        end
    }
end

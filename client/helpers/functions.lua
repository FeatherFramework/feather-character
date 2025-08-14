function Notify(message, typeOrDuration, maybeDuration)
    local notifyType = "info"
    local notifyDuration = 6000

    -- Detect which argument is which
    if type(typeOrDuration) == "string" then
        notifyType = typeOrDuration
        notifyDuration = tonumber(maybeDuration) or 6000
    elseif type(typeOrDuration) == "number" then
        notifyDuration = typeOrDuration
    end

    if Config.Notify == "feather-menu" then
        FeatherMenu:Notify({
            message = message,
            type = notifyType,
            autoClose = notifyDuration,
            position = "top-center",
            transition = "slide",
            icon = true,
            hideProgressBar = false,
            rtl = false,
            style = {},
            toastStyle = {},
            progressStyle = {}
        })
    elseif Config.Notify == "feather-core" then
        FeatherCore.Notify.Notify(message, notifyDuration)
    else
        print("^1[Notify] Invalid Config.Notify: " .. tostring(Config.Notify))
    end
end

FeatherCore.RPC:Register("feather-character:NotifyClient", function(data)
    Notify(data.message, data.type, data.duration)
end)
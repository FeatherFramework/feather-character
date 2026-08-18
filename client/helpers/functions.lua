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

-- (CHAR-06) Was colon-called on `RPCAPI.Register`, which is dot-defined --
-- the RPC table itself landed in the `name` param, which fails
-- `RPCAPI.Register`'s `type(name) ~= 'string'` check and rejects the
-- registration outright. This handler never actually registered, so even a
-- correctly-called server-side Notify (see server/imports.lua) had nothing
-- to dispatch to client-side.
FeatherCore.RPC.Register("feather-character:NotifyClient", function(data)
    Notify(data.message, data.type, data.duration)
end)
FeatherCore = exports['feather-core'].initiate()

function NotifyClient(src, message, type, duration)
    FeatherCore.RPC:Notify("feather-character:NotifyClient", {
        message = message,
        type = type or "info",
        duration = duration or 6000
    }, src)
end
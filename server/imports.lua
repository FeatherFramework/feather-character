FeatherCore = exports['feather-core'].initiate()

function NotifyClient(src, message, type, duration)
    -- (CHAR-06) Was colon-called (`FeatherCore.RPC:Notify`) on `RPCAPI.Notify`,
    -- which is dot-defined -- the colon call implicitly passes the RPC table
    -- itself as the first arg, shifting everything over by one: `name`
    -- received the RPC table (fails the `type(name) ~= 'string'` dispatch
    -- check), `params` received the event name string, and the real `src`
    -- never got passed at all. With `source` then nil, feather-core's
    -- TriggerRemoteEvent does `TriggerClientEvent(eventName, source or -1, ...)`
    -- -- `-1` broadcasts to every connected client, so every notification
    -- meant for one player (e.g. the CHAR-01 rejection) went out to the
    -- entire server instead, mangled, with a table as the event name so it
    -- never dispatched at all client-side.
    FeatherCore.RPC.Notify("feather-character:NotifyClient", {
        message = message,
        type = type or "info",
        duration = duration or 6000
    }, src)
end
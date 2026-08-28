CharacterLogging = {}

local levels = { debug = 10, info = 20, warn = 30, error = 40 }
local sensitive = { password = true, secret = true, token = true, identifier = true, metadata = true }

local function Redact(value, depth)
    if type(value) ~= 'table' then return value end
    if depth >= 6 then return '[depth-limit]' end
    local output = {}
    for key, child in pairs(value) do
        local normalized = type(key) == 'string' and key:lower() or ''
        local hidden = false
        for name in pairs(sensitive) do
            if normalized:find(name, 1, true) then hidden = true break end
        end
        output[key] = hidden and '[redacted]' or Redact(child, depth + 1)
    end
    return output
end

function CharacterLogging.Create(subsystem)
    local logger = {}
    local configured = Config and Config.Contract1 and Config.Contract1.logging
    local threshold = levels[configured and configured.level or 'info'] or levels.info

    local function Write(level, eventName, fields)
        if levels[level] < threshold then return end
        local suffix = ''
        if fields ~= nil then
            local ok, encoded = pcall(json.encode, Redact(fields, 0))
            suffix = ok and (' ' .. encoded) or ' {"loggingError":"encode_failed"}'
        end
        print(('[feather-character] [%s] [%s] %s%s'):format(level:upper(), subsystem, eventName, suffix))
    end

    function logger.Debug(eventName, fields) Write('debug', eventName, fields) end
    function logger.Info(eventName, fields) Write('info', eventName, fields) end
    function logger.Warn(eventName, fields) Write('warn', eventName, fields) end
    function logger.Error(eventName, fields) Write('error', eventName, fields) end
    return logger
end

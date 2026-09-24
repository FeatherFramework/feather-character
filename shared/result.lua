CharacterV2Result = {}

function CharacterV2Result.Ok(value)
    return { ok = true, value = value }
end

function CharacterV2Result.Err(code, message)
    return { ok = false, code = code, message = message }
end

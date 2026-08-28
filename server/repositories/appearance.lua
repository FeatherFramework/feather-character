CharacterAppearance = {}

local allowedSections = {
    attributes = true,
    clothing = true,
    overlays = true,
    tints = true
}

local function ValidatePlain(value, depth, state)
    local kind = type(value)
    state.nodes = state.nodes + 1
    if state.nodes > 2048 then return false end
    if kind == 'nil' or kind == 'boolean' or kind == 'string' then return true end
    if kind == 'number' then return value == value and value ~= math.huge and value ~= -math.huge end
    if kind ~= 'table' or depth >= 10 or state.seen[value] then return false end
    state.seen[value] = true
    for key, child in pairs(value) do
        if type(key) ~= 'string' and type(key) ~= 'number' then return false end
        if not ValidatePlain(child, depth + 1, state) then return false end
    end
    state.seen[value] = nil
    return true
end

local function EncodeDocument(document)
    if type(document) ~= 'table' then
        return CharacterResults.Err('appearance_invalid', 'Appearance document must be a table.')
    end
    for key in pairs(document) do
        if not allowedSections[key] then
            return CharacterResults.Err('appearance_invalid', 'Appearance document contains an unknown section.', {
                section = tostring(key)
            })
        end
    end
    for section in pairs(allowedSections) do
        if document[section] ~= nil and type(document[section]) ~= 'table' then
            return CharacterResults.Err('appearance_invalid', ('Appearance section %s must be a table.'):format(section))
        end
    end
    if not ValidatePlain(document, 0, { nodes = 0, seen = {} }) then
        return CharacterResults.Err('appearance_invalid', 'Appearance document exceeds its structural limits.')
    end
    local ok, encoded = pcall(json.encode, document)
    if not ok or type(encoded) ~= 'string' or #encoded > Config.Contract1.appearance.maxDocumentBytes then
        return CharacterResults.Err('appearance_invalid', 'Appearance document is invalid or too large.')
    end
    return CharacterResults.Ok(encoded)
end

local function DecodeRow(row)
    local ok, document = pcall(json.decode, row.document or '{}')
    if not ok or type(document) ~= 'table' then
        return CharacterResults.Err('internal_error', 'Stored appearance document is invalid.')
    end
    return CharacterResults.Ok({
        characterId = row.character_id,
        schemaVersion = tonumber(row.schema_version),
        revision = tonumber(row.revision),
        model = row.model,
        document = document,
        updatedAt = tostring(row.updated_at)
    })
end

function CharacterAppearance.Get(characterId)
    if type(characterId) ~= 'string' then
        return CharacterResults.Err('invalid_input', 'characterId is required.')
    end
    local rows = MySQL.query.await([[
        SELECT a.`character_id`, a.`schema_version`, a.`revision`, a.`document`, a.`updated_at`, p.`model`
        FROM `character_appearance_documents` a
        INNER JOIN `character_profiles` p ON p.`character_id` = a.`character_id`
        WHERE a.`character_id` = ? AND p.`status` = 'active'
        LIMIT 1
    ]], { characterId }) or {}
    if not rows[1] then return CharacterResults.Err('not_found', 'Character appearance was not found.') end
    return DecodeRow(rows[1])
end

function CharacterAppearance.Update(characterId, expectedRevision, document)
    expectedRevision = tonumber(expectedRevision)
    if type(characterId) ~= 'string' or not expectedRevision or expectedRevision < 1
        or expectedRevision ~= math.floor(expectedRevision) then
        return CharacterResults.Err('invalid_input', 'characterId and a positive expectedRevision are required.')
    end
    local encoded = EncodeDocument(document)
    if not encoded.ok then return encoded end

    local result = MySQL.update.await([[
        UPDATE `character_appearance_documents` a
        INNER JOIN `character_profiles` p ON p.`character_id` = a.`character_id`
        SET a.`document` = ?, a.`revision` = a.`revision` + 1
        WHERE a.`character_id` = ? AND a.`revision` = ? AND p.`status` = 'active'
    ]], { encoded.value, characterId, expectedRevision })
    local affected = type(result) == 'table' and tonumber(result.affectedRows) or tonumber(result) or 0
    if affected ~= 1 then
        local current = CharacterAppearance.Get(characterId)
        if not current.ok then return current end
        return CharacterResults.Err('conflict', 'Appearance revision is stale.', {
            expectedRevision = expectedRevision,
            actualRevision = current.value.revision
        })
    end
    return CharacterAppearance.Get(characterId)
end

function CharacterAppearance.Validate(document)
    local result = EncodeDocument(document)
    return result.ok and CharacterResults.Ok(true) or result
end

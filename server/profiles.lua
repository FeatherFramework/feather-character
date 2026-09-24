-- Account-scoped repository. Creation persists only catalog-constrained
-- appearance values; arbitrary client component hashes are not accepted.
CharacterV2Profiles = {}

local function Uuid(value)
    return type(value) == 'string' and value:match(
        '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$'
    ) ~= nil
end

local function RequestKey(value)
    return type(value) == 'string' and #value >= 8 and #value <= 96
        and value:match('^[%w%-%:_]+$') ~= nil
end

local function PublicProfile(row)
    return {
        characterId = row.character_id,
        firstName = row.first_name,
        lastName = row.last_name,
        dateOfBirth = tostring(row.date_of_birth),
        model = row.model,
        description = row.description or '',
        status = row.status
    }
end

-- Stable across Lua table iteration orders, so a retried create request with
-- the same appearance does not spuriously conflict on its idempotency key.
local function Canonical(value, seen)
    local kind = type(value)
    if kind ~= 'table' then
        if kind ~= 'string' and kind ~= 'number' and kind ~= 'boolean' and kind ~= 'nil' then return nil end
        local ok, encoded = pcall(json.encode, value)
        return ok and encoded or nil
    end
    if getmetatable(value) ~= nil or seen[value] then return nil end
    seen[value] = true
    local keys = {}
    local array = true
    local count = 0
    for key in pairs(value) do
        count = count + 1
        if type(key) ~= 'number' or key < 1 or key % 1 ~= 0 then array = false end
        keys[#keys + 1] = key
    end
    if array then
        for index = 1, count do if value[index] == nil then array = false break end end
    end
    local parts = {}
    if array then
        for index = 1, count do
            local encoded = Canonical(value[index], seen)
            if not encoded then seen[value] = nil return nil end
            parts[#parts + 1] = encoded
        end
        seen[value] = nil
        return '[' .. table.concat(parts, ',') .. ']'
    end
    for _, key in ipairs(keys) do
        if type(key) ~= 'string' then seen[value] = nil return nil end
    end
    table.sort(keys)
    for _, key in ipairs(keys) do
        local encoded = Canonical(value[key], seen)
        if not encoded then seen[value] = nil return nil end
        parts[#parts + 1] = json.encode(key) .. ':' .. encoded
    end
    seen[value] = nil
    return '{' .. table.concat(parts, ',') .. '}'
end

local function Digest(draft, document)
    local content = table.concat({
        draft.firstName, draft.lastName, draft.dateOfBirth, draft.model,
        draft.spawnPointId, draft.description, document
    }, '\n')
    local digest = MySQL.scalar.await('SELECT SHA2(?, 256)', { content })
    if type(digest) ~= 'string' or #digest ~= 64 then return nil end
    return digest
end

function CharacterV2Profiles.Create(accountId, requestKey, input)
    if not Uuid(accountId) or not RequestKey(requestKey) then
        return CharacterV2Result.Err('invalid_input', 'Account and request identity are required.')
    end
    if type(input) ~= 'table' then
        return CharacterV2Result.Err('invalid_input', 'Character data is required.')
    end
    local appearance = CharacterV2Draft.SanitizeAppearance(input.model, input.appearance)
    if not appearance.ok then return appearance end
    -- Catalog-constrained creation: known base components and expression
    -- hair, and facial-overlay values are accepted; clothes and tints remain
    -- owned by the server until their individual catalog gate is implemented.
    local checked = CharacterV2Draft.Validate({
        firstName = input.firstName, lastName = input.lastName,
        dateOfBirth = input.dateOfBirth, model = input.model,
        description = input.description, spawnPointId = input.spawnPointId,
        appearance = appearance.value
    })
    if not checked.ok then return checked end
    local draft = checked.value
    local document = Canonical(draft.appearance, {})
    if document and #document > CharacterV2Config.appearance.maxDocumentBytes then document = nil end
    if not document then
        return CharacterV2Result.Err('invalid_appearance', 'The appearance document is too large or invalid.')
    end
    local digest = Digest(draft, document)
    if not digest then
        return CharacterV2Result.Err('database_unavailable', 'Request verification is unavailable.')
    end

    local bodyResult, bodyError
    local called, committed = pcall(MySQL.startTransaction, function(query)
        local executed, result = pcall(function()
            query('INSERT INTO `fc2_accounts` (`account_id`) VALUES (?) ON DUPLICATE KEY UPDATE `account_id` = VALUES(`account_id`)', { accountId })
            query('SELECT `account_id` FROM `fc2_accounts` WHERE `account_id` = ? FOR UPDATE', { accountId })
            query([[
                INSERT IGNORE INTO `fc2_creation_requests`
                    (`account_id`, `request_key`, `payload_digest`, `status`)
                VALUES (?, ?, ?, 'pending')
            ]], { accountId, requestKey, digest })
            local requests = query([[
                SELECT `payload_digest`, `status`, `character_id`
                FROM `fc2_creation_requests`
                WHERE `account_id` = ? AND `request_key` = ? FOR UPDATE
            ]], { accountId, requestKey }) or {}
            local request = requests[1]
            if not request then
                return CharacterV2Result.Err('database_unavailable', 'Creation request could not be locked.')
            end
            if request.payload_digest ~= digest then
                return CharacterV2Result.Err('idempotency_conflict',
                    'This request key was already used with different character data.')
            end
            if request.status == 'completed' and Uuid(request.character_id) then
                return CharacterV2Result.Ok({ characterId = request.character_id, idempotent = true })
            end
            if request.status ~= 'pending' or request.character_id ~= nil then
                return CharacterV2Result.Err('creation_conflict', 'Creation request is inconsistent.')
            end

            local counts = query([[
                SELECT COUNT(*) AS `total` FROM `fc2_characters`
                WHERE `account_id` = ? AND `status` = 'active'
            ]], { accountId }) or {}
            if (tonumber(counts[1] and counts[1].total) or 0) >= CharacterV2Config.maxCharacters then
                return CharacterV2Result.Err('character_limit', 'This account has reached its character limit.')
            end
            local uuids = query('SELECT UUID() AS `character_id`') or {}
            local characterId = uuids[1] and uuids[1].character_id
            if not Uuid(characterId) then
                return CharacterV2Result.Err('database_unavailable', 'Character identity could not be generated.')
            end
            query([[
                INSERT INTO `fc2_characters`
                    (`character_id`, `account_id`, `first_name`, `last_name`, `date_of_birth`,
                     `model`, `description`, `status`)
                VALUES (?, ?, ?, ?, ?, ?, ?, 'active')
            ]], { characterId, accountId, draft.firstName, draft.lastName,
                draft.dateOfBirth, draft.model, draft.description })
            query([[
                INSERT INTO `fc2_appearances`
                    (`character_id`, `schema_version`, `revision`, `document`)
                VALUES (?, ?, 1, ?)
            ]], { characterId, CharacterV2Config.appearance.schemaVersion, document })
            query([[
                INSERT INTO `fc2_spawn_states`
                    (`character_id`, `mode`, `spawn_point_id`)
                VALUES (?, 'first_spawn', ?)
            ]], { characterId, draft.spawnPointId })
            query([[
                UPDATE `fc2_creation_requests`
                SET `status` = 'completed', `character_id` = ?
                WHERE `account_id` = ? AND `request_key` = ?
            ]], { characterId, accountId, requestKey })
            return CharacterV2Result.Ok({ characterId = characterId, idempotent = false })
        end)
        if not executed then bodyError = tostring(result) return false end
        bodyResult = result
        return type(result) == 'table' and result.ok == true
    end)
    if not called then
        print(('[feather-character-v2] create transaction failed: %s'):format(tostring(committed)))
        return CharacterV2Result.Err('database_unavailable', 'Character creation could not start.')
    end
    if committed ~= true then
        if type(bodyResult) == 'table' and bodyResult.ok == false then return bodyResult end
        print(('[feather-character-v2] create rolled back: %s'):format(tostring(bodyError)))
        return CharacterV2Result.Err('database_unavailable', 'Character creation rolled back.')
    end
    return bodyResult
end

function CharacterV2Profiles.UpdatePosition(accountId, characterId, position)
    if not Uuid(accountId) or not Uuid(characterId) or type(position) ~= 'table' then
        return CharacterV2Result.Err('invalid_input', 'Account, character, and position are required.')
    end
    local function Finite(value)
        return type(value) == 'number' and value == value and value ~= math.huge and value ~= -math.huge
    end
    local x, y, z, heading = position.x, position.y, position.z, position.heading
    if not Finite(x) or not Finite(y) or not Finite(z) or not Finite(heading)
        or math.abs(x) > 20000 or math.abs(y) > 20000 or z < -1000 or z > 3000
        or heading < -360 or heading > 360 then
        return CharacterV2Result.Err('position_invalid', 'Character position is outside world bounds.')
    end
    local changed = MySQL.update.await([[
        UPDATE `fc2_spawn_states` s
        INNER JOIN `fc2_characters` c ON c.`character_id` = s.`character_id`
        SET s.`mode` = 'last_position', s.`position_x` = ?, s.`position_y` = ?,
            s.`position_z` = ?, s.`heading` = ?, s.`revision` = s.`revision` + 1
        WHERE s.`character_id` = ? AND c.`account_id` = ? AND c.`status` = 'active'
    ]], { x, y, z, heading, characterId, accountId })
    if tonumber(changed) ~= 1 then return CharacterV2Result.Err('not_found', 'Character was not found.') end
    return CharacterV2Result.Ok(true)
end

function CharacterV2Profiles.List(accountId)
    if not Uuid(accountId) then
        return CharacterV2Result.Err('invalid_input', 'Account identity is required.')
    end
    local rows = MySQL.query.await([[
        SELECT `character_id`, `first_name`, `last_name`, `date_of_birth`,
               `model`, `description`, `status`
        FROM `fc2_characters`
        WHERE `account_id` = ? AND `status` = 'active'
        ORDER BY `created_at`, `character_id`
    ]], { accountId }) or {}
    local profiles = {}
    for index, row in ipairs(rows) do profiles[index] = PublicProfile(row) end
    return CharacterV2Result.Ok(profiles)
end

function CharacterV2Profiles.Delete(accountId, characterId)
    if not Uuid(accountId) or not Uuid(characterId) then
        return CharacterV2Result.Err('invalid_input',
            'Account and character identities are required.')
    end
    local changed = MySQL.update.await([[
        UPDATE `fc2_characters`
        SET `status` = 'deleted', `deleted_at` = CURRENT_TIMESTAMP(3)
        WHERE `account_id` = ? AND `character_id` = ? AND `status` = 'active'
    ]], { accountId, characterId })
    if tonumber(changed) ~= 1 then
        return CharacterV2Result.Err('not_found', 'Character was not found.')
    end
    return CharacterV2Result.Ok({ characterId = characterId, deleted = true })
end

function CharacterV2Profiles.Get(accountId, characterId)
    if not Uuid(accountId) or not Uuid(characterId) then
        return CharacterV2Result.Err('invalid_input', 'Account and character identities are required.')
    end
    local row = MySQL.single.await([[
        SELECT `character_id`, `first_name`, `last_name`, `date_of_birth`,
               `model`, `description`, `status`
        FROM `fc2_characters`
        WHERE `account_id` = ? AND `character_id` = ? AND `status` = 'active'
        LIMIT 1
    ]], { accountId, characterId })
    if not row then return CharacterV2Result.Err('not_found', 'Character was not found.') end
    return CharacterV2Result.Ok(PublicProfile(row))
end

function CharacterV2Profiles.GetAppearance(accountId, characterId)
    if not Uuid(accountId) or not Uuid(characterId) then
        return CharacterV2Result.Err('invalid_input', 'Account and character identities are required.')
    end
    local row = MySQL.single.await([[
        SELECT a.`schema_version`, a.`revision`, a.`document`, c.`model`
        FROM `fc2_appearances` a
        INNER JOIN `fc2_characters` c ON c.`character_id` = a.`character_id`
        WHERE c.`account_id` = ? AND c.`character_id` = ? AND c.`status` = 'active'
        LIMIT 1
    ]], { accountId, characterId })
    if not row then return CharacterV2Result.Err('not_found', 'Appearance was not found.') end
    local schemaVersion = tonumber(row.schema_version)
    local decoded, document = pcall(json.decode, row.document)
    if not decoded or type(document) ~= 'table' then
        return CharacterV2Result.Err('invalid_appearance', 'Saved appearance is invalid.')
    end
    -- Schemas 1-2 were pre-customization live probes. They carried either the
    -- wrong starter outfit or male base components in the female document.
    -- Normalize those test records without mutating their stored rows.
    if schemaVersion and schemaVersion < CharacterV2Config.appearance.schemaVersion then
        document = row.model == 'mp_female' and CharacterV2Defaults.Female
            or CharacterV2Defaults.Male
        schemaVersion = CharacterV2Config.appearance.schemaVersion
    end
    -- Remove the briefly shipped test accessory that rendered as a chrome
    -- canteen. This exact rejected hash is not part of the supported default;
    -- keep the actual gunbelt and its built-in holster intact.
    if type(document.clothing) == 'table'
        and document.clothing.GunbeltAccs == -1313955174 then
        document.clothing.GunbeltAccs = nil
    end
    return CharacterV2Result.Ok({
        schemaVersion = schemaVersion,
        revision = tonumber(row.revision),
        document = document
    })
end

function CharacterV2Profiles.GetSpawnState(accountId, characterId)
    if not Uuid(accountId) or not Uuid(characterId) then
        return CharacterV2Result.Err('invalid_input', 'Account and character identities are required.')
    end
    local row = MySQL.single.await([[
        SELECT s.`mode`, s.`spawn_point_id`, s.`position_x`, s.`position_y`,
               s.`position_z`, s.`heading`, s.`revision`
        FROM `fc2_spawn_states` s
        INNER JOIN `fc2_characters` c ON c.`character_id` = s.`character_id`
        WHERE c.`account_id` = ? AND c.`character_id` = ? AND c.`status` = 'active'
        LIMIT 1
    ]], { accountId, characterId })
    if not row then return CharacterV2Result.Err('not_found', 'Spawn state was not found.') end
    return CharacterV2Result.Ok({
        mode = row.mode, spawnPointId = row.spawn_point_id,
        position = row.position_x and {
            x = tonumber(row.position_x), y = tonumber(row.position_y),
            z = tonumber(row.position_z), heading = tonumber(row.heading)
        } or nil,
        revision = tonumber(row.revision)
    })
end

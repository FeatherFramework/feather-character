CharacterProfiles = {}

local function Copy(value)
    if type(value) ~= 'table' then return value end
    local output = {}
    for key, child in pairs(value) do output[key] = Copy(child) end
    return output
end

local function Snapshot(row)
    if not row then return nil end
    return {
        characterId = row.character_id,
        firstName = row.first_name,
        lastName = row.last_name,
        dateOfBirth = tostring(row.date_of_birth),
        model = row.model,
        description = row.description,
        portraitUrl = row.portrait_url,
        status = row.status,
        createdAt = tostring(row.created_at),
        updatedAt = tostring(row.updated_at)
    }
end

local function ValidateId(value, name)
    if type(value) ~= 'string' or not value:match('^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$') then
        return CharacterResults.Err('invalid_input', ('%s must be a UUID.'):format(name))
    end
    return CharacterResults.Ok(value)
end

function CharacterProfiles.List(accountId)
    local valid = ValidateId(accountId, 'accountId')
    if not valid.ok then return valid end
    local rows = MySQL.query.await([[
        SELECT `character_id`, `first_name`, `last_name`,
               DATE_FORMAT(`date_of_birth`, '%m/%d/%Y') AS `date_of_birth`, `model`,
               `description`, `portrait_url`, `status`, `created_at`, `updated_at`
        FROM `character_profiles`
        WHERE `account_id` = ? AND `status` = 'active'
        ORDER BY `created_at`, `character_id`
    ]], { accountId }) or {}
    local profiles = {}
    for index, row in ipairs(rows) do profiles[index] = Snapshot(row) end
    return CharacterResults.Ok(profiles)
end

function CharacterProfiles.Get(characterId)
    local valid = ValidateId(characterId, 'characterId')
    if not valid.ok then return valid end
    local rows = MySQL.query.await([[
        SELECT `character_id`, `first_name`, `last_name`,
               DATE_FORMAT(`date_of_birth`, '%m/%d/%Y') AS `date_of_birth`, `model`,
               `description`, `portrait_url`, `status`, `created_at`, `updated_at`
        FROM `character_profiles` WHERE `character_id` = ? LIMIT 1
    ]], { characterId }) or {}
    if not rows[1] then return CharacterResults.Err('not_found', 'Character was not found.') end
    return CharacterResults.Ok(Snapshot(rows[1]))
end

function CharacterProfiles.Owns(accountId, characterId)
    local account = ValidateId(accountId, 'accountId')
    if not account.ok then return account end
    local character = ValidateId(characterId, 'characterId')
    if not character.ok then return character end
    local count = tonumber(MySQL.scalar.await([[
        SELECT COUNT(*) FROM `character_profiles`
        WHERE `account_id` = ? AND `character_id` = ? AND `status` = 'active'
    ]], { accountId, characterId })) or 0
    return CharacterResults.Ok({ owned = count == 1 })
end

function CharacterProfiles.Create(accountId, input, idempotencyKey)
    local account = ValidateId(accountId, 'accountId')
    if not account.ok then return account end
    if type(input) ~= 'table' then return CharacterResults.Err('invalid_input', 'Character input must be a table.') end
    if type(idempotencyKey) ~= 'string' or idempotencyKey == '' or #idempotencyKey > 100
        or not idempotencyKey:match('^[%w%._:%-]+$') then
        return CharacterResults.Err('invalid_input', 'A valid idempotency key is required.')
    end
    if type(input.firstName) ~= 'string' or input.firstName == '' or #input.firstName > Config.Character.maxFirstNameLength then
        return CharacterResults.Err('name_invalid', 'First name is invalid.')
    end
    if type(input.lastName) ~= 'string' or input.lastName == '' or #input.lastName > Config.Character.maxLastNameLength then
        return CharacterResults.Err('name_invalid', 'Last name is invalid.')
    end
    if type(input.model) ~= 'string' or not Config.Character.allowedModels[input.model] then
        return CharacterResults.Err('model_invalid', 'Character model is invalid.')
    end
    if type(input.dateOfBirth) ~= 'string' or not input.dateOfBirth:match('^%d%d%d%d%-%d%d%-%d%d$')
        or input.dateOfBirth < Config.defaults.dob.min or input.dateOfBirth > Config.defaults.dob.max then
        return CharacterResults.Err('date_invalid', 'Date of birth is invalid.')
    end
    if input.description ~= nil and (type(input.description) ~= 'string'
        or #input.description > Config.Character.maxDescLength) then
        return CharacterResults.Err('invalid_input', 'Character description is invalid.')
    end
    if input.portraitUrl ~= nil and (type(input.portraitUrl) ~= 'string'
        or #input.portraitUrl > Config.Character.maxImgLength
        or not input.portraitUrl:match('^https?://')) then
        return CharacterResults.Err('invalid_input', 'Character portrait URL is invalid.')
    end
    if input.spawnPointId ~= nil and (type(input.spawnPointId) ~= 'string'
        or input.spawnPointId == '' or #input.spawnPointId > 64) then
        return CharacterResults.Err('spawn_invalid', 'Character spawn point is invalid.')
    end
    if input.appearance ~= nil and type(input.appearance) ~= 'table' then
        return CharacterResults.Err('appearance_invalid', 'Character appearance must be a table.')
    end
    local appearance = Copy(input.appearance or {})
    appearance.attributes = type(appearance.attributes) == 'table' and appearance.attributes or {}
    local gender = input.model == 'mp_female' and 'Female' or 'Male'
    local hairCatalog = HairandBeards and HairandBeards[gender]
    local defaultHair = hairCatalog and hairCatalog.hair and hairCatalog.hair[1] and hairCatalog.hair[1][1]
    if appearance.attributes.hairCategory == nil and appearance.attributes.hairVariant == nil then
        if not defaultHair or not defaultHair.hash then
            return CharacterResults.Err('appearance_invalid', 'The default hair definition is unavailable.')
        end
        appearance.attributes.hairCategory = { hash = defaultHair.hash }
        appearance.attributes.hairVariant = { hash = defaultHair.hash }
    end
    if CharacterAppearance and CharacterAppearance.Validate then
        local appearanceValidation = CharacterAppearance.Validate(appearance)
        if not appearanceValidation.ok then return appearanceValidation end
    end
    local appearanceEncoded, appearanceDocument = pcall(json.encode, appearance)
    if not appearanceEncoded or type(appearanceDocument) ~= 'string'
        or #appearanceDocument > Config.Contract1.appearance.maxDocumentBytes then
        return CharacterResults.Err('appearance_invalid', 'Character appearance document is invalid or too large.')
    end

    local bodyResult, bodyError
    local called, committed = pcall(MySQL.startTransaction, function(query)
        local ok, result = pcall(function()
            query([[
                INSERT IGNORE INTO `character_creation_requests`
                    (`account_id`, `idempotency_key`, `status`) VALUES (?, ?, 'pending')
            ]], { accountId, idempotencyKey })
            local requestRows = query([[
                SELECT `character_id`, `status` FROM `character_creation_requests`
                WHERE `account_id` = ? AND `idempotency_key` = ? FOR UPDATE
            ]], { accountId, idempotencyKey })
            local request = requestRows and requestRows[1]
            if not request then
                return CharacterResults.Err('internal_error', 'Character creation request could not be locked.')
            end
            if request.status == 'completed' and request.character_id then
                return CharacterResults.Ok({ characterId = request.character_id, idempotent = true })
            end

            query('INSERT INTO `character_account_state` (`account_id`) VALUES (?) ON DUPLICATE KEY UPDATE `account_id` = VALUES(`account_id`)', { accountId })
            query('SELECT `account_id` FROM `character_account_state` WHERE `account_id` = ? FOR UPDATE', { accountId })
            local countRows = query("SELECT COUNT(*) AS `count` FROM `character_profiles` WHERE `account_id` = ? AND `status` <> 'deleted'", { accountId })
            local count = tonumber(countRows and countRows[1] and countRows[1].count) or 0
            if count >= Config.MaxAllowedChars then
                return CharacterResults.Err('character_limit', 'This account has reached its character limit.', {
                    limit = Config.MaxAllowedChars
                })
            end
            local uuidRows = query('SELECT UUID() AS `character_id`')
            local characterId = uuidRows and uuidRows[1] and uuidRows[1].character_id
            if not characterId then return CharacterResults.Err('internal_error', 'Character ID could not be generated.') end
            query([[
                INSERT INTO `character_profiles`
                    (`character_id`, `account_id`, `first_name`, `last_name`, `date_of_birth`, `model`, `description`, `portrait_url`)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ]], { characterId, accountId, input.firstName, input.lastName, input.dateOfBirth, input.model,
                input.description, input.portraitUrl })
            query([[
                INSERT INTO `character_appearance_documents`
                    (`character_id`, `schema_version`, `revision`, `document`) VALUES (?, 1, 1, ?)
            ]], { characterId, appearanceDocument })
            query([[
                INSERT INTO `character_spawn_state`
                    (`character_id`, `mode`, `spawn_point_id`) VALUES (?, 'first_spawn', ?)
            ]], { characterId, input.spawnPointId })
            query([[
                UPDATE `character_creation_requests`
                SET `character_id` = ?, `status` = 'completed'
                WHERE `account_id` = ? AND `idempotency_key` = ?
            ]], { characterId, accountId, idempotencyKey })
            return CharacterResults.Ok({ characterId = characterId, idempotent = false })
        end)
        if not ok then bodyError = tostring(result) return false end
        bodyResult = result
        return CharacterResults.Is(result) and result.ok
    end)

    if not called then
        return CharacterResults.Err('internal_error', 'Character transaction could not start.', { reason = tostring(committed) })
    end
    if committed ~= true then
        if CharacterResults.Is(bodyResult) then return bodyResult end
        return CharacterResults.Err('internal_error', 'Character transaction failed.', { reason = bodyError })
    end
    return Copy(bodyResult)
end

function CharacterProfiles.SoftDelete(accountId, characterId, confirmed, activeCharacterId)
    local account = ValidateId(accountId, 'accountId')
    if not account.ok then return account end
    local character = ValidateId(characterId, 'characterId')
    if not character.ok then return character end
    if activeCharacterId == characterId then
        return CharacterResults.Err('character_active', 'The active character cannot be deleted.')
    end
    if Config.Character.deletion.requireConfirmation and confirmed ~= true then
        return CharacterResults.Err('confirmation_invalid', 'Character deletion must be confirmed.')
    end

    local bodyResult, bodyError
    local called, committed = pcall(MySQL.startTransaction, function(query)
        local ok, result = pcall(function()
            query('INSERT INTO `character_account_state` (`account_id`) VALUES (?) ON DUPLICATE KEY UPDATE `account_id` = VALUES(`account_id`)', { accountId })
            query('SELECT `account_id` FROM `character_account_state` WHERE `account_id` = ? FOR UPDATE', { accountId })
            local rows = query([[
                SELECT `status`, `created_at`
                FROM `character_profiles`
                WHERE `account_id` = ? AND `character_id` = ? FOR UPDATE
            ]], { accountId, characterId })
            local row = rows and rows[1]
            if not row or row.status ~= 'active' then
                return CharacterResults.Err('not_found', 'Character was not found.')
            end
            local minimumAgeHours = Config.Character.deletion.minimumAgeHours
            if minimumAgeHours > 0 then
                local ageRows = query('SELECT TIMESTAMPDIFF(HOUR, ?, CURRENT_TIMESTAMP(3)) AS `hours`', { row.created_at })
                local ageHours = tonumber(ageRows and ageRows[1] and ageRows[1].hours) or 0
                if ageHours < minimumAgeHours then
                    return CharacterResults.Err('deletion_cooldown', 'This character is too new to delete.', {
                        minimumAgeHours = minimumAgeHours, currentAgeHours = ageHours
                    })
                end
            end
            local changed = query([[
                UPDATE `character_profiles` SET `status` = 'deleted'
                WHERE `account_id` = ? AND `character_id` = ? AND `status` = 'active'
            ]], { accountId, characterId })
            local affected = type(changed) == 'table' and tonumber(changed.affectedRows) or tonumber(changed)
            if affected ~= 1 then
                return CharacterResults.Err('conflict', 'Character deletion conflicted with another operation.')
            end
            return CharacterResults.Ok({
                characterId = characterId,
                deleted = true,
                recoveryDays = Config.Character.deletion.recoveryDays
            })
        end)
        if not ok then bodyError = tostring(result) return false end
        bodyResult = result
        return CharacterResults.Is(result) and result.ok
    end)

    if not called then
        return CharacterResults.Err('internal_error', 'Character deletion transaction could not start.', {
            reason = tostring(committed)
        })
    end
    if committed ~= true then
        if CharacterResults.Is(bodyResult) then return bodyResult end
        return CharacterResults.Err('internal_error', 'Character deletion transaction failed.', { reason = bodyError })
    end
    return Copy(bodyResult)
end

function CharacterProfiles.DeleteForTest(accountId)
    MySQL.query.await('DELETE FROM `character_creation_requests` WHERE `account_id` = ?', { accountId })
    MySQL.query.await('DELETE FROM `character_profiles` WHERE `account_id` = ?', { accountId })
    MySQL.query.await('DELETE FROM `character_account_state` WHERE `account_id` = ?', { accountId })
end

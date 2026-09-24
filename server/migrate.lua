-- Called during first-playable startup; failure keeps the resource unhealthy.
CharacterV2Migration = {}

local ledgerStatement = [[
    CREATE TABLE IF NOT EXISTS `fc2_schema_migrations` (
        `version` INT UNSIGNED NOT NULL,
        `checksum` CHAR(64) NOT NULL,
        `applied_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
        PRIMARY KEY (`version`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
]]

function CharacterV2Migration.Run()
    local success, outcome = xpcall(function()
        local schema = CharacterV2Schema
        if type(schema) ~= 'table' or type(schema.version) ~= 'number'
            or type(schema.statements) ~= 'table' or #schema.statements == 0 then
            return CharacterV2Result.Err('invalid_schema', 'The v2 schema definition is incomplete.')
        end
        local checksum = MySQL.scalar.await('SELECT SHA2(?, 256)', {
            table.concat(schema.statements, '\n-- statement boundary --\n')
        })
        if type(checksum) ~= 'string' or #checksum ~= 64 then
            return CharacterV2Result.Err('checksum_unavailable', 'The schema checksum could not be computed.')
        end

        MySQL.query.await(ledgerStatement)
        local rows = MySQL.query.await(
            'SELECT `version`, `checksum` FROM `fc2_schema_migrations` WHERE `version` = ? LIMIT 1',
            { schema.version }
        ) or {}
        if rows[1] then
            if rows[1].checksum ~= checksum then
                return CharacterV2Result.Err('schema_drift',
                    'The installed v2 schema differs from the checked-in definition.')
            end
            return CharacterV2Result.Ok({ version = schema.version, applied = false })
        end

        -- MySQL DDL is not rolled back like ordinary row writes. Each table
        -- definition is idempotent, and the ledger is inserted only afterward.
        for _, statement in ipairs(schema.statements) do MySQL.query.await(statement) end
        MySQL.insert.await(
            'INSERT INTO `fc2_schema_migrations` (`version`, `checksum`) VALUES (?, ?)',
            { schema.version, checksum }
        )
        return CharacterV2Result.Ok({ version = schema.version, applied = true })
    end, debug.traceback)
    if success then return outcome end
    print(('[feather-character-v2] migration failed: %s'):format(tostring(outcome)))
    return CharacterV2Result.Err('migration_failed', 'The v2 schema migration failed.')
end

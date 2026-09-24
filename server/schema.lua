-- New table namespace. Startup applies these definitions only after the old
-- Character resource has been stopped. Existing Character tables are untouched.
CharacterV2Schema = {
    version = 1,
    statements = {
        [[
            CREATE TABLE IF NOT EXISTS `fc2_accounts` (
                `account_id` CHAR(36) NOT NULL,
                `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
                PRIMARY KEY (`account_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `fc2_characters` (
                `character_id` CHAR(36) NOT NULL,
                `account_id` CHAR(36) NOT NULL,
                `first_name` VARCHAR(24) NOT NULL,
                `last_name` VARCHAR(24) NOT NULL,
                `date_of_birth` DATE NOT NULL,
                `model` VARCHAR(16) NOT NULL,
                `description` VARCHAR(512) NOT NULL DEFAULT '',
                `status` VARCHAR(16) NOT NULL DEFAULT 'active',
                `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
                `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                `deleted_at` DATETIME(3) NULL,
                PRIMARY KEY (`character_id`),
                KEY `idx_fc2_characters_account_status` (`account_id`, `status`),
                CONSTRAINT `fk_fc2_characters_account` FOREIGN KEY (`account_id`)
                    REFERENCES `fc2_accounts` (`account_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `fc2_appearances` (
                `character_id` CHAR(36) NOT NULL,
                `schema_version` INT UNSIGNED NOT NULL,
                `revision` BIGINT UNSIGNED NOT NULL DEFAULT 1,
                `document` LONGTEXT NOT NULL,
                `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                PRIMARY KEY (`character_id`),
                CONSTRAINT `fk_fc2_appearances_character` FOREIGN KEY (`character_id`)
                    REFERENCES `fc2_characters` (`character_id`) ON DELETE CASCADE,
                CONSTRAINT `chk_fc2_appearances_json` CHECK (JSON_VALID(`document`))
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `fc2_spawn_states` (
                `character_id` CHAR(36) NOT NULL,
                `mode` VARCHAR(24) NOT NULL DEFAULT 'first_spawn',
                `spawn_point_id` VARCHAR(64) NOT NULL,
                `position_x` DOUBLE NULL,
                `position_y` DOUBLE NULL,
                `position_z` DOUBLE NULL,
                `heading` DOUBLE NULL,
                `revision` BIGINT UNSIGNED NOT NULL DEFAULT 1,
                `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                PRIMARY KEY (`character_id`),
                CONSTRAINT `fk_fc2_spawn_character` FOREIGN KEY (`character_id`)
                    REFERENCES `fc2_characters` (`character_id`) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `fc2_creation_requests` (
                `account_id` CHAR(36) NOT NULL,
                `request_key` VARCHAR(96) NOT NULL,
                `payload_digest` CHAR(64) NOT NULL,
                `status` VARCHAR(16) NOT NULL DEFAULT 'pending',
                `character_id` CHAR(36) NULL,
                `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
                PRIMARY KEY (`account_id`, `request_key`),
                KEY `idx_fc2_creation_character` (`character_id`),
                CONSTRAINT `fk_fc2_creation_character` FOREIGN KEY (`character_id`)
                    REFERENCES `fc2_characters` (`character_id`) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]]
    }
}

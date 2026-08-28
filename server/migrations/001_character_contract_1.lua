CharacterMigrationDefinitions = CharacterMigrationDefinitions or {}

CharacterMigrationDefinitions[#CharacterMigrationDefinitions + 1] = {
    id = '001_character_contract_1',
    statements = {
        [[
            CREATE TABLE IF NOT EXISTS `character_account_state` (
                `account_id` CHAR(36) NOT NULL,
                `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
                `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                PRIMARY KEY (`account_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `character_profiles` (
                `character_id` CHAR(36) NOT NULL,
                `account_id` CHAR(36) NOT NULL,
                `first_name` VARCHAR(24) NOT NULL,
                `last_name` VARCHAR(24) NOT NULL,
                `date_of_birth` DATE NOT NULL,
                `model` VARCHAR(64) NOT NULL,
                `description` VARCHAR(512) NULL,
                `portrait_url` VARCHAR(256) NULL,
                `status` VARCHAR(24) NOT NULL DEFAULT 'active',
                `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
                `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                PRIMARY KEY (`character_id`),
                KEY `idx_character_profiles_account_status` (`account_id`, `status`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `character_appearance_documents` (
                `character_id` CHAR(36) NOT NULL,
                `schema_version` INT UNSIGNED NOT NULL DEFAULT 1,
                `revision` BIGINT UNSIGNED NOT NULL DEFAULT 1,
                `document` LONGTEXT NOT NULL,
                `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
                `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                PRIMARY KEY (`character_id`),
                CONSTRAINT `fk_character_appearance_profile`
                    FOREIGN KEY (`character_id`) REFERENCES `character_profiles` (`character_id`) ON DELETE CASCADE,
                CONSTRAINT `chk_character_appearance_json` CHECK (JSON_VALID(`document`))
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]],
        [[
            CREATE TABLE IF NOT EXISTS `character_spawn_state` (
                `character_id` CHAR(36) NOT NULL,
                `mode` VARCHAR(24) NOT NULL DEFAULT 'first_spawn',
                `spawn_point_id` VARCHAR(64) NULL,
                `position_x` DOUBLE NULL,
                `position_y` DOUBLE NULL,
                `position_z` DOUBLE NULL,
                `heading` DOUBLE NULL,
                `revision` BIGINT UNSIGNED NOT NULL DEFAULT 1,
                `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
                `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                PRIMARY KEY (`character_id`),
                CONSTRAINT `fk_character_spawn_profile`
                    FOREIGN KEY (`character_id`) REFERENCES `character_profiles` (`character_id`) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]]
    }
}

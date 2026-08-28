CharacterMigrationDefinitions = CharacterMigrationDefinitions or {}

CharacterMigrationDefinitions[#CharacterMigrationDefinitions + 1] = {
    id = '002_character_creation_requests',
    statements = {
        [[
            CREATE TABLE IF NOT EXISTS `character_creation_requests` (
                `account_id` CHAR(36) NOT NULL,
                `idempotency_key` VARCHAR(100) NOT NULL,
                `character_id` CHAR(36) NULL,
                `status` VARCHAR(24) NOT NULL DEFAULT 'pending',
                `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
                `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
                PRIMARY KEY (`account_id`, `idempotency_key`),
                KEY `idx_character_creation_character` (`character_id`),
                CONSTRAINT `fk_character_creation_profile`
                    FOREIGN KEY (`character_id`) REFERENCES `character_profiles` (`character_id`) ON DELETE SET NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]]
    }
}

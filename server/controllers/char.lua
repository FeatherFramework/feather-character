CharControllers = {}

function CharControllers.GetCharApperanceData(charId)
    local result = MySQL.query.await("SELECT * FROM character_appearance WHERE id = ?", { charId })
    return result[1]
end

-- (CHAR-08) Was a plain INSERT -- `character_appearance.id` is the PRIMARY
-- KEY (one row per character, FK to `characters.id`), so this only ever
-- worked once, right after creation. Any later appearance save for the same
-- character (a barber, tailor, mirror, ...) threw a duplicate-key error
-- instead of updating the row. Upsert instead.
function CharControllers.UpdateCharApperanceData(charId, attributes, clothing, overlays)
    MySQL.query.await(
        "INSERT INTO character_appearance (`id`, `attributes`, `clothing`, `overlays`) VALUES (?, ?, ?, ?) " ..
        "ON DUPLICATE KEY UPDATE `attributes` = VALUES(`attributes`), `clothing` = VALUES(`clothing`), `overlays` = VALUES(`overlays`)",
        { charId, attributes, clothing, overlays })
end

-- (CHAR-07) `ORDER BY user_id DESC` on rows already filtered to a single
-- `user_id` sorts nothing -- every row has the same value, so the result
-- order was effectively whatever MySQL felt like returning, not creation
-- order. `result[#result].id` (last row) was relied on by SaveCharacterData
-- to identify the character that was *just* created; on a user with
-- multiple existing characters this could return the wrong character's id,
-- and the caller then writes appearance data (CHAR-08's UpdateAttributeDB)
-- onto that wrong, pre-existing character. Order by `id DESC` (actual
-- creation order for an AUTO_INCREMENT PK) and take the first row instead.
function CharControllers.GetCharIdFromUserId(userId)
    local result = MySQL.query.await("SELECT id FROM characters WHERE user_id = ? ORDER BY id DESC LIMIT 1", { userId })
    return result[1] and result[1].id or nil
end
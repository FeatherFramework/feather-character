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

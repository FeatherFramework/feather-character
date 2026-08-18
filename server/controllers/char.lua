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
-- (CHAR-20) `clothingtints` (feather-recipe's migration.sql) already
-- existed as its own column and was simply never included in this
-- INSERT/UPDATE -- a dye picked in clothing_pages.lua applied live and was
-- silently dropped on the next save. `tints` defaults to '{}' the same way
-- the column itself does, so older callers that don't pass it still work.
function CharControllers.UpdateCharApperanceData(charId, attributes, clothing, overlays, tints)
    MySQL.query.await(
        "INSERT INTO character_appearance (`id`, `attributes`, `clothing`, `overlays`, `clothingtints`) VALUES (?, ?, ?, ?, ?) " ..
        "ON DUPLICATE KEY UPDATE `attributes` = VALUES(`attributes`), `clothing` = VALUES(`clothing`), `overlays` = VALUES(`overlays`), `clothingtints` = VALUES(`clothingtints`)",
        { charId, attributes, clothing, overlays, tints or '{}' })
end

CharControllers = {}

function CharControllers.GetCharApperanceData(charId)
    local result = MySQL.query.await("SELECT * FROM character_appearance WHERE id = ?", { charId })
    return result[1]
end

function CharControllers.UpdateCharApperanceData(charId, attributes, clothing, overlays)
    MySQL.query.await( "INSERT INTO character_appearance (`id`, `attributes`, `clothing`,`overlays`) VALUES (?, ?, ?, ?)", { charId, attributes, clothing, overlays })
end

function CharControllers.GetCharIdFromUserId(userId)
    local result = MySQL.query.await("SELECT id FROM characters WHERE user_id = ? ORDER BY user_id DESC", { userId })
    return result[#result].id
end
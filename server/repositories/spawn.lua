CharacterSpawn = {}

function CharacterSpawn.Get(characterId)
    if type(characterId) ~= 'string' then
        return CharacterResults.Err('invalid_input', 'characterId is required.')
    end
    local rows = MySQL.query.await([[
        SELECT s.`character_id`, s.`mode`, s.`spawn_point_id`, s.`position_x`, s.`position_y`,
               s.`position_z`, s.`heading`, s.`revision`, s.`updated_at`
        FROM `character_spawn_state` s
        INNER JOIN `character_profiles` p ON p.`character_id` = s.`character_id`
        WHERE s.`character_id` = ? AND p.`status` = 'active' LIMIT 1
    ]], { characterId }) or {}
    local row = rows[1]
    if not row then return CharacterResults.Err('not_found', 'Character spawn state was not found.') end
    return CharacterResults.Ok({
        characterId = row.character_id,
        mode = row.mode,
        spawnPointId = row.spawn_point_id,
        position = row.position_x and {
            x = tonumber(row.position_x), y = tonumber(row.position_y), z = tonumber(row.position_z),
            heading = tonumber(row.heading) or 0.0
        } or nil,
        revision = tonumber(row.revision),
        updatedAt = tostring(row.updated_at)
    })
end

function CharacterSpawn.BuildPlan(characterId, sessionId)
    local state = CharacterSpawn.Get(characterId)
    if not state.ok then return state end
    local value = state.value
    local position
    if value.mode == 'last_position' and value.position then
        position = value.position
    else
        local point = Config.Contract1.spawnPoints[value.spawnPointId]
        if not point then
            return CharacterResults.Err('spawn_invalid', 'The configured character spawn point is unavailable.', {
                spawnPointId = value.spawnPointId
            })
        end
        position = { x = point.x, y = point.y, z = point.z, heading = point.heading }
    end
    return CharacterResults.Ok({
        characterId = characterId,
        sessionId = sessionId,
        mode = value.mode,
        spawnPointId = value.spawnPointId,
        position = position,
        revision = value.revision
    })
end

local function Finite(value)
    return type(value) == 'number' and value == value and value ~= math.huge and value ~= -math.huge
end

function CharacterSpawn.UpdatePosition(characterId, position)
    if type(characterId) ~= 'string' or type(position) ~= 'table' then
        return CharacterResults.Err('invalid_input', 'characterId and position are required.')
    end
    local x, y, z = tonumber(position.x), tonumber(position.y), tonumber(position.z)
    local heading = tonumber(position.heading) or 0.0
    if not Finite(x) or not Finite(y) or not Finite(z) or not Finite(heading)
        or math.abs(x) > 20000 or math.abs(y) > 20000 or z < -1000 or z > 3000
        or heading < -360 or heading > 360 then
        return CharacterResults.Err('position_invalid', 'Character position is outside the accepted world bounds.')
    end
    local changed = MySQL.update.await([[
        UPDATE `character_spawn_state` s
        INNER JOIN `character_profiles` p ON p.`character_id` = s.`character_id`
        SET s.`mode` = 'last_position', s.`position_x` = ?, s.`position_y` = ?,
            s.`position_z` = ?, s.`heading` = ?, s.`revision` = s.`revision` + 1
        WHERE s.`character_id` = ? AND p.`status` = 'active'
    ]], { x, y, z, heading, characterId })
    if tonumber(changed) ~= 1 then
        return CharacterResults.Err('not_found', 'Character spawn state was not found.')
    end
    local state = CharacterSpawn.Get(characterId)
    if not state.ok then return state end
    return CharacterResults.Ok({
        characterId = characterId,
        position = state.value.position,
        revision = state.value.revision
    })
end

-- One input boundary for the future server creation service. No client value
-- can select an arbitrary ped model, spawn coordinate, or ownership identity.
CharacterV2Draft = {}

local function Copy(value)
    if type(value) ~= 'table' then return value end
    local output = {}
    for key, child in pairs(value) do output[key] = Copy(child) end
    return output
end

local function Trim(value)
    return value:match('^%s*(.-)%s*$')
end

local function Name(value, maxBytes)
    if type(value) ~= 'string' then return nil end
    local name = Trim(value)
    if #name < 1 or #name > maxBytes or name:find('[%c<>]') then return nil end
    return name
end

local function LeapYear(year)
    return year % 400 == 0 or (year % 4 == 0 and year % 100 ~= 0)
end

local function ValidDate(value)
    if type(value) ~= 'string' then return false end
    local yearText, monthText, dayText = value:match('^(%d%d%d%d)%-(%d%d)%-(%d%d)$')
    if not yearText then return false end
    local year, month, day = tonumber(yearText), tonumber(monthText), tonumber(dayText)
    local days = { 31, LeapYear(year) and 29 or 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    return month >= 1 and month <= 12 and day >= 1 and day <= days[month]
end

local function PlainDocument(value)
    if type(value) ~= 'table' or getmetatable(value) ~= nil then return false end
    if value.schemaVersion ~= CharacterV2Config.appearance.schemaVersion then return false end
    for _, key in ipairs({ 'attributes', 'clothing', 'tints', 'overlays' }) do
        if type(value[key]) ~= 'table' then return false end
    end
    return true
end

function CharacterV2Draft.SanitizeAppearance(model, input)
    local base = model == 'mp_female' and CharacterV2Defaults.Female
        or model == 'mp_male' and CharacterV2Defaults.Male or nil
    if not base then return CharacterV2Result.Err('invalid_model', 'The character model is not supported.') end
    local output = Copy(base)
    local attributes = type(input) == 'table' and input.attributes or nil
    if type(attributes) ~= 'table' then return CharacterV2Result.Ok(output) end
    for _, name in ipairs({ 'Head', 'Body', 'Legs', 'Albedo', 'BodyType', 'ChestSize', 'WaistSize' }) do
        local candidate = attributes[name]
        local value = type(candidate) == 'table' and (candidate.hash or candidate.value) or nil
        if type(value) == 'number' and CharacterV2Catalog.Contains(model, name, value) then
            if name == 'WaistSize' then output.attributes[name] = { value = value }
            else output.attributes[name] = { hash = value } end
        end
    end
    for _, definition in ipairs({
        { kind = 'hair', category = 'hairCategory', variant = 'hairVariant' },
        { kind = 'beard', category = 'beardCategory', variant = 'beardVariant' }
    }) do
        local category = attributes[definition.category]
        local variant = attributes[definition.variant]
        local categoryHash = type(category) == 'table' and category.hash or nil
        local variantHash = type(variant) == 'table' and variant.hash or nil
        if categoryHash == 0 or variantHash == 0 then
            output.attributes[definition.category] = { hash = 0 }
            output.attributes[definition.variant] = { hash = 0 }
        elseif CharacterV2HairCatalog.Contains(model, definition.kind, categoryHash)
            and CharacterV2HairCatalog.Contains(model, definition.kind, variantHash) then
            output.attributes[definition.category] = { hash = categoryHash }
            output.attributes[definition.variant] = { hash = variantHash }
        end
    end
    local overlays = type(input) == 'table' and input.overlays or nil
    if type(overlays) == 'table' then
        for category, candidate in pairs(overlays) do
            local catalog = CharacterV2OverlayCatalog.Get(category)
            if catalog and type(candidate) == 'table' then
                local textureId = tonumber(candidate.textureId)
                local variant = tonumber(candidate.variant)
                local opacity = tonumber(candidate.opacity)
                local color1, color2, color3 = tonumber(candidate.color1),
                    tonumber(candidate.color2), tonumber(candidate.color3)
                local validColors = true
                for _, color in ipairs({ color1, color2, color3 }) do
                    if color ~= math.floor(color or -1) or color < 1 or color > 255 then validColors = false end
                end
                if textureId == math.floor(textureId or -1) and catalog.ids[textureId]
                    and variant == math.floor(variant or -1) and variant >= 1
                    and variant <= catalog.variants and opacity and opacity == opacity
                    and opacity >= 0.0 and opacity <= 1.0 and validColors then
                    output.overlays[category] = {
                        textureId = textureId, variant = variant, opacity = opacity * 1.0,
                        color1 = color1, color2 = color2, color3 = color3,
                        colorType = catalog.palette and 0 or 1
                    }
                end
            end
        end
    end
    for name, expected in pairs(output.attributes) do
        local candidate = attributes[name]
        if type(expected) == 'table' and expected.value ~= nil and type(candidate) == 'table'
            and candidate.hash == expected.hash and type(candidate.value) == 'number'
            and candidate.value == candidate.value and candidate.value >= -1.0 and candidate.value <= 1.0 then
            expected.value = candidate.value * 1.0
        end
    end
    return CharacterV2Result.Ok(output)
end

function CharacterV2Draft.Validate(input)
    if type(input) ~= 'table' or getmetatable(input) ~= nil then
        return CharacterV2Result.Err('invalid_input', 'Character data must be an object.')
    end
    local rules = CharacterV2Config.identity
    local firstName = Name(input.firstName, rules.firstNameMaxBytes)
    local lastName = Name(input.lastName, rules.lastNameMaxBytes)
    if not firstName or not lastName then
        return CharacterV2Result.Err('invalid_name', 'First and last name are required.')
    end
    local date = input.dateOfBirth
    if not ValidDate(date) or date < rules.birthDateMin or date > rules.birthDateMax then
        return CharacterV2Result.Err('invalid_birth_date', 'Birth date is outside the allowed range.')
    end
    if input.model ~= 'mp_male' and input.model ~= 'mp_female' then
        return CharacterV2Result.Err('invalid_model', 'The character model is not supported.')
    end
    if type(input.spawnPointId) ~= 'string' or not CharacterV2Config.spawnPoints[input.spawnPointId] then
        return CharacterV2Result.Err('invalid_spawn', 'The selected starting location is unavailable.')
    end
    local description = input.description
    if description ~= nil and (type(description) ~= 'string'
        or #description > rules.descriptionMaxBytes or description:find('[%c]')) then
        return CharacterV2Result.Err('invalid_description', 'Description is invalid.')
    end
    if not PlainDocument(input.appearance) then
        return CharacterV2Result.Err('invalid_appearance', 'The appearance document envelope is invalid.')
    end
    -- The current persistence path replaces the client's appearance with a
    -- server-owned default. Fine-tuning stays disabled until catalog checks.
    return CharacterV2Result.Ok({
        firstName = firstName,
        lastName = lastName,
        dateOfBirth = date,
        model = input.model,
        spawnPointId = input.spawnPointId,
        description = description or '',
        appearance = input.appearance
    })
end

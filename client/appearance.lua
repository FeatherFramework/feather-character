-- Applied only at the world-entry boundary or to a locally owned preview.
-- The first playable slice accepts only server-owned canonical defaults.
CharacterV2Appearance = {}

local overlayTexture = -1
local overlayPalettes = {
    0x3F6E70FF, 0x0105607B, 0x17CBCC83, 0x29F81B2A, 0x3385C5DB,
    0x37CD36D4, 0x4101ED87, 0x63838A81, 0x6765BC15, 0x8BA18876,
    0x9AC34F34, 0x9E4803A0, 0xA4041CEF, 0xA4CFABD0, 0xAA65D8A3,
    0xB562025C, 0xB9E7F722, 0xBBF43EF8, 0xD1476963, 0xD799E1C2,
    0xDC6BC93B, 0xDFB1F64C, 0xF509C745, 0xF93DB0C8, 0xFB71527B
}

local function ReleaseOverlayTexture()
    if overlayTexture == -1 then return end
    Citizen.InvokeNative(0xB63B9178D0F58D82, overlayTexture)
    Citizen.InvokeNative(0x6BEFAA907B076859, overlayTexture)
    overlayTexture = -1
end

local function Refresh(ped)
    Citizen.InvokeNative(0xAAB86462966168CE, ped, true)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
end

local function Tint(ped, hash, colors)
    if type(colors) ~= 'table' or #colors < 3 then return end
    local pedType = Citizen.InvokeNative(0xEC9A1261BF0CE510, ped)
    local category = Citizen.InvokeNative(0x5FF9A878C3D115B8, hash, pedType, true)
    local count = Citizen.InvokeNative(0x90403E8107B60E81, ped, Citizen.ResultAsInteger())
    for index = 0, (tonumber(count) or 0) - 1 do
        local candidate = Citizen.InvokeNative(0x9B90842304C938A7,
            ped, index, 0, Citizen.ResultAsInteger())
        if candidate == category then
            local drawable, albedo, normal, material = Citizen.InvokeNative(
                0xA9C28516A6DC9D56, ped, index,
                Citizen.PointerValueInt(), Citizen.PointerValueInt(),
                Citizen.PointerValueInt(), Citizen.PointerValueInt())
            local palette = Citizen.InvokeNative(0xE7998FEC53A33BBE, ped, index,
                Citizen.PointerValueInt(), Citizen.PointerValueInt(),
                Citizen.PointerValueInt(), Citizen.PointerValueInt())
            Citizen.InvokeNative(0xBC6DF00D7A4A6819, ped, drawable, albedo,
                normal, material, palette, colors[1], colors[2], colors[3])
            return
        end
    end
end

local function Component(ped, hash, colors)
    if type(hash) ~= 'number' or hash == 0 then return end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, hash, true, true, false)
    Citizen.InvokeNative(0x66B957AAC2EAAEAB, ped, hash, 0, 0, 1, 1)
    Refresh(ped)
    Tint(ped, hash, colors)
end

local function RemoveComponent(ped, component)
    if type(component) ~= 'number' or component == 0 then return end
    local pedType = Citizen.InvokeNative(0xEC9A1261BF0CE510, ped)
    local category = Citizen.InvokeNative(0x5FF9A878C3D115B8, component, pedType, true)
    if category and category ~= 0 then
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, category, 0)
        Refresh(ped)
    end
end

CharacterV2Appearance.RemoveComponent = RemoveComponent

local function ApplyOverlays(ped, document)
    ReleaseOverlayTexture()
    if type(document.overlays) ~= 'table' or next(document.overlays) == nil then return true end
    local albedo = document.attributes.Albedo and document.attributes.Albedo.hash
    if type(albedo) ~= 'number' then return false end
    local female = GetEntityModel(ped) == joaat('mp_female')
    local normal = GetHashKey(female and 'head_fr1_mp_002_nm' or 'mp_head_mr1_000_nm')
    local material = female and 0x7FC5B1E1 or 0x50A4BBA9
    overlayTexture = Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, normal, material)
    if overlayTexture == -1 then return false end
    local categories = {}
    for category in pairs(document.overlays) do categories[#categories + 1] = category end
    table.sort(categories)
    for _, category in ipairs(categories) do
        local overlay = document.overlays[category]
        local catalog = CharacterV2OverlayCatalog.Get(category)
        local textureHash = catalog and catalog.ids[overlay.textureId]
        if textureHash then
            local colorType = catalog.palette and 0 or 1
            local layer = Citizen.InvokeNative(0x86BB5FF45F193A02, overlayTexture,
                textureHash, 0, 0, colorType, 1.0, 0)
            if colorType == 0 then
                Citizen.InvokeNative(0x1ED8588524AC9BE1, overlayTexture, layer, overlayPalettes[1])
                Citizen.InvokeNative(0x2DF59FFE6FFD6044, overlayTexture, layer,
                    overlay.color1, overlay.color2, overlay.color3)
            end
            -- The selector is the texture for lasting face details. Unlike
            -- eye shadow/lipstick, these assets do not use texture variants.
            Citizen.InvokeNative(0x3329AAE2882FC8E4, overlayTexture, layer,
                catalog.variants > 1 and overlay.variant or 0)
            Citizen.InvokeNative(0x6C76BC24F8BB709A, overlayTexture, layer, overlay.opacity * 1.0)
        end
    end
    local deadline = GetGameTimer() + 5000
    while not Citizen.InvokeNative(0x31DC8D3F216D8509, overlayTexture)
        and GetGameTimer() < deadline do Wait(5) end
    if not Citizen.InvokeNative(0x31DC8D3F216D8509, overlayTexture) then
        ReleaseOverlayTexture()
        return false
    end
    Citizen.InvokeNative(0x92DAABA2C1C10B0E, overlayTexture)
    Citizen.InvokeNative(0x0B46E25761519058, ped, joaat('heads'), overlayTexture)
    -- Match the proven legacy overlay path. Refresh() also invokes the
    -- outfit-fix native, which can replace the head drawable and discard the
    -- texture that was just attached.
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    return true
end

function CharacterV2Appearance.InitializePed(ped, model)
    local preset = CharacterV2Config.playerBasePreset[model]
    if not ped or ped == 0 or not DoesEntityExist(ped) or type(preset) ~= 'number' then
        return CharacterV2Result.Err('invalid_model', 'The player metaped initializer is unavailable.')
    end
    -- A SetPlayerModel metaped can report render-ready before its base drawable
    -- slots exist. Equip the proven neutral preset first, then let the saved
    -- head/body/legs and clothing replace it in Apply.
    Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, preset, false)
    Refresh(ped)
    Wait(100)
    local deadline = GetGameTimer() + 5000
    while GetGameTimer() < deadline do
        local ready = Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
        if ready == true or ready == 1 then return CharacterV2Result.Ok(true) end
        Wait(0)
    end
    return CharacterV2Result.Err('render_timeout', 'The player metaped did not initialize.')
end

CharacterV2Appearance.InitializePlayer = CharacterV2Appearance.InitializePed

function CharacterV2Appearance.Apply(ped, document)
    if not ped or ped == 0 or not DoesEntityExist(ped)
        or type(document) ~= 'table' or type(document.attributes) ~= 'table'
        or type(document.clothing) ~= 'table' then
        return CharacterV2Result.Err('invalid_appearance', 'A valid ped and appearance are required.')
    end
    local a = document.attributes
    for _, category in ipairs({ 'Head', 'Body', 'Legs', 'EyeColor' }) do
        Component(ped, a[category] and a[category].hash)
    end
    for _, category in ipairs({ 'BodyType', 'ChestSize', 'WaistSize' }) do
        local item = a[category]
        local hash = item and (item.hash or item.value)
        if type(hash) == 'number' then Citizen.InvokeNative(0x1902C4CFCC5BE57C, ped, hash) end
    end
    local hair = a.hairVariant or a.hairCategory
    if hair and hair.hash == 0 then
        local groups = CharacterV2HairCatalog.Groups(document.model or
            (GetEntityModel(ped) == joaat('mp_female') and 'mp_female' or 'mp_male'), 'hair')
        RemoveComponent(ped, groups[1] and groups[1][1])
    elseif hair then Component(ped, hair.hash) end
    local beard = a.beardVariant or a.beardCategory
    if beard and beard.hash == 0 then
        local groups = CharacterV2HairCatalog.Groups('mp_male', 'beard')
        RemoveComponent(ped, groups[1] and groups[1][1])
    elseif beard then Component(ped, beard.hash) end
    for _, item in pairs(a) do
        if type(item) == 'table' and type(item.hash) == 'number'
            and type(item.value) == 'number' then
            Citizen.InvokeNative(0x5653AB26C82938CF, ped, item.hash, item.value * 1.0)
        end
    end
    for category, hash in pairs(document.clothing) do
        Component(ped, hash, document.tints and document.tints[category])
    end
    if not ApplyOverlays(ped, document) then
        return CharacterV2Result.Err('overlay_texture_failed', 'The facial overlay texture did not become ready.')
    end
    return CharacterV2Result.Ok(true)
end

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then ReleaseOverlayTexture() end
end)

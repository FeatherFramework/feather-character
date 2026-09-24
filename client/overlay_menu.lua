CharacterV2OverlayMenu = {}

local creatorCategories = {
    eyebrows = true, beardstabble = true, scars = true, acne = true,
    ageing = true, complex = true, disc = true, freckles = true,
    moles = true, spots = true
}

function CharacterV2OverlayMenu.Build(context)
    local Menu = exports['feather-menu-v2']
    local menuId, pageId = context.menuId, context.pageId
    local elements = {}
    local category = 'eyebrows'

    local function Require(result, operation)
        if type(result) ~= 'table' or not result.ok then
            error(('%s: %s %s'):format(operation,
                type(result) == 'table' and tostring(result.code) or 'invalid_result',
                type(result) == 'table' and tostring(result.message) or ''), 0)
        end
        return result.value
    end
    local function Add(kind, spec, callback)
        return Require(Menu:AddElement(menuId, pageId, kind, spec, callback), 'Add overlay ' .. spec.key)
    end
    local function Options(count)
        local output = {}
        for index = 1, count do output[index] = { value = index, label = tostring(index) } end
        return output
    end
    local categoryOptions = {}
    for key, catalog in pairs(CharacterV2OverlayCatalog) do
        if creatorCategories[key] and type(catalog) == 'table' and catalog.label then
            categoryOptions[#categoryOptions + 1] = { value = key, label = catalog.label }
        end
    end
    table.sort(categoryOptions, function(left, right) return left.label < right.label end)
    local function Default(key)
        local catalog = CharacterV2OverlayCatalog.Get(key)
        return { textureId = 1, variant = 1, opacity = 1.0,
            color1 = 1, color2 = 1, color3 = 1, colorType = catalog.palette and 0 or 1 }
    end
    local function Apply(changes)
        local draft = context.getDraft()
        local overlay = draft.appearance.overlays[category]
        if not overlay then overlay = Default(category); draft.appearance.overlays[category] = overlay end
        for key, value in pairs(changes) do overlay[key] = value end
        context.applyAppearance()
    end
    local function Refresh()
        local catalog = CharacterV2OverlayCatalog.Get(category)
        local overlay = context.getDraft().appearance.overlays[category]
        local enabled = overlay ~= nil
        overlay = overlay or Default(category)
        Require(Menu:UpdateElement(menuId, pageId, elements.enabled, { value = enabled }), 'Refresh overlay enabled')
        Require(Menu:UpdateElement(menuId, pageId, elements.texture, {
            options = Options(#catalog.ids), value = overlay.textureId, disabled = not enabled
        }), 'Refresh overlay texture')
        Require(Menu:UpdateElement(menuId, pageId, elements.variant, {
            options = Options(catalog.variants), value = overlay.variant,
            disabled = not enabled or catalog.variants == 1
        }), 'Refresh overlay variant')
        Require(Menu:UpdateElement(menuId, pageId, elements.opacity,
            { value = overlay.opacity, disabled = not enabled }), 'Refresh overlay opacity')
        for channel = 1, 3 do
            Require(Menu:UpdateElement(menuId, pageId, elements['color' .. channel], {
                value = overlay['color' .. channel], disabled = not enabled or not catalog.palette
            }), 'Refresh overlay color')
        end
    end

    elements.category = Add('dropdown', { key = 'overlay-category', label = 'Facial detail',
        value = category, options = categoryOptions, maxVisibleOptions = 7 },
        function(event) category = event.value Refresh() end).elementId
    elements.enabled = Add('toggle', { key = 'overlay-enabled', label = 'Enabled', value = false },
        function(event)
            local overlays = context.getDraft().appearance.overlays
            overlays[category] = event.value and Default(category) or nil
            context.applyAppearance()
            Refresh()
        end).elementId
    local initial = CharacterV2OverlayCatalog.Get(category)
    elements.texture = Add('arrows', { key = 'overlay-texture', label = 'Texture', value = 1,
        options = Options(#initial.ids), disabled = true },
        function(event) Apply({ textureId = event.value }) end).elementId
    elements.variant = Add('arrows', { key = 'overlay-variant', label = 'Variant', value = 1,
        options = Options(initial.variants), disabled = true },
        function(event) Apply({ variant = event.value }) end).elementId
    elements.opacity = Add('slider', { key = 'overlay-opacity', label = 'Detail opacity', value = 1.0,
        min = 0.0, max = 1.0, step = 0.05, disabled = true },
        function(event) Apply({ opacity = event.value * 1.0 }) end).elementId
    Add('accordion', { key = 'makeup-fine-tune', label = 'Fine-tune detail colors', value = false })
    for channel = 1, 3 do
        local selected = channel
        elements['color' .. selected] = Add('arrows', { key = 'overlay-color-' .. selected,
            label = 'Color ' .. selected, section = 'makeup-fine-tune', value = 1,
            options = Options(255), disabled = true },
            function(event) Apply({ ['color' .. selected] = event.value }) end).elementId
    end

    return function()
        category = 'eyebrows'
        Require(Menu:SetElementValue(menuId, pageId, elements.category, category), 'Reset overlay category')
        Refresh()
    end
end

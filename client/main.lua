local Menu = exports['feather-menu-v2']
local menuId
local currentCharacterId
local opening = false
local busy = false
local booted = false
local draft = {}
local requestKey
local generation = 0
local activationLogoutRequested = false
local CloseMenu, Begin

pcall(function() exports.spawnmanager:setAutoSpawn(false) end)

local function Log(stage, detail)
    print(('[feather-character-v2] %s%s'):format(stage,
        detail and (' ' .. tostring(detail)) or ''))
end

local function Require(result, operation)
    if type(result) ~= 'table' or not result.ok then
        error(('%s: %s %s'):format(operation,
            type(result) == 'table' and tostring(result.code) or 'invalid_result',
            type(result) == 'table' and tostring(result.message) or ''), 0)
    end
    return result.value
end

local function Rpc(name, payload)
    local result, transportError = exports['feather-core']:CallRPCAsync(name, payload or {})
    if type(result) == 'table' and result.ok ~= nil then return result end
    if type(transportError) == 'table' then
        Log('rpc transport failure', ('route=%s code=%s message=%s'):format(name,
            tostring(transportError.code or 'transport_error'),
            tostring(transportError.message or 'No response')))
    end
    return CharacterV2Result.Err(transportError and transportError.code or 'transport_error',
        transportError and transportError.message or ('No response from ' .. name))
end

local function Run(operation, fn, finally)
    if busy then return end
    busy = true
    CreateThread(function()
        local ok, problem = xpcall(fn, debug.traceback)
        if not ok then
            Log(operation .. ' failed', problem)
            if operation == 'enter world' and CharacterV2Flow.State().phase == 'activating' then
                pcall(CharacterV2Arrival.Cleanup)
                local called, aborted = pcall(Rpc, 'character.activation.abort.v1', {})
                Log('activation: abort', called and (aborted.code or tostring(aborted.ok)) or aborted)
                CharacterV2Flow.Reset()
                currentCharacterId = nil
                if not IsScreenFadedOut() then DoScreenFadeOut(250) Wait(300) end
                pcall(CloseMenu)
                pcall(CharacterV2Preview.Close)
                Begin()
            elseif not IsScreenFadedIn() then
                DoScreenFadeIn(350)
            end
        end
        if finally then
            local cleaned, cleanupProblem = pcall(finally)
            if not cleaned then Log(operation .. ' cleanup failed', cleanupProblem) end
        end
        busy = false
    end)
end

CloseMenu = function()
    if menuId then
        Menu:CloseMenu(menuId)
        Menu:DestroyMenu(menuId)
        menuId = nil
    end
end

local function Add(pageId, kind, spec, callback)
    return Require(Menu:AddElement(menuId, pageId, kind, spec, callback),
        'AddElement ' .. spec.key)
end

local function CreateMenu(key, title, options)
    options = options or {}
    CloseMenu()
    Require(Menu:AwaitReady(10000), 'AwaitReady')
    menuId = Require(Menu:CreateMenu({
        key = key, closable = false, draggable = options.draggable == true,
        persistPosition = options.persistPosition,
        persistSize = options.persistSize,
        position = options.position,
        size = options.size or { width = '30rem', maxWidth = '92vw', maxHeight = '88vh' },
        theme = { preset = 'redemption', accent = '#a73732' }
    }), 'CreateMenu').menuId
    local pageId = Require(Menu:CreatePage(menuId, { key = 'main' }), 'CreatePage').pageId
    Add(pageId, 'header', { key = 'title', value = title, slot = 'header' })
    return pageId
end

local function ShowMenu(pageId)
    -- Closing the manual load screen can clear NUI focus. Complete that
    -- handoff before Menu v2 claims keyboard/cursor focus.
    if not booted then
        TriggerEvent('feather-loadscreen:client:character-ready')
        booted = true
        Wait(0)
    end
    local options = { keyboard = true, cursor = true }
    if pageId then options.pageId = pageId end
    Require(Menu:OpenMenu(menuId, options), 'OpenMenu')
    if not IsScreenFadedIn() then DoScreenFadeIn(350) end
end

local function Preview(view, model, appearance, reveal)
    local opened = CharacterV2Preview.Open(view, model)
    Require(opened, 'Open preview')
    Log('presentation:', ('view=%s ped=%s player=%s'):format(
        view, tostring(opened.value.ped), tostring(opened.value.ped == PlayerPedId())))
    Require(CharacterV2Appearance.InitializePed(opened.value.ped, model),
        'Initialize preview metaped')
    local document = appearance
        or (model == 'mp_female' and CharacterV2Defaults.Female or CharacterV2Defaults.Male)
    Require(CharacterV2Appearance.Apply(opened.value.ped, document), 'Apply preview appearance')
    if view == 'selector' and reveal ~= false then
        local posed = Require(CharacterV2Preview.PoseSelector(), 'Pose selector preview')
        Log('selector pose', ('scenario=%s active=%s groundZ=%s settledZ=%s'):format(
            tostring(posed.scenario), tostring(posed.active),
            tostring(posed.groundZ), tostring(posed.z)))
    end
    if reveal ~= false then Require(CharacterV2Preview.Reveal(), 'Reveal preview') end
end

local function MakeKey()
    return ('v2-%d-%d-%d'):format(GetGameTimer(), math.random(100000, 999999), math.random(100000, 999999))
end

local OpenSelection
local OpenCreator

OpenCreator = function()
    local state = CharacterV2Flow.State().phase
    if state == 'selection' then Require(CharacterV2Flow.Transition('creator'), 'Creator transition') end
    draft = {
        firstName = '', lastName = '', dateOfBirth = '1874-01-01',
        description = '', model = 'mp_male', spawnPointId = 'valentine',
        appearance = CharacterV2Draft.SanitizeAppearance('mp_male', nil).value
    }
    requestKey = MakeKey()
    DoScreenFadeOut(250)
    Wait(300)
    Preview('creator', draft.model)
    local pages, elements, cameraViewByPage = {}, {}, {}
    CloseMenu()
    Require(Menu:AwaitReady(10000), 'AwaitReady')
    menuId = Require(Menu:CreateMenu({
        key = 'character-v2-create', draggable = false, resizable = false, closable = false,
        position = { x = '18%', y = '50%' },
        size = { width = '30rem', maxWidth = '92vw', maxHeight = '88vh' },
        theme = { preset = 'redemption', accent = '#a73732' }
    }), 'Create creator menu').menuId
    local steps = {
        { key = 'general', label = 'General information' },
        { key = 'face', label = 'Face' }, { key = 'body', label = 'Body' },
        { key = 'hair', label = 'Hair' }, { key = 'makeup', label = 'Face details' },
        { key = 'spawn', label = 'First spawn' }, { key = 'review', label = 'Review' }
    }
    local help = {
        general = 'Required identity fields are checked before submission.',
        face = 'Choose a base head and refine facial proportions.',
        body = 'Upper and lower body controls are grouped separately.',
        hair = 'Hair and facial hair controls will use model-specific catalogs.',
        makeup = 'Choose lasting facial details. Changeable cosmetics belong in the salon.',
        spawn = 'Choose where this character first enters the world.',
        review = 'Review the complete draft before creating the character.'
    }
    local cameraOptions = {
        { value = 'full', label = 'Full Body' }, { value = 'upper', label = 'Upper Body' },
        { value = 'face', label = 'Face' }, { value = 'lower', label = 'Lower Body' }
    }
    for _, step in ipairs(steps) do
        local key = step.key
        pages[key] = Require(Menu:CreatePage(menuId, { key = key }), 'Create page ' .. key).pageId
        Add(pages[key], 'header', { key = key .. '-title', value = step.label, slot = 'header' })
        elements[key .. 'Status'] = Require(Menu:AddElement(menuId, pages[key], 'textdisplay', {
            key = key .. '-status', value = help[key]
        }), 'Add status ' .. key).elementId
        local viewKey = CharacterV2Config.preview.creator.pageViews[key] or 'full'
        cameraViewByPage[key] = viewKey
        local view = CharacterV2Config.preview.creator.views[viewKey]
        elements[key .. 'CameraView'] = Require(Menu:AddElement(menuId, pages[key], 'dropdown', {
            key = key .. '-camera-view', label = 'Camera view', value = viewKey,
            options = cameraOptions, slot = 'footer'
        }, function(event)
            local selected = CharacterV2Config.preview.creator.views[event.value]
            cameraViewByPage[key] = event.value
            Require(CharacterV2Preview.SetCamera(event.value, selected.fov), 'Set camera view')
            Require(Menu:SetElementValue(menuId, pages[key], elements[key .. 'CameraFov'], selected.fov),
                'Set camera FOV')
        end), 'Add camera view ' .. key).elementId
        elements[key .. 'CameraFov'] = Require(Menu:AddElement(menuId, pages[key], 'slider', {
            key = key .. '-camera-fov', label = 'Camera FOV (larger is farther out)',
            value = view.fov, min = 10.0, max = 80.0, step = 0.25, slot = 'footer'
        }, function(event)
            Require(CharacterV2Preview.SetCamera(cameraViewByPage[key], event.value * 1.0), 'Set camera FOV')
        end),
            'Add camera FOV ' .. key).elementId
        Add(pages[key], 'subheader', { key = key .. '-rotate-label', value = 'Rotate', slot = 'footer' })
        Add(pages[key], 'button', { key = key .. '-left', label = '← Left',
            row = key .. '-rotate', slot = 'footer' },
            function() CharacterV2Preview.Rotate(-45.0) end)
        Add(pages[key], 'button', { key = key .. '-right', label = 'Right →',
            row = key .. '-rotate', slot = 'footer' },
            function() CharacterV2Preview.Rotate(45.0) end)
        Add(pages[key], 'button', { key = key .. '-cancel',
            label = 'Cancel and return to character selection', slot = 'footer' },
            function() Run('cancel creator', OpenSelection) end)
    end
    local catalogElements = {}
    local hairElements = {}
    local hairSelection = { hair = 1, beard = 0 }
    local ResetHairControls = function() end
    local ResetOverlayControls = function() end
    local heritageIndex = 1
    local function IndexedOptions(values)
        local options = {}
        for index = 1, #(values or {}) do
            options[index] = { value = index, label = tostring(index) }
        end
        return options
    end
    local function StyleOptions(groups)
        local options = { { value = 0, label = 'None' } }
        for index = 1, #groups do options[#options + 1] = { value = index, label = 'Style ' .. index } end
        return options
    end
    local hairColors = { 'Blonde', 'Brown', 'Dark Brown', 'Dark Blonde', 'Dark Ginger',
        'Dark Grey', 'Ginger', 'Grey', 'Black', 'Light Blonde', 'Light Brown',
        'Light Ginger', 'Light Grey', 'Medium Brown', 'Platinum', 'Silver', 'Uncle Grey' }
    local function VariantOptions(group)
        local options = {}
        for index = 1, #(group or {}) do
            options[index] = { value = index, label = hairColors[index] or ('Variant ' .. index) }
        end
        return options
    end
    local function ApplyDraftAppearance()
        local current = CharacterV2Preview.Current()
        if current then Require(CharacterV2Appearance.Apply(current.ped, draft.appearance), 'Apply creator appearance') end
    end
    local function SelectCatalog(category, index)
        local values = CharacterV2Catalog.Values(draft.model, category, heritageIndex)
        local value = values and values[tonumber(index)]
        if not value then return end
        if category == 'WaistSize' then draft.appearance.attributes[category] = { value = value }
        else draft.appearance.attributes[category] = { hash = value } end
        ApplyDraftAppearance()
    end
    local function ResetCatalogControls()
        heritageIndex = 1
        if catalogElements.Heritage then
            local options = {}
            for index, heritage in ipairs(CharacterV2Catalog.Heritages(draft.model)) do
                options[index] = { value = index, label = heritage.label }
            end
            Require(Menu:UpdateElement(menuId, catalogElements.Heritage.pageId,
                catalogElements.Heritage.elementId, { options = options, value = 1 }), 'Reset heritage')
        end
        for _, category in ipairs({ 'Head', 'Body', 'Legs' }) do
            local element = catalogElements[category]
            if element then
                Require(Menu:UpdateElement(menuId, element.pageId, element.elementId, {
                    options = IndexedOptions(CharacterV2Catalog.Values(draft.model, category, heritageIndex)), value = 1
                }), 'Reset ' .. category)
            end
        end
        for _, category in ipairs({ 'BodyType', 'ChestSize', 'WaistSize' }) do
            local element = catalogElements[category]
            if element then Require(Menu:SetElementValue(menuId, element.pageId, element.elementId, 1),
                'Reset ' .. category) end
        end
    end
    local function ApplyHeritage(index)
        local heritage = CharacterV2Catalog.Heritages(draft.model)[tonumber(index)]
        if not heritage then return end
        heritageIndex = tonumber(index)
        draft.appearance.attributes.Albedo = { hash = CharacterV2Catalog.Albedo(draft.model, heritageIndex) }
        for _, category in ipairs({ 'Head', 'Body', 'Legs' }) do
            local values = CharacterV2Catalog.Values(draft.model, category, heritageIndex)
            draft.appearance.attributes[category] = { hash = values[1] }
            local element = catalogElements[category]
            if element then
                Require(Menu:UpdateElement(menuId, element.pageId, element.elementId, {
                    options = IndexedOptions(values), value = 1
                }), 'Apply heritage ' .. category)
            end
        end
        ApplyDraftAppearance()
    end
    local page = pages.general
    elements.model = Add(page, 'arrows', { key = 'model', label = 'Character model', value = 'mp_male',
        options = { { value = 'mp_male', label = 'Male' }, { value = 'mp_female', label = 'Female' } }
    }, function(event)
        if busy then return end
        local requestedModel = event.value
        Require(Menu:UpdateElement(menuId, page, elements.model.elementId,
            { disabled = true }), 'Disable model switch')
        Run('model preview', function()
            Require(CharacterV2Preview.FadeOut(), 'Fade out model preview')
            draft.model = requestedModel
            draft.appearance = CharacterV2Draft.SanitizeAppearance(draft.model, nil).value
            Preview('creator', draft.model)
            ResetCatalogControls()
            ResetHairControls()
            ResetOverlayControls()
        end, function()
            if menuId and elements.model then
                Require(Menu:UpdateElement(menuId, page, elements.model.elementId,
                    { disabled = false }), 'Enable model switch')
            end
        end)
    end)
    Add(page, 'input', { key = 'first', label = 'First name', value = '', maxLength = 24 },
        function(event) draft.firstName = event.value end)
    Add(page, 'input', { key = 'last', label = 'Last name', value = '', maxLength = 24 },
        function(event) draft.lastName = event.value end)
    local month, day, year = 1, 1, 1874
    local monthNames = { 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December' }
    local months, days, years = {}, {}, {}
    for index, label in ipairs(monthNames) do months[#months + 1] = { value = index, label = label } end
    for index = 1, 31 do days[#days + 1] = { value = index, label = tostring(index) } end
    for value = 1881, 1819, -1 do years[#years + 1] = { value = value, label = tostring(value) } end
    local function Birthday() draft.dateOfBirth = ('%04d-%02d-%02d'):format(year, month, day) end
    Add(page, 'dropdown', { key = 'birth-month', row = 'birth-date', label = 'Month',
        value = month, options = months, maxVisibleOptions = 6 }, function(event) month = event.value Birthday() end)
    Add(page, 'dropdown', { key = 'birth-day', row = 'birth-date', label = 'Day',
        value = day, options = days, maxVisibleOptions = 6 }, function(event) day = event.value Birthday() end)
    Add(page, 'dropdown', { key = 'birth-year', row = 'birth-date', label = 'Year',
        value = year, options = years, maxVisibleOptions = 6 }, function(event) year = event.value Birthday() end)
    Add(page, 'textarea', { key = 'description', label = 'Description',
        value = '', maxLength = 512, rows = 3 }, function(event) draft.description = event.value end)
    local heritageOptions = {}
    for index, heritage in ipairs(CharacterV2Catalog.Heritages(draft.model)) do
        heritageOptions[index] = { value = index, label = heritage.label }
    end
    catalogElements.Heritage = { pageId = pages.face }
    catalogElements.Heritage.elementId = Require(Menu:AddElement(menuId, pages.face, 'dropdown', {
        key = 'heritage', label = 'Heritage', value = 1, options = heritageOptions
    }, function(event) ApplyHeritage(event.value) end), 'Add heritage').elementId
    catalogElements.Head = { pageId = pages.face }
    catalogElements.Head.elementId = Require(Menu:AddElement(menuId, pages.face, 'arrows', {
        key = 'base-head', label = 'Base head', value = 1,
        options = IndexedOptions(CharacterV2Catalog.Values(draft.model, 'Head', heritageIndex))
    }, function(event) SelectCatalog('Head', event.value) end), 'Add base head').elementId
    Add(pages.face, 'accordion', { key = 'face-fine-tune',
        label = 'Fine-tune facial features', value = false })
    local function FineTune(pageId, section, key, label, attribute)
        local item = draft.appearance.attributes[attribute]
        if not item or item.hash == nil then return end
        Add(pageId, 'slider', { key = key, label = label, section = section,
            value = item.value or 0.0, min = -1.0, max = 1.0, step = 0.05 }, function(event)
            draft.appearance.attributes[attribute].value = event.value * 1.0
            local current = CharacterV2Preview.Current()
            if current then CharacterV2Appearance.Apply(current.ped, draft.appearance) end
        end)
    end
    local facial = {
        { 'eye-height', 'Eye height', 'EyeHeight' }, { 'eye-width', 'Eyelid width', 'EyelidWidth' },
        { 'eye-depth', 'Eye depth', 'EyeDepth' }, { 'eye-distance', 'Eye distance', 'EyeDistance' },
        { 'brow-height', 'Eyebrow height', 'EyebrowHeight' }, { 'brow-width', 'Eyebrow width', 'EyebrowWidth' },
        { 'nose-height', 'Nose height', 'NoseHeight' }, { 'nose-width', 'Nose width', 'NoseWidth' },
        { 'nose-angle', 'Nose angle', 'NoseAngle' }, { 'nose-curve', 'Nose curve', 'NoseCurve' },
        { 'cheek-height', 'Cheekbone height', 'CheekboneHeight' },
        { 'cheek-width', 'Cheekbone width', 'CheekboneWidth' },
        { 'cheek-depth', 'Cheekbone depth', 'CheekboneDepth' },
        { 'jaw-height', 'Jaw height', 'JawHeight' }, { 'jaw-width', 'Jaw width', 'JawWidth' },
        { 'jaw-depth', 'Jaw depth', 'JawDepth' }, { 'chin-height', 'Chin height', 'ChinHeight' },
        { 'chin-width', 'Chin width', 'ChinWidth' }, { 'chin-depth', 'Chin depth', 'ChinDepth' },
        { 'mouth-width', 'Mouth width', 'MouthWidth' },
        { 'mouth-horizontal', 'Mouth horizontal position', 'MouthXPos' },
        { 'mouth-vertical', 'Mouth vertical position', 'MouthYPos' },
        { 'upper-lip-height', 'Upper lip height', 'UpLipHeight' },
        { 'upper-lip-width', 'Upper lip width', 'UpLipWidth' },
        { 'lower-lip-height', 'Lower lip height', 'LowLipHeight' },
        { 'lower-lip-width', 'Lower lip width', 'LowLipWidth' },
        { 'ear-height', 'Ear height', 'EarHeight' }, { 'ear-width', 'Ear width', 'EarWidth' },
        { 'ear-angle', 'Ear angle', 'EarAngle' }, { 'ear-size', 'Ear size', 'EarSize' }
    }
    for _, control in ipairs(facial) do
        FineTune(pages.face, 'face-fine-tune', control[1], control[2], control[3])
    end
    Add(pages.body, 'subheader', { key = 'upper-heading', value = 'Upper body' })
    for _, definition in ipairs({
        { 'Body', 'base-body', 'Base body' },
        { 'BodyType', 'body-type', 'Body type' },
        { 'ChestSize', 'chest-size', 'Chest size' }
    }) do
        local category = definition[1]
        catalogElements[category] = { pageId = pages.body }
        catalogElements[category].elementId = Require(Menu:AddElement(menuId, pages.body, 'arrows', {
            key = definition[2], label = definition[3], value = 1,
            options = IndexedOptions(CharacterV2Catalog.Values(draft.model, category, heritageIndex))
        }, function(event) SelectCatalog(category, event.value) end), 'Add ' .. definition[2]).elementId
    end
    Add(pages.body, 'accordion', { key = 'upper-fine-tune', label = 'Fine-tune upper body', value = false })
    FineTune(pages.body, 'upper-fine-tune', 'upper-arm-size', 'Upper arm size', 'UpArmSize')
    FineTune(pages.body, 'upper-fine-tune', 'forearm-size', 'Forearm size', 'ForearmSize')
    Add(pages.body, 'subheader', { key = 'lower-heading', value = 'Lower body' })
    for _, definition in ipairs({
        { 'Legs', 'base-legs', 'Base legs' },
        { 'WaistSize', 'waist-size', 'Waist size' }
    }) do
        local category = definition[1]
        catalogElements[category] = { pageId = pages.body }
        catalogElements[category].elementId = Require(Menu:AddElement(menuId, pages.body, 'arrows', {
            key = definition[2], label = definition[3], value = 1,
            options = IndexedOptions(CharacterV2Catalog.Values(draft.model, category, heritageIndex))
        }, function(event) SelectCatalog(category, event.value) end), 'Add ' .. definition[2]).elementId
    end
    Add(pages.body, 'accordion', { key = 'lower-fine-tune', label = 'Fine-tune lower body', value = false })
    FineTune(pages.body, 'lower-fine-tune', 'waist-width', 'Waist width', 'WaistWidth')
    FineTune(pages.body, 'lower-fine-tune', 'hip-width', 'Hip width', 'HipWidth')
    FineTune(pages.body, 'lower-fine-tune', 'thigh-size', 'Thigh size', 'ThighsSize')
    FineTune(pages.body, 'lower-fine-tune', 'calf-size', 'Calf size', 'CalvesSize')
    local function SelectHairStyle(kind, index)
        local groups = CharacterV2HairCatalog.Groups(draft.model, kind)
        local categoryName = kind == 'beard' and 'beardCategory' or 'hairCategory'
        local variantName = kind == 'beard' and 'beardVariant' or 'hairVariant'
        hairSelection[kind] = tonumber(index)
        if hairSelection[kind] == 0 then
            draft.appearance.attributes[categoryName] = { hash = 0 }
            draft.appearance.attributes[variantName] = { hash = 0 }
            Require(Menu:UpdateElement(menuId, pages.hair, hairElements[kind .. 'Variant'], {
                options = { { value = 1, label = 'None' } }, value = 1, disabled = true
            }), 'Disable ' .. kind .. ' variant')
        else
            local group = groups[hairSelection[kind]]
            if not group or not group[1] then return end
            draft.appearance.attributes[categoryName] = { hash = group[1] }
            draft.appearance.attributes[variantName] = { hash = group[1] }
            Require(Menu:UpdateElement(menuId, pages.hair, hairElements[kind .. 'Variant'], {
                options = VariantOptions(group), value = 1, disabled = false
            }), 'Update ' .. kind .. ' variants')
        end
        ApplyDraftAppearance()
    end
    local function SelectHairVariant(kind, index)
        local group = CharacterV2HairCatalog.Groups(draft.model, kind)[hairSelection[kind]]
        local hash = group and group[tonumber(index)]
        if not hash then return end
        local variantName = kind == 'beard' and 'beardVariant' or 'hairVariant'
        draft.appearance.attributes[variantName] = { hash = hash }
        ApplyDraftAppearance()
    end
    local hairGroups = CharacterV2HairCatalog.Groups(draft.model, 'hair')
    hairElements.hairCategory = Require(Menu:AddElement(menuId, pages.hair, 'dropdown', {
        key = 'hair-style', label = 'Hair style', value = 1, options = StyleOptions(hairGroups)
    }, function(event) SelectHairStyle('hair', event.value) end), 'Add hair style').elementId
    hairElements.hairVariant = Require(Menu:AddElement(menuId, pages.hair, 'arrows', {
        key = 'hair-variant', label = 'Hair color', value = 1, options = VariantOptions(hairGroups[1])
    }, function(event) SelectHairVariant('hair', event.value) end), 'Add hair variant').elementId
    local beardGroups = CharacterV2HairCatalog.Groups('mp_male', 'beard')
    hairElements.beardCategory = Require(Menu:AddElement(menuId, pages.hair, 'dropdown', {
        key = 'beard-style', label = 'Facial hair (male only)', value = 0,
        options = StyleOptions(beardGroups)
    }, function(event) SelectHairStyle('beard', event.value) end), 'Add beard style').elementId
    hairElements.beardVariant = Require(Menu:AddElement(menuId, pages.hair, 'arrows', {
        key = 'beard-variant', label = 'Facial hair color', value = 1,
        options = { { value = 1, label = 'None' } }, disabled = true
    }, function(event) SelectHairVariant('beard', event.value) end), 'Add beard variant').elementId
    ResetHairControls = function()
        local groups = CharacterV2HairCatalog.Groups(draft.model, 'hair')
        hairSelection.hair = 1
        Require(Menu:UpdateElement(menuId, pages.hair, hairElements.hairCategory,
            { options = StyleOptions(groups), value = 1, disabled = false }), 'Reset hair styles')
        Require(Menu:UpdateElement(menuId, pages.hair, hairElements.hairVariant,
            { options = VariantOptions(groups[1]), value = 1, disabled = false }), 'Reset hair variants')
        local male = draft.model == 'mp_male'
        hairSelection.beard = 0
        Require(Menu:UpdateElement(menuId, pages.hair, hairElements.beardCategory, {
            options = male and StyleOptions(CharacterV2HairCatalog.Groups(draft.model, 'beard'))
                or { { value = 0, label = 'Not available' } },
            value = 0, disabled = not male
        }), 'Reset beard styles')
        Require(Menu:UpdateElement(menuId, pages.hair, hairElements.beardVariant, {
            options = { { value = 1, label = 'None' } }, value = 1, disabled = true
        }), 'Reset beard variants')
    end
    ResetOverlayControls = CharacterV2OverlayMenu.Build({
        menuId = menuId,
        pageId = pages.makeup,
        getDraft = function() return draft end,
        applyAppearance = ApplyDraftAppearance
    })
    Add(pages.spawn, 'dropdown', { key = 'town', label = 'Starting town', value = 'valentine',
        options = {
            { value = 'valentine', label = 'Valentine' },
            { value = 'rhodes', label = 'Rhodes' },
            { value = 'saint_denis', label = 'Saint Denis' },
            { value = 'blackwater', label = 'Blackwater' },
            { value = 'strawberry', label = 'Strawberry' },
            { value = 'van_horn', label = 'Van Horn' },
            { value = 'armadillo', label = 'Armadillo' },
            { value = 'tumbleweed', label = 'Tumbleweed' }
        }
    }, function(event) draft.spawnPointId = event.value end)
    elements.review = Require(Menu:AddElement(menuId, pages.review, 'textdisplay', {
        key = 'review-summary', value = 'Complete the earlier steps to review this character.'
    }), 'Add review').elementId
    local navigation = {}
    for _, step in ipairs(steps) do navigation[#navigation + 1] = { pageId = pages[step.key], label = step.label } end
    Require(Menu:ConfigureNavigation(menuId, { type = 'stepper', allowDirectStep = false,
        backLabel = 'Back', nextLabel = 'Next', finishLabel = 'Create character', pages = navigation
    }, function(event)
        if event.action == 'finish' then
            Run('creation', function()
                local checked = CharacterV2Draft.Validate({
                    firstName = draft.firstName, lastName = draft.lastName,
                    dateOfBirth = draft.dateOfBirth, model = draft.model,
                    description = draft.description, spawnPointId = draft.spawnPointId,
                    appearance = draft.appearance
                })
                if not checked.ok then Log('creation rejected', checked.message) return end
                Log('creation: submitting')
                local created = Rpc('character.create.v1', {
                    idempotencyKey = requestKey, character = draft
                })
                if not created.ok then Log('creation rejected', created.message) return end
                Log('creation: saved', created.value.characterId)
                requestKey = nil
                CharacterV2EnterWorld(created.value.characterId, { afterCreation = true })
            end)
            return
        end
        if event.toPageId == pages.review then
            local point = CharacterV2Config.spawnPoints[draft.spawnPointId]
            Require(Menu:UpdateElement(menuId, pages.review, elements.review, {
                value = ('%s %s\nBirthday: %s\nModel: %s\nFirst spawn: %s'):format(
                    draft.firstName ~= '' and draft.firstName or 'Unnamed', draft.lastName,
                    draft.dateOfBirth, draft.model == 'mp_female' and 'Female' or 'Male', point.label)
            }), 'Update review')
        end
        if event.toPageId then
            local targetKey
            for key, id in pairs(pages) do if id == event.toPageId then targetKey = key break end end
            local viewKey = cameraViewByPage[targetKey]
                or CharacterV2Config.preview.creator.pageViews[targetKey] or 'full'
            CharacterV2Preview.SetCamera(viewKey, CharacterV2Config.preview.creator.views[viewKey].fov)
            Require(Menu:NavigateToPage(menuId, event.toPageId), 'Navigate creator')
        end
    end), 'Configure creator navigation')
    ShowMenu(pages.general)
end

OpenSelection = function()
    local phase = CharacterV2Flow.State().phase
    if phase ~= 'selection' then Require(CharacterV2Flow.Transition('selection'), 'Selection transition') end
    Log('selection: listing')
    local listed = Rpc('character.list.v1', {})
    Require(listed, 'List characters')
    DoScreenFadeOut(250)
    Wait(300)
    local profiles = listed.value or {}
    if #profiles == 0 then return OpenCreator() end
    -- The selector is a read-only presentation. Snapshot every owned
    -- appearance once so cycling never waits on another server round trip.
    for _, profile in ipairs(profiles) do
        local appearance = Rpc('character.appearance.get.v1', {
            characterId = profile.characterId
        })
        Require(appearance, 'Cache selector appearance')
        profile.selectorAppearance = appearance.value.document
    end
    Log('selection: appearance snapshot cached', ('characters=%d'):format(#profiles))
    local selectedIndex = 1
    local prepared = {}
    local function ProfileKey(index)
        return profiles[index].characterId
    end
    local function WrappedIndex(index)
        return ((index - 1) % #profiles) + 1
    end
    local function NeededIndexes(index)
        local values, seen = {}, {}
        for _, candidate in ipairs({ WrappedIndex(index - 1), index, WrappedIndex(index + 1) }) do
            local key = ProfileKey(candidate)
            if not seen[key] then
                seen[key] = true
                values[#values + 1] = candidate
            end
        end
        return values, seen
    end
    local function PrepareIndex(index)
        local selected = profiles[index]
        local key = selected.characterId
        if prepared[key] then return end
        Preview('selector', selected.model, selected.selectorAppearance, false)
        Require(CharacterV2Preview.StashSelector(key), 'Cache selector clone')
        prepared[key] = true
    end
    local function WarmCarousel(index)
        local indexes, needed = NeededIndexes(index)
        for key in pairs(prepared) do
            if not needed[key] then
                Require(CharacterV2Preview.EvictSelector(key), 'Evict selector clone')
                prepared[key] = nil
            end
        end
        for _, neededIndex in ipairs(indexes) do PrepareIndex(neededIndex) end
    end
    WarmCarousel(selectedIndex)
    Require(CharacterV2Preview.ActivateSelector(ProfileKey(selectedIndex)),
        'Activate initial selector clone')
    local page = CreateMenu('character-v2-select', 'Choose character', {
        persistPosition = false,
        persistSize = false,
        position = { x = '15%', y = '50%' },
        size = { width = '24rem', maxWidth = '90vw', maxHeight = '82vh' }
    })
    local deletePage = Require(Menu:CreatePage(menuId, {
        key = 'delete-character'
    }), 'Create delete confirmation page').pageId
    Add(deletePage, 'header', {
        key = 'delete-title', value = 'Delete character?', slot = 'header'
    })
    local deleteWarning = Add(deletePage, 'textdisplay', {
        key = 'delete-warning', value = 'This cannot be undone.'
    })
    local characterOptions = {}
    for index, profile in ipairs(profiles) do
        characterOptions[index] = {
            value = index,
            label = ('%s %s'):format(profile.firstName, profile.lastName)
        }
    end
    local characterSwitch
    local debugTown = 'valentine'
    local debugSpawnSequence = 'direct'
    characterSwitch = Add(page, 'arrows', { key = 'character', label = 'Character', value = selectedIndex,
        options = characterOptions }, function(event)
        if busy then return end
        selectedIndex = tonumber(event.value) or 1
        Require(Menu:UpdateElement(menuId, page, characterSwitch.elementId,
            { disabled = true }), 'Disable character switch')
        Run('preview character', function()
            Require(CharacterV2Preview.ActivateSelector(ProfileKey(selectedIndex)),
                'Activate selector clone')
            WarmCarousel(selectedIndex)
        end, function()
            if menuId and characterSwitch then
                Require(Menu:UpdateElement(menuId, page, characterSwitch.elementId,
                    { disabled = false }), 'Enable character switch')
            end
        end)
    end)
    if CharacterV2Config.debug
        and CharacterV2Config.debug.selectorSpawnSequence == true then
        Add(page, 'dropdown', {
            key = 'debug-spawn-town',
            label = 'Spawn town',
            value = debugTown,
            options = {
                { value = 'valentine', label = 'Valentine' },
                { value = 'saint_denis', label = 'Saint Denis' },
                { value = 'strawberry', label = 'Strawberry' },
                { value = 'rhodes', label = 'Rhodes' },
                { value = 'blackwater', label = 'Blackwater' },
                { value = 'van_horn', label = 'Van Horn' },
                { value = 'armadillo', label = 'Armadillo' },
                { value = 'tumbleweed', label = 'Tumbleweed' }
            }
        }, function(event)
            debugTown = event.value
        end)
        Add(page, 'dropdown', {
            key = 'debug-spawn-sequence',
            label = 'Spawn sequence',
            value = debugSpawnSequence,
            options = {
                { value = 'direct', label = 'Direct' },
                { value = 'horse', label = 'Horse' }
            }
        }, function(event)
            debugSpawnSequence = event.value
        end)
    end
    Add(page, 'button', { key = 'enter', label = 'Enter world' },
        function()
            local selected = profiles[selectedIndex]
            local enterOptions
            if CharacterV2Config.debug
                and CharacterV2Config.debug.selectorSpawnSequence == true then
                enterOptions = {
                    debugSpawnTown = debugTown,
                    debugSpawnSequence = debugSpawnSequence
                }
            end
            Run('enter world', function()
                CharacterV2EnterWorld(selected.characterId, enterOptions)
            end)
        end)
    Add(page, 'button', { key = 'delete', label = 'Delete character' }, function()
        if busy then return end
        local selected = profiles[selectedIndex]
        Require(Menu:UpdateElement(menuId, deletePage, deleteWarning.elementId, {
            value = ('Permanently delete %s %s?\n\nThis cannot be undone.'):format(
                selected.firstName, selected.lastName)
        }), 'Update delete warning')
        Require(Menu:NavigateToPage(menuId, deletePage), 'Open delete confirmation')
    end)
    Add(deletePage, 'button', {
        key = 'confirm-delete', label = 'Yes, permanently delete this character'
    }, function()
        if busy then return end
        local selected = profiles[selectedIndex]
        Run('delete character', function()
            Require(Rpc('character.delete.v1', {
                characterId = selected.characterId
            }), 'Delete character')
            DoScreenFadeOut(250)
            Wait(300)
            CloseMenu()
            CharacterV2Preview.Close()
            OpenSelection()
        end)
    end)
    Add(deletePage, 'button', {
        key = 'cancel-delete', label = 'No, keep this character', slot = 'footer'
    }, function()
        if busy then return end
        Require(Menu:NavigateToPage(menuId, page), 'Cancel character deletion')
    end)
    Add(page, 'button', { key = 'new', label = 'Create another character', slot = 'footer' },
        function() Run('open creator', OpenCreator) end)
    ShowMenu()
end

local function CurrentPosition()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    return { x = coords.x, y = coords.y, z = coords.z, heading = GetEntityHeading(ped) }
end

local function AwaitRuntimeReady(timeoutMs)
    local deadline = GetGameTimer() + timeoutMs
    local stable, lastPed = 0, 0
    while GetGameTimer() < deadline do
        local ped = PlayerPedId()
        local renderReady = ped ~= 0 and Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
        local ready = ped ~= 0 and DoesEntityExist(ped)
            and NetworkIsPlayerActive(PlayerId())
            and HasCollisionLoadedAroundEntity(ped)
            and IsScreenFadedIn() and not IsScreenFadingIn()
            and IsGameplayCamRendering()
            and (renderReady == true or renderReady == 1)
        if ready and ped == lastPed then stable = stable + 1
        else stable, lastPed = ready and 1 or 0, ready and ped or 0 end
        if stable >= 8 then return true end
        Wait(0)
    end
    return false
end

function CharacterV2EnterWorld(characterId, options)
    options = options or {}
    activationLogoutRequested = false
    Log('activation: requesting', characterId)
    local activated = Rpc('character.activate.v1', { characterId = characterId })
    Require(activated, 'Activate character')
    Require(CharacterV2Flow.Transition('activating'), 'Activation transition')
    local value = activated.value
    local spawn = value.spawn and value.spawn.position
    local spawnPointId = value.spawn and value.spawn.spawnPointId
    local debugSpawnSequence
    if CharacterV2Config.debug
        and CharacterV2Config.debug.selectorSpawnSequence == true
        and type(options.debugSpawnTown) == 'string'
        and (options.debugSpawnSequence == 'direct' or options.debugSpawnSequence == 'horse') then
        debugSpawnSequence = options.debugSpawnSequence
        spawnPointId = options.debugSpawnTown
        local direct = CharacterV2Config.spawnPoints[spawnPointId]
        if type(direct) ~= 'table' then
            error('The selected debug town has no configured direct spawn.', 0)
        end
        if debugSpawnSequence == 'horse'
            and type(CharacterV2Config.arrivals.towns[spawnPointId]) ~= 'table' then
            error('The selected debug town has no configured horse arrival.', 0)
        end
        spawn = direct
        Log('activation: debug spawn sequence', ('type=%s town=%s'):format(
            debugSpawnSequence, spawnPointId))
    end
    if type(spawn) ~= 'table' or type(value.appearance) ~= 'table' then
        error('Activation did not contain a spawn plan and appearance.', 0)
    end
    DoScreenFadeOut(350)
    Wait(400)
    CloseMenu()
    CharacterV2Preview.Close()
    Log('activation: leaving selection route')
    Require(Rpc('character.selection.route.leave.v1', {}), 'Leave selection route')
    local hash = joaat(value.profile.model)
    RequestModel(hash)
    local deadline = GetGameTimer() + 10000
    while not HasModelLoaded(hash) and GetGameTimer() < deadline do Wait(0) end
    if not HasModelLoaded(hash) then error('Player model did not load.', 0) end
    Log('activation: loading network player model')
    SetPlayerModel(PlayerId(), hash, false)
    SetModelAsNoLongerNeeded(hash)
    local ped = PlayerPedId()
    if ped == 0 or not DoesEntityExist(ped) then error('Network player ped is unavailable.', 0) end
    SetEntityCollision(ped, true, true)
    Log('activation: initializing network metaped')
    Require(CharacterV2Appearance.InitializePlayer(ped, value.profile.model),
        'Initialize player metaped')
    local renderDeadline = GetGameTimer() + 5000
    while GetGameTimer() < renderDeadline do
        local ready = Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
        if ready == true or ready == 1 then break end
        Wait(0)
    end
    local renderReady = Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
    if renderReady ~= true and renderReady ~= 1 then error('Network player ped did not render.', 0) end
    Log('activation: applying appearance')
    Require(CharacterV2Appearance.Apply(ped, value.appearance.document), 'Apply appearance')
    local function CancelActivationForLogout()
        if not activationLogoutRequested then return false end
        activationLogoutRequested = false
        CharacterV2Arrival.Cleanup()
        Require(Rpc('character.activation.abort.v1', {}), 'Cancel activation for logout')
        generation = generation + 1
        TriggerEvent('Feather:Character:Logout', {
            characterId = characterId, reason = 'logout'
        })
        CharacterV2Flow.Reset()
        Begin()
        return true
    end
    if CancelActivationForLogout() then return end
    local arrivalPlayed = false
    local configuredArrival = type(spawnPointId) == 'string'
        and CharacterV2Config.arrivals
        and CharacterV2Config.arrivals.towns[spawnPointId]
    local playHorseArrival = debugSpawnSequence == 'horse'
        or (options.afterCreation == true and value.spawn.mode == 'first_spawn'
            and configuredArrival and configuredArrival.type == 'horse')
    if playHorseArrival and type(spawnPointId) == 'string' then
        Log('arrival: requesting', spawnPointId)
        local forcedType = debugSpawnSequence == 'horse' and 'horse' or nil
        local arrival = CharacterV2Arrival.Play(spawnPointId, ped, forcedType)
        if CancelActivationForLogout() then return end
        if arrival.ok then
            arrivalPlayed = true
            Log('arrival: completed', spawnPointId)
        else
            Log('arrival: direct fallback', ('code=%s message=%s'):format(
                tostring(arrival.code), tostring(arrival.message)))
            if not IsScreenFadedOut() then
                DoScreenFadeOut(250)
                while not IsScreenFadedOut() do Wait(0) end
            end
        end
    end
    if not arrivalPlayed then
        RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)
        SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, false)
        SetEntityHeading(ped, spawn.heading or 0.0)
        local collisionDeadline = GetGameTimer() + 5000
        while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < collisionDeadline do
            RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)
            Wait(0)
        end
        if not HasCollisionLoadedAroundEntity(ped) then
            error('Authorized spawn collision did not load.', 0)
        end
        if PlaceEntityOnGroundProperly(ped) == false then
            error('Authorized spawn ground placement failed.', 0)
        end
        FreezeEntityPosition(ped, false)
        SetEntityVisible(ped, true)
        DisplayRadar(true)
    end
    Log('activation: completing spawn')
    Require(Rpc('character.spawn.complete.v1', {}), 'Complete spawn')
    currentCharacterId = characterId
    Require(CharacterV2Flow.Transition('world'), 'World transition')
    if not IsScreenFadedIn() then DoScreenFadeIn(450) end
    local lifecycle = {
        id = characterId, characterId = characterId,
        first_name = value.profile.firstName, last_name = value.profile.lastName,
        model = value.profile.model
    }
    TriggerEvent('Feather:Character:Spawned', lifecycle)
    if AwaitRuntimeReady(5000) then
        TriggerEvent('feather-character:client:runtime-ready.v1', lifecycle)
        Log('activation: runtime ready', characterId)
    else
        Log('activation: runtime readiness timed out', characterId)
    end
    Log('activation: playable', characterId)
    generation = generation + 1
    local ticket = generation
    CreateThread(function()
        while currentCharacterId == characterId and ticket == generation do
            Wait(30000)
            if currentCharacterId == characterId and ticket == generation then
                local saved = Rpc('character.position.update.v1', { position = CurrentPosition() })
                if not saved.ok then Log('position sync failed', saved.code) end
            end
        end
    end)
end

Begin = function()
    local phase = CharacterV2Flow.State().phase
    if opening or currentCharacterId or phase == 'selection'
        or phase == 'creator' or phase == 'activating' then return end
    opening = true
    CreateThread(function()
        local ok, problem = xpcall(function()
            while not NetworkIsSessionStarted() or PlayerPedId() == 0 do Wait(250) end
            SetEntityVisible(PlayerPedId(), false)
            FreezeEntityPosition(PlayerPedId(), true)
            DisplayRadar(false)
            local routed
            for _ = 1, 20 do
                routed = Rpc('character.selection.route.enter.v1', {})
                if routed.ok then break end
                Wait(1000)
            end
            Require(routed, 'Enter selection route')
            Require(CharacterV2Flow.Transition('selection'), 'Begin selection')
            OpenSelection()
        end, debug.traceback)
        if not ok then Log('bootstrap failed', problem) end
        opening = false
    end)
end

RegisterCommand('logout', function()
    if CharacterV2Flow.State().phase == 'activating' then
        activationLogoutRequested = true
        CharacterV2Arrival.Cleanup()
        Log('activation: logout requested')
        return
    end
    if not currentCharacterId then return end
    Run('logout', function()
        CharacterV2Arrival.Cleanup()
        local previous = currentCharacterId
        Require(CharacterV2Checkpoints.Run({ characterId = previous, reason = 'logout' }),
            'Logout checkpoint')
        Require(Rpc('character.logout.v1', { position = CurrentPosition() }), 'Logout')
        currentCharacterId = nil
        generation = generation + 1
        TriggerEvent('Feather:Character:Logout', { characterId = previous, reason = 'logout' })
        Begin()
    end)
end, false)

RegisterCommand('savequit', function()
    if not currentCharacterId then return end
    Run('save and quit', function()
        CharacterV2Arrival.Cleanup()
        local previous = currentCharacterId
        Require(CharacterV2Checkpoints.Run({ characterId = previous, reason = 'save_quit' }),
            'Save and quit checkpoint')
        DoScreenFadeOut(250)
        Wait(300)
        Require(Rpc('character.quit.v1', { position = CurrentPosition() }), 'Save and quit')
    end)
end, false)

exports('HasActiveCharacter', function()
    return currentCharacterId ~= nil
end)

CreateThread(Begin)
AddEventHandler('playerSpawned', Begin)
AddEventHandler('onClientResourceStop', function(resource)
    if resource == GetCurrentResourceName() then CloseMenu() end
end)

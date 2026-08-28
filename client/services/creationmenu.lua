-- Builds the full character-creation menu tree: main page (name/dob/desc/
-- gender/model) -> Customization -> Appearance/Clothing/Makeup/Hair
-- sub-pages, each registered as a nested CharacterMenu page the same way
-- (RegisterElement per option, live-applying via the client/helpers/
-- character.lua AddComponent/SetCharExpression helpers as the player
-- adjusts sliders/pickers). `SelectedAttributeElements` (client/helpers/
-- general.lua) and `selectedClothingElements`/`SelectedOverlayElements`
-- (this file) accumulate the in-progress character's state as the player
-- moves through these pages; the final "Create" button (near the bottom of
-- this file) submits all of it through the atomic Contract 1 creation route.
local firstName, lastName, gender, charDesc, textureId, tx_color_type = '', '', GetGender(), "", -1, 0
-- Town choice now happens here at creation time instead of a second picker
-- after spawn.lua's SpawnSelect (see spawner.lua) -- defaults to the first
-- configured town so a save without ever touching the arrows still lands
-- somewhere valid.
local SelectedTownIndex = 1
selectedClothingElements = {}
selectedClothingTints = {} -- (CHAR-20) index -> {c1,c2,c3}, see clothing/clothing_pages.lua
ActiveTexture, ActiveColor1, ActiveColor2, ActiveColor3, ActiveOpacity, ActiveVariant, CamZ, SelectedOverlayElements = {}, {}, {}, {}, {}, {}, Config.CameraCoords.creation.z + 0.5, {}

Pages = Pages or {}
Fov = 20.0
Model = 'mp_male'
local dob, imgLink

local function ApplyDefaultHair(selectedGender)
    local catalog = HairandBeards[selectedGender]
    local default = catalog and catalog.hair and catalog.hair[1] and catalog.hair[1][1]
    if not default or not default.hash then return false end
    SelectedAttributeElements.hairCategory = { hash = default.hash }
    SelectedAttributeElements.hairVariant = { hash = default.hash }
    AddComponent(PlayerPedId(), default.hash, 'hair')
    return true
end

-- Server-pushed once the player has walked to the creation camera spot
-- (client/services/character/create.lua).
RegisterNetEvent('feather-character:CreateCharacterMenu', function()
    PageOpened = true
    gender = GetGender()
    Model = gender == 'Female' and 'mp_female' or 'mp_male'
    ApplyDefaultHair(gender)
    local mainCreationPage = CharacterMenu:RegisterPage('feather-character:MainCreationPage')
    mainCreationPage:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "charCreation"),
        slot = "header",
        style = {}
    })
    local maleLabel   = FeatherCore.Locale.translate(0, "male")
    local femaleLabel = FeatherCore.Locale.translate(0, "female")

    mainCreationPage:RegisterElement('arrows', {
        label = FeatherCore.Locale.translate(0, "gender"),
        start = 1,
        options = { maleLabel, femaleLabel },
    }, function(data)
        -- (CHAR-11) `gender` was captured once from GetGender() at file
        -- load (module scope, line 12) and never updated -- picking a
        -- different gender here correctly changed `Model`, but every
        -- CharacterConfig.General.DefaultChar[gender] lookup in the
        -- appearance/heritage pages below kept indexing with whatever
        -- gender the player happened to already be at menu load, handing a
        -- player who picked Female the Male heritage/head/body/leg pools
        -- (or vice versa).
        if data.value == maleLabel then
            Model = 'mp_male'
            gender = 'Male'
        else
            Model = 'mp_female'
            gender = 'Female'
        end
        LoadPlayer(Model)
        ApplyDefaultHair(gender)
    end)


    mainCreationPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "custChar"),
        style = {}
    }, function()
        Pages.categoriesPage = CharacterMenu:RegisterPage('feather-character:CustomizationPage')
        Pages.categoriesPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "appearance"),
            style = {}
        }, function()
            local mainAppearanceMenu = CharacterMenu:RegisterPage('feather-character:MainAppearanceMenu')
            mainAppearanceMenu:RegisterElement('header', {
                value = FeatherCore.Locale.translate(0, "appearanceMenu"),
                slot = "header",
                style = {}
            })
            local heritageDisplay, headVariantSlider, bodyVariantSlider, legVariantSlider = nil, nil, nil, nil
            mainAppearanceMenu:RegisterElement('slider', {
                label = FeatherCore.Locale.translate(0, "heritage"),
                start = 1,
                min = 1,
                max = #CharacterConfig.General.DefaultChar[gender],
                steps = 1
            }, function(data)
                Race = data.value
                SelectedAttributeElements['Albedo'] = {
                    hash = tonumber(CharacterConfig.General.DefaultChar[gender]
                        [Race].HeadTexture[1])
                }
                AddComponent(PlayerPedId(), tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Heads[1]),
                    nil)
                AddComponent(PlayerPedId(), tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Body[1]),
                    nil)
                AddComponent(PlayerPedId(), tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Legs[1]),
                    nil)
                if heritageDisplay then
                    heritageDisplay:update({
                        value = CharacterConfig.General.DefaultChar[gender][Race].label,
                    })
                end
                if headVariantSlider then
                    headVariantSlider = headVariantSlider:update({
                        value = 1,
                    })
                end
                if bodyVariantSlider then
                    bodyVariantSlider = bodyVariantSlider:update({
                        value = 1,
                    })
                end
                if legVariantSlider then
                    legVariantSlider = legVariantSlider:update({
                        value = 1,
                    })
                end
            end)
            heritageDisplay = mainAppearanceMenu:RegisterElement('textdisplay', {
                value = FeatherCore.Locale.translate(0, "european"),
                style = {}
            })
            headVariantSlider = mainAppearanceMenu:RegisterElement('slider', {
                label = FeatherCore.Locale.translate(0, "headVars"),
                start = 1,
                min = 1,
                max = #CharacterConfig.General.DefaultChar[gender][1].Heads,
                steps = 1,
            }, function(data)
                local value = data.value
                local Head
                if Race == nil then
                    Head = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][1].Heads[value])
                else
                    Head = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Heads[value])
                end
                AddComponent(PlayerPedId(), Head, nil)
                SelectedAttributeElements['Head'] = { hash = Head }
            end)
            bodyVariantSlider = mainAppearanceMenu:RegisterElement('slider', {
                label = FeatherCore.Locale.translate(0, "bodyVars"),
                start = 1,
                min = 1,
                max = #CharacterConfig.General.DefaultChar[gender][1].Body,
                steps = 1
            }, function(data)
                local value = data.value
                local body
                if Race == nil then
                    body = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][1].Body[value])
                else
                    body = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Body[value])
                end
                AddComponent(PlayerPedId(), body, nil)
                SelectedAttributeElements['Body'] = { hash = body }
            end)
            legVariantSlider = mainAppearanceMenu:RegisterElement('slider', {
                label = FeatherCore.Locale.translate(0, "legVars"),
                start = 1,
                min = 1,
                max = #CharacterConfig.General.DefaultChar[gender][1].Legs,
                steps = 1
            }, function(data)
                local value = data.value
                local legs
                if Race == nil then
                    legs = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][1].Legs[value])
                else
                    legs = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Legs[value])
                end
                AddComponent(PlayerPedId(), legs, nil)
                SelectedAttributeElements['Legs'] = { hash = legs }
            end)
            mainAppearanceMenu:RegisterElement('button', {
                label = FeatherCore.Locale.translate(0, "hair"),
                style = {}
            }, function()
                OpenHairCategoryMenu(mainAppearanceMenu, gender)
            end)
            mainAppearanceMenu:RegisterElement('button', {
                label = FeatherCore.Locale.translate(0, "facialAdjustments"),
                style = {}
            }, function()
                OpenFaceAdjustmentsMenu(mainAppearanceMenu, gender)
            end)

            mainAppearanceMenu:RegisterElement('button', {
                label = FeatherCore.Locale.translate(0, "facialFeatures"),
                style = {}
            }, function()
                OpenFacialFeaturesMenu(mainAppearanceMenu, gender)
            end)

            mainAppearanceMenu:RegisterElement('line', {
                slot = "footer",
                style = {}
            })
            mainAppearanceMenu:RegisterElement('button', {
                label = FeatherCore.Locale.translate(0, "goBack"),
                slot = 'footer',
                style = {}
            }, function()
                SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
                    Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                Pages.categoriesPage:RouteTo()
            end)

            mainAppearanceMenu:RegisterElement('bottomline', {
                slot = "footer",
                style = {}
            })

            mainAppearanceMenu:RouteTo()
        end)
        Pages.categoriesPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "body"),
            style = {}
        }, function()
            OpenBodyCustomizationMenu(Pages.categoriesPage, gender)
        end)

        Pages.categoriesPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "clothing"),
            style = {}
        }, function()
            OpenClothingMenu(Pages.categoriesPage, gender)
        end)

        Pages.categoriesPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "makeup"),
            style = {}
        }, function()
            -- inside categoriesPage clothing/makeup button handler:
            OpenMakeupMenu(Pages.categoriesPage, gender)
        end)
        Pages.categoriesPage:RegisterElement('header', {
            value = FeatherCore.Locale.translate(0, "clothingSelection"),
            slot = "header",
            style = {}
        })
        Pages.categoriesPage:RegisterElement('line', {
            slot = "footer",
            style = {}
        })
        Pages.categoriesPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "goBack"),
            slot = 'footer',
            style = {}
        }, function()
            mainCreationPage:RouteTo()
        end)
        Pages.categoriesPage:RegisterElement('bottomline', {
            slot = "footer",
            style = {}
        })
        Pages.categoriesPage:RouteTo()
    end)

    mainCreationPage:RegisterElement('input', {
        label = FeatherCore.Locale.translate(0, "firstName"),
        placeholder = FeatherCore.Locale.translate(0, "enterFirstName"),
        style = {}
    }, function(data)
        firstName = data.value
    end)
    mainCreationPage:RegisterElement('input', {
        label = FeatherCore.Locale.translate(0, "lastName"),
        placeholder = FeatherCore.Locale.translate(0, "enterLastName"),
        style = {}
    }, function(data)
        lastName = data.value
    end)
    mainCreationPage:RegisterElement('input', {
        label = FeatherCore.Locale.translate(0, "dob"),
        placeholder = FeatherCore.Locale.translate(0, "enterDOB"),
        style = {}
    }, function(data)
        dob = data.value
    end)
    mainCreationPage:RegisterElement('textarea', {
        label = FeatherCore.Locale.translate(0, "charDesc"),
        placeholder = FeatherCore.Locale.translate(0, "enterCharDesc"),
        rows = "5",
        resize = false,
        style = {}
    }, function(data)
        charDesc = data.value
    end)
    mainCreationPage:RegisterElement('input', {
        label = FeatherCore.Locale.translate(0, "imgLink"),
        placeholder = FeatherCore.Locale.translate(0, "enterImgLink"),
        style = {}
    }, function(data)
        imgLink = data.value
    end)
    if imgLink == nil then
        imgLink = 'None'
    end

    -- Starting town/arrival is chosen here and persisted as a trusted
    -- Contract 1 spawn-point ID. There is no second town choice after this.
    local townOptions = {}
    for _, town in ipairs(Config.SpawnCoords.towns) do
        table.insert(townOptions, town.name .. " (" .. town.arrival .. ")")
    end
    mainCreationPage:RegisterElement('arrows', {
        label = FeatherCore.Locale.translate(0, "chooseCity"),
        start = SelectedTownIndex,
        options = townOptions,
    }, function(data)
        -- `persistindex` is the 0-based index feather-menu's arrows element
        -- posts alongside `value` (see ArrowSelectorComp.vue) -- convert to
        -- the 1-based index Config.SpawnCoords.towns actually uses.
        SelectedTownIndex = data.persistindex + 1
    end)

    mainCreationPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    -- Commits profile, initial appearance, and spawn state atomically through
    -- Contract 1. A successful create immediately activates the new UUID
    -- character and plays the selected city's first-arrival journey.
    mainCreationPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "saveChar"),
        slot = 'footer',
        style = {}
    }, function()
        local fName       = firstName
        local lName       = lastName
        local dateOfBirth = dob or ""
        local model       = Model
        local description = charDesc
        local imageUrl    = imgLink or "None"

        -- validations
        if fName == "" then
            Notify(FeatherCore.Locale.translate(0, "firstNameRequired"), "error", 5000)
            return
        end

        if lName == "" then
            Notify(FeatherCore.Locale.translate(0, "lastNameRequired"), "error", 5000)
            return
        end

        if not dateOfBirth or dateOfBirth == "" then
            Notify(FeatherCore.Locale.translate(0, "validDobRequired"), "error", 5000)
            return
        end

        -- UX guard only. The Contract 1 server independently validates the
        -- mapped spawn-point ID against its configured registry.
        if not SelectedTownIndex or not Config.SpawnCoords.towns[SelectedTownIndex] then
            Notify(FeatherCore.Locale.translate(0, "chooseCity"), "error", 5000)
            return
        end

        local data           = {
            firstname = fName,
            lastname  = lName,
            dob       = dateOfBirth,
            model     = model,
            desc      = description,
            img       = imageUrl,
            townindex = SelectedTownIndex,
        }

        local created = CharacterContract1.Create(data, {
            clothing = selectedClothingElements or {},
            tints = selectedClothingTints or {},
            attributes = SelectedAttributeElements or {},
            overlays = SelectedOverlayElements or {}
        })
        if created then
            Notify(FeatherCore.Locale.translate(0, "characterSaved"), "success", 4000)
        end
    end)

    mainCreationPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    CharacterMenu:Open({
        startupPage = mainCreationPage
    })
end)

RegisterNetEvent('FeatherMenu:closed', function(data)
    MenuOpened = false
end)

--Global function goes here as our local textureId is used
function ChangeOverlay(ped, name, visibility, tx_id, tx_normal, tx_material, tx_color_type, tx_opacity, tx_unk,
                       palette_id, palette_color_primary, palette_color_secondary, palette_color_tertiary, var, opacity,
                       albedo)
    local layer = OverlayAllLayers[name]
    layer.visibility = visibility
    if visibility ~= 0 then
        layer.tx_normal = tx_normal
        layer.tx_material = tx_material
        layer.tx_color_type = tx_color_type
        layer.tx_opacity = tx_opacity
        layer.tx_unk = tx_unk
        if tx_color_type == 0 then
            local colorPalettes = {
                { 0x3F6E70FF },
                { 0x0105607B },
                { 0x17CBCC83 },
                { 0x29F81B2A },
                { 0x3385C5DB },
                { 0x37CD36D4 },
                { 0x4101ED87 },
                { 0x63838A81 },
                { 0x6765BC15 },
                { 0x8BA18876 },
                { 0x9AC34F34 },
                { 0x9E4803A0 },
                { 0xA4041CEF },
                { 0xA4CFABD0 },
                { 0xAA65D8A3 },
                { 0xB562025C },
                { 0xB9E7F722 },
                { 0xBBF43EF8 },
                { 0xD1476963 },
                { 0xD799E1C2 },
                { 0xDC6BC93B },
                { 0xDFB1F64C },
                { 0xF509C745 },
                { 0xF93DB0C8 },
                { 0xFB71527B }
            }
            layer.palette = colorPalettes[palette_id][1]
            layer.palette_color_primary = palette_color_primary
            layer.palette_color_secondary = palette_color_secondary
            layer.palette_color_tertiary = palette_color_tertiary
        end
        if name == "shadows" or name == "eyeliners" or name == "lipsticks" then
            layer.var = var
            layer.tx_id = OverlayInfo[name][1].id
        else
            layer.var = 0
            layer.tx_id = OverlayInfo[name][tx_id].id
        end
        layer.opacity = opacity
    end
    if textureId ~= -1 then
        Citizen.InvokeNative(0xB63B9178D0F58D82, textureId)
        Citizen.InvokeNative(0x6BEFAA907B076859, textureId)
    end
    local textureTypes = {
        ["Male"] = {
            albedo = GetHashKey("head_fr1_sc08_soft_c0_001_ab"),
            normal = GetHashKey("mp_head_mr1_000_nm"),
            material = 0x50A4BBA9,
            color_type = 1,
            texture_opacity = 1.0,
            unk_arg = 0
        },
        ["Female"] = {
            albedo = GetHashKey("mp_head_fr1_sc08_c0_000_ab"),
            normal = GetHashKey("head_fr1_mp_002_nm"),
            material = 0x7FC5B1E1,
            color_type = 1,
            texture_opacity = 1.0,
            unk_arg = 0
        }
    }
    local current_texture_settings = textureTypes[gender]
    if visibility > 0 then
        textureId = Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, current_texture_settings.normal,
            current_texture_settings.material)
    end
    for k, v in pairs(OverlayAllLayers) do
        if v.visibility and v.visibility ~= 0 then
            local overlay_id = Citizen.InvokeNative(0x86BB5FF45F193A02, textureId, v.tx_id, v.tx_normal, v.tx_material,
                v.tx_color_type, v.tx_opacity, v.tx_unk)
            if v.tx_color_type == 0 then
                Citizen.InvokeNative(0x1ED8588524AC9BE1, textureId, overlay_id, v.palette)
                Citizen.InvokeNative(0x2DF59FFE6FFD6044, textureId, overlay_id, v.palette_color_primary,
                    v.palette_color_secondary, v.palette_color_tertiary)
            end
            Citizen.InvokeNative(0x3329AAE2882FC8E4, textureId, overlay_id, v.var)
            Citizen.InvokeNative(0x6C76BC24F8BB709A, textureId, overlay_id, v.opacity)
        end
    end
    while not Citizen.InvokeNative(0x31DC8D3F216D8509, textureId) do
        Wait(5)
    end
    Citizen.InvokeNative(0x92DAABA2C1C10B0E, textureId)
    Citizen.InvokeNative(0x0B46E25761519058, ped, joaat("heads"), textureId)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
end

-- global funct goes here as our local tx_color_type is used
function SetDefaultValues(selected) -- make local in creation menu
    if ActiveTexture[selected] == nil then
        ActiveTexture[selected] = 1
    end
    if ActiveColor1[selected] == nil then
        ActiveColor1[selected] = 1
    end
    if ActiveColor2[selected] == nil then
        ActiveColor2[selected] = 1
    end
    if ActiveColor3[selected] == nil then
        ActiveColor3[selected] = 1
    end
    if ActiveVariant[selected] == nil then
        ActiveVariant[selected] = 1
    end
    if ActiveOpacity[selected] == nil then
        ActiveOpacity[selected] = 1.0
    end
    if selected == "scars" or selected == "spots" or selected == "disc" or selected == "complex" or selected == "acne" or selected == "ageing" or selected == "moles" or selected == "freckles" then
        tx_color_type = 1
    else
        tx_color_type = 0
    end
end

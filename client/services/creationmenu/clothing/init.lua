-- creationmenu/clothing/init.lua
function OpenClothingMenu(parentPage, gender)
    local clothingCategoriesPage = CharacterMenu:RegisterPage('feather-character:ClothingCategoriesPage')

    clothingCategoriesPage:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "clothingSelection"),
        slot = "header",
        style = {}
    })

    -- Categories
    local categories = {}
    if CharacterConfig and CharacterConfig.Clothing and CharacterConfig.Clothing.Clothes
        and CharacterConfig.Clothing.Clothes[gender] then
        for categoryKey, _ in pairs(CharacterConfig.Clothing.Clothes[gender]) do
            table.insert(categories, categoryKey)
        end
    else
        categories = { "Upper", "Lower", "Accessories" }
    end
    table.sort(categories, function(a, b)
        local order = { Upper = 1, Lower = 2, Accessories = 3 }
        return (order[a] or 99) < (order[b] or 99)
    end)

    for _, categoryKey in ipairs(categories) do
        local localeKey = string.lower(categoryKey)
        local label     = FeatherCore.Locale.translate(0, localeKey) or categoryKey

        clothingCategoriesPage:RegisterElement('button', {
            label = label, style = {}
        }, function()
            local preset = GetClothingCamPreset(categoryKey)
            SwitchCam(
                Config.CameraCoords.creation.x + preset.xOff,
                Config.CameraCoords.creation.y + preset.yOff,
                Config.CameraCoords.creation.z + preset.zOff,
                Config.CameraCoords.creation.h,
                Config.CameraCoords.creation.zoom + preset.zoomDelta
            )
            CamZ = Config.CameraCoords.creation.z + preset.camZDelta

            OpenClothingCategoryPage(clothingCategoriesPage, gender, categoryKey)
        end)
    end

    clothingCategoriesPage:RegisterElement('line', { slot = "footer", style = {} })
    clothingCategoriesPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "goBack"),
        slot = "footer",
        style = {}
    }, function()
        Pages.categoriesPage:RouteTo()
    end)
    clothingCategoriesPage:RegisterElement('bottomline', { slot = "footer", style = {} })

    clothingCategoriesPage:RouteTo()
end

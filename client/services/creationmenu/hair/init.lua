function OpenHairCategoryMenu(mainAppearanceMenu, gender)
    local hairCategoryPage = CharacterMenu:RegisterPage('feather-character:HairCategoryPage')

    hairCategoryPage:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "hairPage"),
        slot = "header",
        style = {}
    })

    hairCategoryPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "hair"),
        style = {}
    }, function()
        SwitchCam(
            Config.CameraCoords.creation.x - 0.25,
            Config.CameraCoords.creation.y,
            Config.CameraCoords.creation.z + 0.7,
            Config.CameraCoords.creation.h,
            0.0
        )
        OpenHairPage(mainAppearanceMenu, gender)
    end)

    hairCategoryPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "beard"),
        style = {}
    }, function()
        SwitchCam(
            Config.CameraCoords.creation.x - 0.25,
            Config.CameraCoords.creation.y,
            Config.CameraCoords.creation.z + 0.7,
            Config.CameraCoords.creation.h,
            0.0
        )
        OpenBeardPage(mainAppearanceMenu, gender)
    end)

    hairCategoryPage:RegisterElement('line', { 
        slot = "footer", 
        style = {} 
    })
    hairCategoryPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "goBack"),
        slot = 'footer',
        style = {}
    }, function()
        SwitchCam(
            Config.CameraCoords.creation.x,
            Config.CameraCoords.creation.y,
            Config.CameraCoords.creation.z,
            Config.CameraCoords.creation.h,
            Config.CameraCoords.creation.zoom
        )
        mainAppearanceMenu:RouteTo()
    end)
    hairCategoryPage:RegisterElement('bottomline', { slot = "footer", style = {} })

    hairCategoryPage:RouteTo()
end

function OpenFaceAdjustmentsMenu(mainAppearanceMenu, gender)
    local faceAdjMenu = CharacterMenu:RegisterPage('feather-character:FaceAdjMenu')

    faceAdjMenu:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "facialAdjustments"),
        slot = "header",
        style = {}
    })
    for key, v in pairs(FaceFeatures.Adjustments) do
        faceAdjMenu:RegisterElement('button', {
            label = key,
            style = {}
        }, function()
            if key == FeatherCore.Locale.translate(0, "eyebrowPage") then
                OpenEyesAndBrowsPage(mainAppearanceMenu, gender)
                return
            end
            if key == FeatherCore.Locale.translate(0, "cheeksPage") then
                OpenCheeksPage(mainAppearanceMenu, gender)
                return
            end
            if key == FeatherCore.Locale.translate(0, "chinPage") then
                OpenChinPage(mainAppearanceMenu, gender)
                return
            end
            if key == FeatherCore.Locale.translate(0, "earsPage") then
                OpenEarsPage(mainAppearanceMenu, gender)
                return
            end
            if key == FeatherCore.Locale.translate(0, "mouthPage") then
                OpenMouthPage(mainAppearanceMenu, gender)
                return
            end
            if key == FeatherCore.Locale.translate(0, "nosePage") then
                OpenNosePage(mainAppearanceMenu, gender)
                return
            end
            if key == FeatherCore.Locale.translate(0, "jawPage") then
                OpenJawPage(mainAppearanceMenu, gender)
                return
            end
        end)
    end

    faceAdjMenu:RegisterElement('line', { 
        slot = "footer", 
        style = {} 
    })
    faceAdjMenu:RegisterElement('button', {
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

    SwitchCam(
        Config.CameraCoords.creation.x - 0.25,
        Config.CameraCoords.creation.y,
        Config.CameraCoords.creation.z + 0.7,
        Config.CameraCoords.creation.h,
        0.0
    )
    faceAdjMenu:RegisterElement('bottomline', { 
        slot = "footer", 
        style = {}
    })
    faceAdjMenu:RouteTo()
end

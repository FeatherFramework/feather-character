-- client/creationmenu/facialadjustments/mouth.lua

function OpenMouthPage(mainAppearanceMenu, gender)
    local mouthPage = CharacterMenu:RegisterPage('feather-character:MouthPage')

    mouthPage:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "mouthPage"),
        slot = "header",
        style = {}
    })

    local UpperLipGrid = mouthPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "upperLipWidthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "upperLipWidthPlus"),
        toplabel = FeatherCore.Locale.translate(0, "upperLipHeightPlus"),
        bottomlabel = FeatherCore.Locale.translate(0, "upperLipHeightMinus"),
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0x91C1, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 0x1A00, tonumber(data.value.y))
        SelectedAttributeElements['UpLipWidth']  = { value = tonumber(data.value.x), hash = 0x91C1 }
        SelectedAttributeElements['UpLipHeight'] = { value = tonumber(data.value.y), hash = 0x1A00 }
        UpdatePedVariation(PlayerPedId())
    end)

    local UpperLipGrid2 = mouthPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "upperLipDepthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "upperLipDepthPlus"),
        maxx = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0xC375, tonumber(data.value.x))
        SelectedAttributeElements['UpLipDepth'] = { value = tonumber(data.value.x), hash = 0xC375 }
        UpdatePedVariation(PlayerPedId())
    end)

    local LowerLipGrid = mouthPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "lowerLipWidthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "lowerLipWidthPlus"),
        toplabel = FeatherCore.Locale.translate(0, "lowerLipHeightPlus"),
        bottomlabel = FeatherCore.Locale.translate(0, "lowerLipHeightMinus"),
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0xB0B0, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 0xBB4D, tonumber(data.value.y))
        SelectedAttributeElements['LowLipWidth']  = { value = tonumber(data.value.x), hash = 0xB0B0 }
        SelectedAttributeElements['LowLipHeight'] = { value = tonumber(data.value.y), hash = 0xBB4D }
        UpdatePedVariation(PlayerPedId())
    end)

    local LowerLipGrid2 = mouthPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "lowerLipDepthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "lowerLipDepthPlus"),
        maxx = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0x5D16, tonumber(data.value.x))
        SelectedAttributeElements['LowLipDepth'] = { value = tonumber(data.value.x), hash = 0x5D16 }
        UpdatePedVariation(PlayerPedId())
    end)

    local MouthTuning = mouthPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "mouthWidthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "mouthWidthPlus"),
        toplabel = FeatherCore.Locale.translate(0, "mouthDepthPlus"),
        bottomlabel = FeatherCore.Locale.translate(0, "mouthDepthMinus"),
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 61541, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 43625, tonumber(data.value.y))
        SelectedAttributeElements['MouthWidth'] = { value = tonumber(data.value.x), hash = 61541 }
        SelectedAttributeElements['MouthDepth'] = { value = tonumber(data.value.y), hash = 43625 }
        UpdatePedVariation(PlayerPedId())
    end)

    local MouthPlacement = mouthPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "mouthXPosMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "mouthXPosPlus"),
        toplabel = FeatherCore.Locale.translate(0, "mouthYPosPlus"),
        bottomlabel = FeatherCore.Locale.translate(0, "mouthYPosMinus"),
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 31427, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 16653, tonumber(data.value.y))
        SelectedAttributeElements['MouthXPos'] = { value = tonumber(data.value.x), hash = 31427 }
        SelectedAttributeElements['MouthYPos'] = { value = tonumber(data.value.y), hash = 16653 }
    end)

    mouthPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    mouthPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "goBack"),
        slot = 'footer',
        style = {}
    }, function()
        SwitchCam(
            Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
            Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom
        )
        OpenFaceAdjustmentsMenu(mainAppearanceMenu, gender)
    end)
    mouthPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    mouthPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "moveCamUp"),
        current = FeatherCore.Locale.translate(0, "moveCamDown"),
        style = {}
    }, function(data)
        if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
        SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
    end)

    mouthPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "rotateRight"),
        current = FeatherCore.Locale.translate(0, "rotateLeft"),
        style = {}
    }, function(data)
        local heading = GetEntityHeading(PlayerPedId())
        if data.value == 'forward' then heading = heading + 10.0 else heading = heading - 10.0 end
        SetEntityHeading(PlayerPedId(), heading)
    end)

    mouthPage:RouteTo()
end

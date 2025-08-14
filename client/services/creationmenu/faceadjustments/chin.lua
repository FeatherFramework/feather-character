function OpenChinPage(mainAppearanceMenu, gender)
    local chinPage = CharacterMenu:RegisterPage('feather-character:ChinPage')

    chinPage:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "chinPage"),
        slot = "header",
        style = {}
    })
    local ChinGrid1 = chinPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "chinWidthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "chinWidthPlus"),
        toplabel = FeatherCore.Locale.translate(0, "chinHeightPlus"),
        bottomlabel = FeatherCore.Locale.translate(0, "chinHeightMinus"),
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0xC3B2, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 0x3C0F, tonumber(data.value.y))
        SelectedAttributeElements['ChinWidth']  = { value = tonumber(data.value.x), hash = 0xC3B2 }
        SelectedAttributeElements['ChinHeight'] = { value = tonumber(data.value.y), hash = 0x3C0F }
        UpdatePedVariation(PlayerPedId())
    end)
    local ChinGrid2 = chinPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "chinDepthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "chinDepthPlus"),
        maxx = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0xE323, tonumber(data.value.x))
        SelectedAttributeElements['ChinDepth'] = { value = tonumber(data.value.x), hash = 0xE323 }
        UpdatePedVariation(PlayerPedId())
    end)
    chinPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })
    chinPage:RegisterElement('button', {
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
    chinPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })
    chinPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "moveCamUp"),
        current = FeatherCore.Locale.translate(0, "moveCamDown"),
        style = {}
    }, function(data)
        if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
        SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
    end)
    chinPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "rotateRight"),
        current = FeatherCore.Locale.translate(0, "rotateLeft"),
        style = {}
    }, function(data)
        local heading = GetEntityHeading(PlayerPedId())
        if data.value == 'forward' then heading = heading + 10.0 else heading = heading - 10.0 end
        SetEntityHeading(PlayerPedId(), heading)
    end)
    chinPage:RouteTo()
end

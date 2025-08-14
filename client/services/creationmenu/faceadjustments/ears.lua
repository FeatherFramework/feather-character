function OpenEarsPage(mainAppearanceMenu, gender)
    local earPage = CharacterMenu:RegisterPage('feather-character:EarPage')

    earPage:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "earPage"),
        slot = "header",
        style = {}
    })
    local EarGrid1 = earPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "earWidthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "earWidthPlus"),
        toplabel = FeatherCore.Locale.translate(0, "earHeightPlus"),
        bottomlabel = FeatherCore.Locale.translate(0, "earHeightMinus"),
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0xC04F, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 0x2844, tonumber(data.value.y))
        SelectedAttributeElements['EarWidth']  = { value = tonumber(data.value.x), hash = 0xC04F }
        SelectedAttributeElements['EarHeight'] = { value = tonumber(data.value.y), hash = 0x2844 }
        UpdatePedVariation(PlayerPedId())
    end)
    local EarGrid2 = earPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "earlobeSizeMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "earlobeSizePlus"),
        toplabel = FeatherCore.Locale.translate(0, "earAnglePlus"),
        bottomlabel = FeatherCore.Locale.translate(0, "earAngleMinus"),
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0xED30, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 0xB6CE, tonumber(data.value.y))
        SelectedAttributeElements['EarSize']  = { value = tonumber(data.value.x), hash = 0xED30 }
        SelectedAttributeElements['EarAngle'] = { value = tonumber(data.value.y), hash = 0xB6CE }
        UpdatePedVariation(PlayerPedId())
    end)
    earPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })
    earPage:RegisterElement('button', {
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
    earPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })
    earPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "moveCamUp"),
        current = FeatherCore.Locale.translate(0, "moveCamDown"),
        style = {}
    }, function(data)
        if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
        SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
    end)

    earPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "rotateRight"),
        current = FeatherCore.Locale.translate(0, "rotateLeft"),
        style = {}
    }, function(data)
        local heading = GetEntityHeading(PlayerPedId())
        if data.value == 'forward' then heading = heading + 10.0 else heading = heading - 10.0 end
        SetEntityHeading(PlayerPedId(), heading)
    end)
    earPage:RouteTo()
end

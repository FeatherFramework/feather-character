-- client/creationmenu/facialadjustments/jaw.lua

function OpenJawPage(mainAppearanceMenu, gender)
    local jawPage = CharacterMenu:RegisterPage('feather-character:JawPage')

    jawPage:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "jawPage"),
        slot = "header",
        style = {}
    })

    local JawGrid1 = jawPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "jawWidthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "jawWidthPlus"),
        toplabel = FeatherCore.Locale.translate(0, "jawHeightPlus"),
        bottomlabel = FeatherCore.Locale.translate(0, "jawHeightMinus"),
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0xEBAE, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 0x8D0A, tonumber(data.value.y))
        SelectedAttributeElements['JawWidth']  = { value = tonumber(data.value.x), hash = 0xEBAE }
        SelectedAttributeElements['JawHeight'] = { value = tonumber(data.value.y), hash = 0x8D0A }
        UpdatePedVariation(PlayerPedId())
    end)

    local JawGrid2 = jawPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "jawDepthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "jawDepthPlus"),
        maxx = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0x1DF6, tonumber(data.value.x))
        SelectedAttributeElements['JawDepth'] = { value = tonumber(data.value.x), hash = 0x1DF6 }
        UpdatePedVariation(PlayerPedId())
    end)

    jawPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    jawPage:RegisterElement('button', {
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
        OpenFaceAdjustmentsMenu(mainAppearanceMenu, gender)
    end)

    jawPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    jawPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "moveCamUp"),
        current = FeatherCore.Locale.translate(0, "moveCamDown"),
        style = {}
    }, function(data)
        if data.value == 'forward' then
            CamZ = CamZ + 0.1
        else
            CamZ = CamZ - 0.1
        end
        SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
    end)

    jawPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "rotateRight"),
        current = FeatherCore.Locale.translate(0, "rotateLeft"),
        style = {}
    }, function(data)
        local heading = GetEntityHeading(PlayerPedId())
        if data.value == 'forward' then
            heading = heading + 10.0
        else
            heading = heading - 10.0
        end
        SetEntityHeading(PlayerPedId(), heading)
    end)
    jawPage:RouteTo()
end

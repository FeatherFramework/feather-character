-- client/creationmenu/facialadjustments/nose.lua

function OpenNosePage(mainAppearanceMenu, gender)
    local nosePage = CharacterMenu:RegisterPage('feather-character:NosePage')

    nosePage:RegisterElement('header',{ 
        value = FeatherCore.Locale.translate(0, "nosePage"), 
        slot = "header", 
        style = {} 
    })

    local NoseGrid1 = nosePage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "noseWidthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "noseWidthPlus"),
        toplabel = FeatherCore.Locale.translate(0, "noseHeightPlus"),
        bottomlabel = FeatherCore.Locale.translate(0, "noseHeightMinus"),
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0x6E7F, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 0x03F5, tonumber(data.value.y))
        SelectedAttributeElements['NoseWidth']  = { value = tonumber(data.value.x), hash = 0x6E7F }
        SelectedAttributeElements['NoseHeight'] = { value = tonumber(data.value.y), hash = 0x03F5 }
        UpdatePedVariation(PlayerPedId())
    end)

    local NoseGrid2 = nosePage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "noseCurveMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "noseCurvePlus"),
        toplabel = FeatherCore.Locale.translate(0, "noseAnglePlus"),
        bottomlabel = FeatherCore.Locale.translate(0, "noseAngleMinus"),
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0xF156, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 0x34B1, tonumber(data.value.y))
        SelectedAttributeElements['NoseCurve'] = { value = tonumber(data.value.x), hash = 0xF156 }
        SelectedAttributeElements['NoseAngle'] = { value = tonumber(data.value.y), hash = 0x34B1 }
        UpdatePedVariation(PlayerPedId())
    end)

    local NoseGrid3 = nosePage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "noseSizeMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "noseSizePlus"),
        toplabel = FeatherCore.Locale.translate(0, "nostrilDistPlus"),
        bottomlabel = FeatherCore.Locale.translate(0, "nostrilDistMinus"),
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0x3471, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 0x561E, tonumber(data.value.y))
        UpdatePedVariation(PlayerPedId())
    end)
    nosePage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    nosePage:RegisterElement('button', {
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
    nosePage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    nosePage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "moveCamUp"),
        current = FeatherCore.Locale.translate(0, "moveCamDown"),
        style = {}
    }, function(data)
        if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
        SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
    end)

    nosePage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "rotateRight"),
        current = FeatherCore.Locale.translate(0, "rotateLeft"),
        style = {}
    }, function(data)
        local heading = GetEntityHeading(PlayerPedId())
        if data.value == 'forward' then heading = heading + 10.0 else heading = heading - 10.0 end
        SetEntityHeading(PlayerPedId(), heading)
    end)

    nosePage:RouteTo()
end

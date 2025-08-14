-- client/creationmenu/facialadjustments/cheeks.lua

function OpenCheeksPage(mainAppearanceMenu, gender)
    local cheekPage = CharacterMenu:RegisterPage('feather-character:CheekPage')

    cheekPage:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "cheeksPage"),
        slot = "header",
        style = {}
    })

    local CheekGrid1 = cheekPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "cheekboneWidthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "cheekboneWidthPlus"),
        toplabel = FeatherCore.Locale.translate(0, "cheekboneHeightPlus"),
        bottomlabel = FeatherCore.Locale.translate(0, "cheekboneHeightMinus"),
        maxx = 1, maxy = 1, arrowsteps = 10, precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0xABCF, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 0x6A0B, tonumber(data.value.y))
        SelectedAttributeElements['CheekboneWidth']  = { value = tonumber(data.value.x), hash = 0xABCF }
        SelectedAttributeElements['CheekboneHeight'] = { value = tonumber(data.value.y), hash = 0x6A0B }
        UpdatePedVariation(PlayerPedId())
    end)

    local CheekGrid2 = cheekPage:RegisterElement('gridslider', {
        leftlabel = FeatherCore.Locale.translate(0, "cheekboneDepthMinus"),
        rightlabel = FeatherCore.Locale.translate(0, "cheekboneDepthPlus"),
        maxx = 1, arrowsteps = 10, precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0x358D, tonumber(data.value.x))
        SelectedAttributeElements['CheekboneDepth'] = { value = tonumber(data.value.x), hash = 0x358D }
        UpdatePedVariation(PlayerPedId())
    end)

    cheekPage:RegisterElement('line', { 
        slot = "footer", 
        style = {} 
    })

    cheekPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "goBack"),
        slot = 'footer',
        style = {}
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        OpenFaceAdjustmentsMenu(mainAppearanceMenu, gender)
    end)

    cheekPage:RegisterElement('bottomline', { 
        slot = "footer", 
        style = {} 
    })

    cheekPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "moveCamUp"),
        current = FeatherCore.Locale.translate(0, "moveCamDown"),
        style = {}
    }, function(data)
        if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
        SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
    end)

    cheekPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "rotateRight"),
        current = FeatherCore.Locale.translate(0, "rotateLeft"),
        style = {}
    }, function(data)
        local heading = GetEntityHeading(PlayerPedId())
        if data.value == 'forward' then heading = heading + 10.0 else heading = heading - 10.0 end
        SetEntityHeading(PlayerPedId(), heading)
    end)

end

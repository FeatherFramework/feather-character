local function OpenGenericMakeupPage(parentMakeupPage, k, v)
    if not SelectedOverlayElements[v] then
        SelectedOverlayElements[v] = { textureId = 1, opacity = 1.0, variant = 1, color1 = 1, color2 = 1, color3 = 1 }
    end
    if SetDefaultValues then SetDefaultValues(v) end

    local activeMakeupPage = CharacterMenu:RegisterPage('feather-character:ActiveMakeupPage')

    activeMakeupPage:RegisterElement('header', {
        value = k,
        slot = "header",
        style = {}
    })
    activeMakeupPage:RegisterElement('subheader', {
        value = FeatherCore.Locale.translate(0, "chooseYour") .. v .. FeatherCore.Locale.translate(0, "options"),
        slot = "header",
        style = {}
    })


    activeMakeupPage:RegisterElement('slider', {
        label = v .. " " .. FeatherCore.Locale.translate(0, "opacity"),
        start = 1,
        min = 0,
        max = 1,
        steps = 0.1
    }, function(data)
        if data.value == 1 then data.value = 1.0 end
        ActiveOpacity[v] = data.value
        local vis = (data.value > 0) and 1 or 0
        ChangeOverlay(PlayerPedId(), v, vis, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1,
            ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v],
            SelectedAttributeElements['Albedo'].hash)
        SelectedOverlayElements[v]["opacity"] = ActiveOpacity[v]
    end)

    activeMakeupPage:RegisterElement("toggle", {
        label = v,
        start = false
    }, function(data)
        if data.value then
            ActiveTexture[v] = 1
            ChangeOverlay(PlayerPedId(), v, 1, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1,
                ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v],
                SelectedAttributeElements['Albedo'].hash)
            SelectedOverlayElements[v]["textureId"] = ActiveTexture[v]
        else
            ChangeOverlay(PlayerPedId(), v, 0, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1,
                ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v],
                SelectedAttributeElements['Albedo'].hash)
            ActiveTexture[v] = 0
            SelectedOverlayElements[v]["textureId"] = nil
        end
    end)

    activeMakeupPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })

    activeMakeupPage:RegisterElement('slider', {
        label = v .. ' ' .. FeatherCore.Locale.translate(0, "color1"),
        start = 1,
        min = 1,
        max = 254,
        steps = 1
    }, function(data)
        ActiveColor1[v] = data.value
        local vis = (ActiveColor1[v] > 0) and 1 or 0
        ChangeOverlay(PlayerPedId(), v, vis, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1,
            ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v],
            SelectedAttributeElements['Albedo'].hash)
        SelectedOverlayElements[v]["color1"] = ActiveColor1[v]
    end)

    if v ~= 'lipsticks' and v ~= 'foundation' then
        activeMakeupPage:RegisterElement('slider', {
            label = v .. " " .. FeatherCore.Locale.translate(0, "color2"),
            start = 1,
            min = 1,
            max = 254,
            steps = 1
        }, function(data)
            ActiveColor2[v] = data.value
            local vis = (ActiveColor2[v] > 0) and 1 or 0
            ChangeOverlay(PlayerPedId(), v, vis, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1,
                ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v],
                SelectedAttributeElements['Albedo'].hash)
            SelectedOverlayElements[v]["color2"] = ActiveColor2[v]
        end)

        activeMakeupPage:RegisterElement('slider', {
            label = v .. " " .. FeatherCore.Locale.translate(0, "color3"),
            start = 1,
            min = 1,
            max = 254,
            steps = 1
        }, function(data)
            ActiveColor3[v] = data.value
            local vis = (ActiveColor3[v] > 0) and 1 or 0
            ChangeOverlay(PlayerPedId(), v, vis, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1,
                ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v],
                SelectedAttributeElements['Albedo'].hash)
            SelectedOverlayElements[v]["color3"] = ActiveColor3[v]
        end)
    end

    activeMakeupPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })
    activeMakeupPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "goBack"),
        slot = 'footer',
        style = {}
    }, function()
        parentMakeupPage:RouteTo()
    end)
    activeMakeupPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    activeMakeupPage:RegisterElement('pagearrows', {
        total = FeatherCore.Locale.translate(0, "moveCamUp"),
        current = FeatherCore.Locale.translate(0, "moveCamDown"),
        slot = 'footer',
        style = {}
    }, function(data)
        if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
        SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
    end)
    activeMakeupPage:RegisterElement('pagearrows', {
        total = FeatherCore.Locale.translate(0, "rotateRight"),
        current = FeatherCore.Locale.translate(0, "rotateLeft"),
        slot = 'footer',
        style = {}
    }, function(data)
        local heading = GetEntityHeading(PlayerPedId())
        if data.value == 'forward' then SetEntityHeading(PlayerPedId(), heading + 10.0) else SetEntityHeading(
            PlayerPedId(), heading - 10.0) end
    end)
    activeMakeupPage:RouteTo()
end

function OpenMakeupMenu(categoriesPage, gender)
    local makeupPage = CharacterMenu:RegisterPage('feather-character:MakeupPage')

    makeupPage:RegisterElement('header',
        { value = FeatherCore.Locale.translate(0, "makeupPage"), slot = "header", style = {} })

    for k, v in pairs(FaceFeatures.Makeup) do
        makeupPage:RegisterElement('button', {
            label = k,
            style = {}
        }, function()
            if v == 'eyeliners' then
                OpenEyelinerMakeupPage(makeupPage)
            elseif v == 'shadows' then
                OpenShadowsMakeupPage(makeupPage)
            elseif v == 'lipsticks' then
                OpenLipsticksMakeupPage(makeupPage)
            elseif v == 'foundation' then
                OpenFoundationMakeupPage(makeupPage)
            else
                OpenGenericMakeupPage(makeupPage, k, v)
            end
        end)
    end

    makeupPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })
    makeupPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "goBack"),
        slot = 'footer',
        style = {}
    }, function()
        categoriesPage:RouteTo()
    end)

    makeupPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    SwitchCam(
        Config.CameraCoords.creation.x - 0.25, Config.CameraCoords.creation.y,
        Config.CameraCoords.creation.z + 0.7, Config.CameraCoords.creation.h, 0.0
    )
    makeupPage:RouteTo()
end

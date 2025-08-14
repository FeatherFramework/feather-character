function OpenBodyCustomizationMenu(mainAppearanceMenu, gender)
    local bodyPage = CharacterMenu:RegisterPage('feather-character:BodyPage')
    local bodySlidersMade = nil

    bodyPage:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "bodyPage"),
        slot = "header",
        style = {}
    })

    if bodySlidersMade == nil then
        bodySlidersMade = true

        HeightSlider = bodyPage:RegisterElement('arrows', {
            label = FeatherCore.Locale.translate(0, "height"),
            start = 5,
            options = Config.Heights
        }, function(data)
            if data.value == 1 then
                data.value = 1.0
            end
            SetPedScale(PlayerPedId(), data.value)
            SelectedAttributeElements['Height'] = { value = data.value }
        end)

        BodySlider = bodyPage:RegisterElement('slider', {
            label = FeatherCore.Locale.translate(0, "bodyType"),
            start = 0,
            min = 1,
            max = #BodyTypes,
            steps = 1
        }, function(data)
            local size = data.value
            SelectedAttributeElements['BodyType'] = { hash = BodyTypes[size] }
            EquipMetaPedOutfit(PlayerPedId(), BodyTypes[size])
        end)

        ChestSlider = bodyPage:RegisterElement('slider', {
            label = FeatherCore.Locale.translate(0, "chestSize"),
            start = 0,
            min = 1,
            max = #ChestType,
            steps = 1
        }, function(data)
            local size = data.value
            SelectedAttributeElements['ChestSize'] = { hash = ChestType[size] }
            EquipMetaPedOutfit(PlayerPedId(), ChestType[size])
        end)

        WaistSlider = bodyPage:RegisterElement('slider', {
            label = FeatherCore.Locale.translate(0, "waistSize"),
            start = 0,
            min = 1,
            max = #WaistTypes,
            steps = 1,
        }, function(data)
            local size = data.value
            SelectedAttributeElements['WaistSize'] = { hash = WaistTypes[size] }
            EquipMetaPedOutfit(PlayerPedId(), WaistTypes[size])
        end)

        ForearmGrid1 = bodyPage:RegisterElement('gridslider', {
            leftlabel = FeatherCore.Locale.translate(0, "foreArmSizeMinus"),
            rightlabel = FeatherCore.Locale.translate(0, "foreArmSizePlus"),
            toplabel = FeatherCore.Locale.translate(0, "upperArmSizePlus"),
            bottomlabel = FeatherCore.Locale.translate(0, "upperArmSizeMinus"),
            maxx = 1,
            maxy = 1,
            arrowsteps = 10,
            precision = 1
        }, function(data)
            SetCharExpression(PlayerPedId(), 8420, tonumber(data.value.x))
            SetCharExpression(PlayerPedId(), 46032, tonumber(data.value.y))
            SelectedAttributeElements['ForearmSize'] = { value = tonumber(data.value.x), hash = 8420 }
            SelectedAttributeElements['UpArmSize'] = { value = tonumber(data.value.y), hash = 46032 }
            UpdatePedVariation(PlayerPedId())
        end)

        LegGrid = bodyPage:RegisterElement('gridslider', {
            leftlabel = FeatherCore.Locale.translate(0, "calvesSizeMinus"),
            rightlabel = FeatherCore.Locale.translate(0, "calvesSizePlus"),
            toplabel = FeatherCore.Locale.translate(0, "thighSizePlus"),
            bottomlabel = FeatherCore.Locale.translate(0, "thighSizeMinus"),
            maxx = 1,
            maxy = 1,
            arrowsteps = 10,
            precision = 1
        }, function(data)
            SetCharExpression(PlayerPedId(), 42067, tonumber(data.value.x))
            SetCharExpression(PlayerPedId(), 64834, tonumber(data.value.y))
            SelectedAttributeElements['CalvesSize'] = { value = tonumber(data.value.x), hash = 42067 }
            SelectedAttributeElements['ThighsSize'] = { value = tonumber(data.value.y), hash = 64834 }
            UpdatePedVariation(PlayerPedId())
        end)

        WaistGrid = bodyPage:RegisterElement('gridslider', {
            leftlabel = FeatherCore.Locale.translate(0, "waistWidthMinus"),
            rightlabel = FeatherCore.Locale.translate(0, "waistWidthPlus"),
            toplabel = FeatherCore.Locale.translate(0, "hipWidthPlus"),
            bottomlabel = FeatherCore.Locale.translate(0, "hipWidthMinus"),
            maxx = 1,
            maxy = 1,
            arrowsteps = 10,
            precision = 1
        }, function(data)
            SetCharExpression(PlayerPedId(), 50460, tonumber(data.value.x))
            SetCharExpression(PlayerPedId(), 49787, tonumber(data.value.y))
            SelectedAttributeElements['WaistWidth'] = { value = tonumber(data.value.x), hash = 50460 }
            SelectedAttributeElements['HipWidth'] = { value = tonumber(data.value.y), hash = 49787 }
            UpdatePedVariation(PlayerPedId())
        end)

        bodyPage:RegisterElement('line', { 
            slot = "footer", 
            style = {} 
        })

        bodyPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "goBack"),
            slot = 'footer',
            style = {}
        }, function()
            mainAppearanceMenu:RouteTo()
            SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
                Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        end)

        bodyPage:RegisterElement('bottomline', { 
            slot = "footer", 
            style = {} 
        })
        bodyPage:RegisterElement('pagearrows', {
            slot = 'footer',
            total = FeatherCore.Locale.translate(0, "zoomCamIn"),
            current = FeatherCore.Locale.translate(0, "zoomCamOut"),
            style = {}
        }, function(data)
            if data.value == 'forward' then
                Fov = Fov - 1.0
                SetCamFov(CharacterCamera, Fov)
            else
                Fov = Fov + 1.0
                SetCamFov(CharacterCamera, Fov)
            end
        end)

        bodyPage:RegisterElement('pagearrows', {
            slot = 'footer',
            total = FeatherCore.Locale.translate(0, "moveCamUp"),
            current = FeatherCore.Locale.translate(0, "moveCamDown"),
            style = {}
        }, function(data)
            if data.value == 'forward' then
                CamZ = CamZ + 0.1
                SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
            else
                CamZ = CamZ - 0.1
                SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
            end
        end)

        bodyPage:RegisterElement('pagearrows', {
            slot = 'footer',
            total = FeatherCore.Locale.translate(0, "rotateRight"),
            current = FeatherCore.Locale.translate(0, "rotateLeft"),
            style = {}
        }, function(data)
            if data.value == 'forward' then
                SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) + 10.0)
            else
                SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) - 10.0)
            end
        end)
    end

    bodyPage:RouteTo()
end

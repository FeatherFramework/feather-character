local selectedAttributes = {}

function OpenBeardPage(mainAppearanceMenu, gender)
    local beardPage = CharacterMenu:RegisterPage('feather-character:BeardPage')

    beardPage:RegisterElement('header', { value = FeatherCore.Locale.translate(0, "hairPage"), slot = "header", style = {} })
    -- Optional beard stubble (male only)
    if gender == "Male" then
        beardPage:RegisterElement("toggle", {
            label = FeatherCore.Locale.translate(0, "beardStubble"),
            start = false
        }, function(data)
            if data.value then
                ChangeOverlay(PlayerPedId(), 'beardstabble', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, 1.0, Albedo)
            else
                ChangeOverlay(PlayerPedId(), 'beardstabble', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, 0.0, Albedo)
            end
        end)

        beardPage:RegisterElement('arrows', {
            label = FeatherCore.Locale.translate(0, "opacity"),
            start = 11,
            options = { 0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 }
        }, function(data)
            local BeardOpacity = data.value
            if BeardOpacity == 1 then BeardOpacity = 1.0 end
            ChangeOverlay(PlayerPedId(), 'beardstabble', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, BeardOpacity, Albedo)
        end)
    end

    -- Main beard list (from your HairandBeards[gender].beard structure)
    local MainComponent = 0
    local VariantComponent
    local CategoryElement
    local VariantElement

    CategoryElement = beardPage:RegisterElement('slider', {
        label = FeatherCore.Locale.translate(0, "beard"),
        start = 0, min = 0,
        max = #HairandBeards[gender].beard,
        steps = 1
    }, function(data)
        MainComponent = data.value
        if VariantComponent == nil then VariantComponent = 1 end
        if MainComponent > 0 then
            VariantElement = VariantElement:update({
                label = FeatherCore.Locale.translate(0, "beard") .. " " .. FeatherCore.Locale.translate(0, "variant"),
                max = #HairandBeards[gender].beard[MainComponent],
            })
            AddComponent(PlayerPedId(), HairandBeards[gender].beard[MainComponent][VariantComponent].hash, 'beard')
            local pedType = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
            ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8, HairandBeards[gender].beard[MainComponent][1].hash, pedType, true)
            SelectedAttributeElements['beardCategory'] = { hash = HairandBeards[gender].beard[MainComponent][1].hash }
            SelectedAttributeElements['beardVariant']  = { hash = HairandBeards[gender].beard[MainComponent][1].hash }
        else
            Citizen.InvokeNative(0xDF631E4BCE1B1FC4, PlayerPedId(), ActiveCatagory, 0, 0)
            Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0)
        end
    end)

    VariantElement = beardPage:RegisterElement('slider', {
        label = FeatherCore.Locale.translate(0, "variant"),
        start = 1, min = 1, max = 5, steps = 1
    }, function(data)
        VariantComponent = data.value
        if VariantComponent > 0 and MainComponent > 0 then
            VariantElement = VariantElement:update({
                label = FeatherCore.Locale.translate(0, "beard") .. " " .. FeatherCore.Locale.translate(0, "variant"),
                max = #HairandBeards[gender].beard[MainComponent]
            })
            AddComponent(PlayerPedId(), HairandBeards[gender].beard[MainComponent][VariantComponent].hash, 'beard')
            local pedType = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
            ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8, HairandBeards[gender].beard[MainComponent][VariantComponent].hash, pedType, true)
            SelectedAttributeElements['beardVariant'] = { hash = HairandBeards[gender].beard[MainComponent][VariantComponent].hash }
        end
    end)

    selectedAttributes['beardCategory'] = CategoryElement
    selectedAttributes['beardVariant']  = VariantElement

    beardPage:RegisterElement('line', { slot = "footer", style = {} })

    beardPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "goBack"),
        slot = 'footer',
        style = {}
    }, function()
        SwitchCam(
            Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
            Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom
        )
        OpenHairCategoryMenu(mainAppearanceMenu, gender)
    end)

    beardPage:RegisterElement('bottomline', { 
        slot = "footer", 
        style = {} 
    })

    beardPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "moveCamUp"),
        current = FeatherCore.Locale.translate(0, "moveCamDown"),
        style = {}
    }, function(data)
        if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
        SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
    end)

    beardPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "rotateRight"),
        current = FeatherCore.Locale.translate(0, "rotateLeft"),
        style = {}
    }, function(data)
        local heading = GetEntityHeading(PlayerPedId())
        if data.value == 'forward' then heading = heading + 10.0 else heading = heading - 10.0 end
        SetEntityHeading(PlayerPedId(), heading)
    end)
    beardPage:RouteTo()

end

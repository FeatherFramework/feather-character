local selectedAttributes = {}

function OpenHairPage(mainAppearanceMenu, gender)
    local hairPage = CharacterMenu:RegisterPage('feather-character:HairPage')

    hairPage:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "hairPage"),
        slot = "header",
        style = {}
    })

    local MainComponent = 0
    local VariantComponent
    local CategoryElement
    local VariantElement

    -- Main hair list (from your HairandBeards[gender].hair structure)
    CategoryElement = hairPage:RegisterElement('slider', {
        label = FeatherCore.Locale.translate(0, "hair"),
        start = 0,
        min = 0,
        max = #HairandBeards[gender].hair,
        steps = 1
    }, function(data)
        MainComponent = data.value
        if VariantComponent == nil then VariantComponent = 1 end
        if MainComponent > 0 then
            VariantElement = VariantElement:update({
                label = FeatherCore.Locale.translate(0, "hair") .. " " .. FeatherCore.Locale.translate(0, "variant"),
                max = #HairandBeards[gender].hair[MainComponent],
            })
            AddComponent(PlayerPedId(), HairandBeards[gender].hair[MainComponent][VariantComponent].hash, 'hair')
            local pedType                             = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
            ActiveCatagory                            = Citizen.InvokeNative(0x5FF9A878C3D115B8,
                HairandBeards[gender].hair[MainComponent][1].hash, pedType, true)
            SelectedAttributeElements['hairCategory'] = { hash = HairandBeards[gender].hair[MainComponent][1].hash }
            SelectedAttributeElements['hairVariant']  = { hash = HairandBeards[gender].hair[MainComponent][1].hash }
        else
            Citizen.InvokeNative(0xDF631E4BCE1B1FC4, PlayerPedId(), ActiveCatagory, 0, 0)
            Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0)
        end
    end)

    VariantElement = hairPage:RegisterElement('slider', {
        label = FeatherCore.Locale.translate(0, "variant"),
        start = 1,
        min = 1,
        max = 5,
        steps = 1
    }, function(data)
        VariantComponent = data.value
        if VariantComponent > 0 and MainComponent > 0 then
            VariantElement = VariantElement:update({
                label = FeatherCore.Locale.translate(0, "hair") .. " " .. FeatherCore.Locale.translate(0, "variant"),
                max = #HairandBeards[gender].hair[MainComponent]
            })
            AddComponent(PlayerPedId(), HairandBeards[gender].hair[MainComponent][VariantComponent].hash, 'hair')
            local pedType = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
            ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8,
                HairandBeards[gender].hair[MainComponent][VariantComponent].hash, pedType, true)
            SelectedAttributeElements['hairVariant'] = {
                hash = HairandBeards[gender].hair[MainComponent]
                    [VariantComponent].hash
            }
        end
    end)

    -- Female hair accessories (your exact logic)
    if gender == "Female" then
        local hairacc                             = 'Hair Accessories'
        local HairPiece
        local MainHairComponent
        local HA_CategoryElement                  = hairPage:RegisterElement('slider', {
            label = FeatherCore.Locale.translate(0, "hairAccessories"),
            start = 0,
            min = 0,
            max = #CharacterConfig.Clothing.Clothes[gender].Accessories.HairAccesories.CategoryData,
            steps = 1
        }, function(data)
            HairPiece = CharacterConfig.Clothing.Clothes[gender].Accessories.HairAccesories.CategoryData
            MainHairComponent = data.value
            if VariantComponent == nil then VariantComponent = 1 end
            if MainHairComponent > 0 then
                VariantElement = VariantElement:update({
                    label = hairacc .. " " .. FeatherCore.Locale.translate(0, "variant"),
                    max = #CharacterConfig.Clothing.Clothes[gender].Accessories.HairAccesories.CategoryData
                        [MainHairComponent],
                })
                AddComponent(PlayerPedId(), HairPiece[MainHairComponent][VariantComponent].hash, hairacc)
                SelectedAttributeElements[hairacc] = CharacterConfig.Clothing.Clothes[gender].Accessories.HairAccesories
                    .CategoryData[MainHairComponent][1].hash
                local pedType = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8, HairPiece[MainHairComponent][1].hash, pedType,
                    true)
            else
                Citizen.InvokeNative(0xDF631E4BCE1B1FC4, PlayerPedId(), ActiveCatagory, 0, 0)
                Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0)
            end
        end)

        local HA_VariantElement                   = hairPage:RegisterElement('slider', {
            label = FeatherCore.Locale.translate(0, "hairAccessoriesVariants"),
            start = 1,
            min = 1,
            max = 10,
            steps = 1
        }, function(data)
            HairPiece = CharacterConfig.Clothing.Clothes[gender].Accessories.HairAccesories.CategoryData
                [MainHairComponent]
            AddComponent(PlayerPedId(), HairPiece[data.value].hash, nil)
        end)

        selectedAttributes[hairacc .. 'Category'] = HA_CategoryElement
        selectedAttributes[hairacc .. 'Variant']  = HA_VariantElement
    end

    selectedAttributes['hairCategory'] = CategoryElement
    selectedAttributes['hairVariant']  = VariantElement

    hairPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    hairPage:RegisterElement('button', {
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

    hairPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    hairPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "moveCamUp"),
        current = FeatherCore.Locale.translate(0, "moveCamDown"),
        style = {}
    }, function(data)
        if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
        SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
    end)

    hairPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "rotateRight"),
        current = FeatherCore.Locale.translate(0, "rotateLeft"),
        style = {}
    }, function(data)
        local heading = GetEntityHeading(PlayerPedId())
        if data.value == 'forward' then heading = heading + 10.0 else heading = heading - 10.0 end
        SetEntityHeading(PlayerPedId(), heading)
    end)

    hairPage:RouteTo()
end

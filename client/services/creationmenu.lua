local firstName, lastName, gender, selectedClothing, selectedClothingElements, charDesc, selectedAttributes, textureId, tx_color_type = '', '', GetGender(), {}, {}, "", {}, -1, 0
ActiveTexture, ActiveColor1, ActiveColor2, ActiveColor3, ActiveOpacity, ActiveVariant, CamZ, SelectedOverlayElements = {}, {}, {}, {}, {},{}, Config.CameraCoords.creation.z + 0.5, {}
Fov = 20.0
Model = 'mp_male'
local selectedColoring, dob, imgLink

RegisterNetEvent('feather-character:CreateCharacterMenu', function()
    PageOpened = true
    local mainCreationPage = MyMenu:RegisterPage('feather-character:MainCreationPage')
    mainCreationPage:RegisterElement('header', {
        value = 'Character Creation',
        slot = "header",
        style = {}
    })
    mainCreationPage:RegisterElement('button', {
        label = "Customize Character",
        style = {}
    }, function()
        local categoriesPage = MyMenu:RegisterPage('feather-character:CustomizationPage')
        categoriesPage:RegisterElement('button', {
            label = 'Appearance',
            style = {}
        }, function()
            local mainAppearanceMenu = MyMenu:RegisterPage('feather-character:MainAppearanceMenu')
            mainAppearanceMenu:RegisterElement('header', {
                value = 'Appearance Menu',
                slot = "header",
                style = {}
            })
            mainAppearanceMenu:RegisterElement('subheader', {
                value = "First Page",
                slot = "header",
                style = {}
            })
            mainAppearanceMenu:RegisterElement('bottomline', {
                slot = "content"
            })
            local heritageDisplay, headVariantSlider, bodyVariantSlider, legVariantSlider = nil, nil, nil, nil
            local heritageSlider = mainAppearanceMenu:RegisterElement('slider', {
                label = "Heritage",
                start = 1,
                min = 1,
                max = #CharacterConfig.General.DefaultChar[gender],
                steps = 1
            }, function(data)
                Race = data.value
                local head = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Heads[1])
                local body = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Body[1])
                local legs = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Legs[1])
                local albedo = tonumber(CharacterConfig.General.DefaultChar[gender][Race].HeadTexture[1])
                SelectedAttributeElements['Albedo'] = { hash = albedo }
                AddComponent(PlayerPedId(), head, nil)
                AddComponent(PlayerPedId(), body, nil)
                AddComponent(PlayerPedId(), legs, nil)
                if heritageDisplay then
                    heritageDisplay:update({
                        value = CharacterConfig.General.DefaultChar[gender][Race].label,
                    })
                end
                if headVariantSlider then
                    headVariantSlider = headVariantSlider:update({
                        value = 1,
                    })
                end
                if bodyVariantSlider then
                    bodyVariantSlider = bodyVariantSlider:update({
                        value = 1,
                    })
                end
                if legVariantSlider then
                    legVariantSlider = legVariantSlider:update({
                        value = 1,
                    })
                end
            end)
            heritageDisplay = mainAppearanceMenu:RegisterElement('textdisplay', {
                value = "European",
                style = {}
            })
            headVariantSlider = mainAppearanceMenu:RegisterElement('slider', {
                label = "Head Variations",
                start = 1,
                min = 1,
                max = #CharacterConfig.General.DefaultChar[gender][1].Heads,
                steps = 1,
            }, function(data)
                local value = data.value
                local Head
                if Race == nil then
                    Head = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][1].Heads[value])
                else
                    Head = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Heads[value])
                end
                AddComponent(PlayerPedId(), Head, nil)
                SelectedAttributeElements['Head'] = { hash = Head }
            end)
            bodyVariantSlider = mainAppearanceMenu:RegisterElement('slider', {
                label = "Body Variations",
                start = 1,
                min = 1,
                max = #CharacterConfig.General.DefaultChar[gender][1].Body,
                steps = 1,
            }, function(data)
                local value = data.value
                local Body
                if Race == nil then
                    Body = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][1].Body[value])
                else
                    Body = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Body[value])
                end
                AddComponent(PlayerPedId(), Body, nil)
                SelectedAttributeElements['Body'] = { hash = Body }
            end)
            legVariantSlider = mainAppearanceMenu:RegisterElement('slider', {
                label = "Leg Variations",
                start = 1,
                min = 1,
                max = #CharacterConfig.General.DefaultChar[gender][1].Legs,
                steps = 1
            }, function(data)
                local value = data.value
                local Legs
                if Race == nil then
                    Legs = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][1].Legs[value])
                else
                    Legs = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Legs[value])
                end
                AddComponent(PlayerPedId(), Legs, nil)
                SelectedAttributeElements['Legs'] = { hash = Legs }
            end)
            mainAppearanceMenu:RegisterElement('bottomline', {
                slot = "footer",
                style = {}
            })
            mainAppearanceMenu:RegisterElement('button', {
                label = "Go Back",
                slot = 'footer',
                style = {}
            }, function()
                SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                mainCreationPage:RouteTo()
            end)
            mainAppearanceMenu:RegisterElement('button', {
                label = 'Hair',
                style = {}
            }, function()
                local hairCategoryPage = MyMenu:RegisterPage('feather-character:HairCategoryPage')
                SwitchCam(Config.CameraCoords.creation.x - 0.25, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z + 0.7, Config.CameraCoords.creation.h, 0.0)
                hairCategoryPage:RegisterElement('header', {
                    value = 'My First Menu',
                    slot = "header",
                    style = {}
                })
                hairCategoryPage:RegisterElement('subheader', {
                    value = "First Page",
                    slot = "header",
                    style = {}
                })
                hairCategoryPage:RegisterElement('bottomline', {
                    slot = "footer",
                    style = {}
                })
                hairCategoryPage:RegisterElement('button', {
                    label = "Go Back",
                    slot = 'footer',
                    style = {}
                }, function()
                    SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                    mainAppearanceMenu:RouteTo()
                end)
                for key, v in pairs(HairandBeards[gender]) do
                    hairCategoryPage:RegisterElement('button', {
                        label = key,
                        style = {}
                    }, function()
                        local hairAndBeardPage = MyMenu:RegisterPage('feather-character:HairandBeardPage')
                        hairAndBeardPage:RegisterElement('header', {
                            value = 'My First Menu',
                            slot = "header",
                            style = {}
                        })
                        hairAndBeardPage:RegisterElement('subheader', {
                            value = "First Page",
                            slot = "header",
                            style = {}
                        })
                        hairAndBeardPage:RegisterElement('bottomline', {
                            slot = "footer",
                            style = {}
                        })
                        hairAndBeardPage:RegisterElement('button', {
                            label = "Go Back",
                            slot = 'footer',
                            style = {}
                        }, function()
                            SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y,Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                            mainAppearanceMenu:RouteTo()
                        end)
                        hairAndBeardPage:RegisterElement('pagearrows', {
                            slot = 'footer',
                            total = ' Move Cam Up',
                            current = 'Move Cam Down ',
                            style = {},
                        }, function(data)
                            if data.value == 'forward' then
                                CamZ = CamZ + 0.1
                                SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
                            else
                                CamZ = CamZ - 0.1
                                SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
                            end
                        end)
                        hairAndBeardPage:RegisterElement('pagearrows', {
                            slot = 'footer',
                            total = ' Rotate Right ',
                            current = 'Rotate Left ',
                            style = {},
                        }, function(data)
                            if data.value == 'forward' then
                                local heading = GetEntityHeading(PlayerPedId())
                                SetEntityHeading(PlayerPedId(), heading + 10.0)
                            else
                                local heading = GetEntityHeading(PlayerPedId())
                                SetEntityHeading(PlayerPedId(), heading - 10.0)
                            end
                        end)
                        if key == 'beard' then
                            if gender == "Male" then
                                hairAndBeardPage:RegisterElement("toggle", {
                                    label = "Beard Stuble",
                                    start = false
                                }, function(data)
                                    if data.value == true then
                                        ChangeOverlay(PlayerPedId(),'beardstabble', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, 1.0, Albedo)
                                    else
                                        ChangeOverlay(PlayerPedId(),'beardstabble', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, 0.0, Albedo)
                                    end
                                end)
                                hairAndBeardPage:RegisterElement('arrows', {
                                    label = "Opacity",
                                    start = 11,
                                    options = {
                                        0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0
                                    }
                                }, function(data)
                                    BeardOpacity = data.value
                                    if BeardOpacity == 1 then
                                        BeardOpacity = 1.0
                                    end
                                    ChangeOverlay(PlayerPedId(),'beardstabble', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, BeardOpacity, Albedo)
                                end)
                            end
                        end
                        if key == 'hair' then
                            hairacc = 'Hair Accessories'
                            if gender == "Female" then
                                CategoryElement = hairAndBeardPage:RegisterElement('slider', {
                                    label = "Hair Accessories",
                                    start = 0,
                                    min = 0,
                                    max = #CharacterConfig.Clothing.Clothes[gender].Accessories.HairAccesories.CategoryData,
                                    steps = 1,
                                }, function(data)
                                    HairPiece = CharacterConfig.Clothing.Clothes[gender].Accessories.HairAccesories.CategoryData
                                    MainHairComponent = data.value
                                    if VariantComponent == nil then
                                        VariantComponent = 1
                                    end
                                    if MainHairComponent > 0 then
                                        selectedAttributes[hairacc .. 'Variant'] = selectedAttributes[hairacc .. 'Variant']:update({
                                            label = hairacc .. ' variant',
                                            max = #CharacterConfig.Clothing.Clothes[gender].Accessories.HairAccesories.CategoryData[MainHairComponent], --#v.CategoryData[inputvalue],
                                        })
                                        AddComponent(PlayerPedId(), HairPiece[MainHairComponent][VariantComponent].hash, hairacc)
                                        SelectedAttributeElements[hairacc] = CharacterConfig.Clothing.Clothes[gender].Accessories.HairAccesories.CategoryData[MainHairComponent][1].hash
                                        local type = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                                        ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8, HairPiece[MainHairComponent][1].hash, type, true)
                                        VariantElement = VariantElement:update({
                                            label = hairacc .. ' variant',
                                            max = #HairPiece[MainHairComponent]
                                        })
                                    else
                                        Citizen.InvokeNative(0xDF631E4BCE1B1FC4, PlayerPedId(), ActiveCatagory, 0, 0)
                                        Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
                                    end
                                end)
                                VariantElement = hairAndBeardPage:RegisterElement('slider', {
                                    label = "Hair Accessories Variants",
                                    start = 1,
                                    min = 1,
                                    max = 10,
                                    steps = 1
                                }, function(data)
                                    HairPiece = CharacterConfig.Clothing.Clothes[gender].Accessories.HairAccesories.CategoryData[MainHairComponent]
                                    AddComponent(PlayerPedId(), HairPiece[data.value].hash, nil)
                                end)
                                selectedAttributes[hairacc .. 'Category'] = CategoryElement
                                selectedAttributes[hairacc .. 'Variant'] = VariantElement
                            end
                        end
                        MainComponent = 0
                        table.insert(selectedAttributes, key)
                        CategoryElement = hairAndBeardPage:RegisterElement('slider', {
                            label = v,
                            start = 0,
                            min = 0,
                            max = #HairandBeards[gender][key],
                            steps = 1
                        }, function(data)
                            MainComponent = data.value
                            if VariantComponent == nil then
                                VariantComponent = 1
                            end
                            if MainComponent > 0 then
                                selectedAttributes[key .. 'Variant'] = selectedAttributes[key .. 'Variant']:update({
                                    label = key .. ' variant',
                                    max = #HairandBeards[gender][key][MainComponent], --#v.CategoryData[inputvalue],
                                })
                                AddComponent(PlayerPedId(), HairandBeards[gender][key][MainComponent][VariantComponent].hash, key)
                                local type = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                                ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8, HairandBeards[gender][key][MainComponent][1].hash, type, true)
                                SelectedAttributeElements[key .. 'Category'] = {hash = HairandBeards[gender][key][MainComponent][1].hash}
                                SelectedAttributeElements[key .. 'Variant'] = {hash = HairandBeards[gender][key][MainComponent][1].hash}
                                TextElement = TextElement:update({
                                    value = HairandBeards[gender][key][MainComponent][VariantComponent].color
                                })
                            else
                                Citizen.InvokeNative(0xDF631E4BCE1B1FC4, PlayerPedId(), ActiveCatagory, 0, 0)
                                Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
                            end
                        end)
                        VariantElement = hairAndBeardPage:RegisterElement('slider', {
                            label = key .. ' variant',
                            start = 1,
                            min = 1,
                            max = 5, --#v.CategoryData[inputvalue],
                            steps = 1
                        }, function(data)
                            VariantComponent = data.value
                            if VariantComponent > 0 and MainComponent > 0 then
                                selectedAttributes[key .. 'Variant'] = selectedAttributes[key .. 'Variant']:update({
                                    label = key .. ' variant',
                                    max = #HairandBeards[gender][key][MainComponent], --#v.CategoryData[inputvalue],
                                })
                                AddComponent(PlayerPedId(), HairandBeards[gender][key][MainComponent][VariantComponent].hash, key)
                                local type = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                                ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8, HairandBeards[gender][key][MainComponent][VariantComponent].hash, type, true)
                                SelectedAttributeElements[key .. 'Variant'] = {hash = HairandBeards[gender][key][MainComponent][VariantComponent].hash}
                                TextElement = TextElement:update({
                                    value = HairandBeards[gender][key][MainComponent][VariantComponent].color
                                })
                            end
                        end)
                        selectedAttributes[key .. 'Category'] = CategoryElement
                        selectedAttributes[key .. 'Variant'] = VariantElement
                        CategoryElement = CategoryElement:update({
                            label = key,
                            max = #HairandBeards[gender][key], --#v.CategoryData[inputvalue],
                        })
                        VariantElement = VariantElement:update({
                            label = key .. ' variant',
                            max = #HairandBeards[gender][key], --#v.CategoryData[inputvalue],
                        })
                        TextElement = hairAndBeardPage:RegisterElement('textdisplay', {
                            value = 'test',
                            style = {}
                        })
                        hairAndBeardPage:RouteTo()
                    end)
                end
                hairCategoryPage:RouteTo()
            end)
            mainAppearanceMenu:RegisterElement('button', {
                label = 'Facial Adjustments',
                style = {}
            }, function()
                local faceAdjMenu = MyMenu:RegisterPage('feather-character:FaceAdjMenu')
                faceAdjMenu:RegisterElement('header', {
                    value = 'Facial Features',
                    slot = "header",
                    style = {}
                })
                faceAdjMenu:RegisterElement('subheader', {
                    value = "First Page",
                    slot = "header",
                    style = {}
                })
                for key, v in pairs(FaceFeatures.Adjustments) do
                    FaceButton = faceAdjMenu:RegisterElement('button', {
                        label = key,
                        style = {}
                    }, function()
                        if key == 'Eyes and Brows' then
                            local eyesPage = MyMenu:RegisterPage('feather-character:EyesPage')
                            eyesPage:RegisterElement('header', {
                                value = 'My First Menu',
                                slot = "header",
                                style = {}
                            })
                            eyesPage:RegisterElement('subheader', {
                                value = "First Page",
                                slot = "header",
                                style = {}
                            })
                            eyesPage:RegisterElement('bottomline', {
                                slot = "footer",
                                style = {}
                            })
                            eyesPage:RegisterElement('button', {
                                label = "Go Back",
                                slot = 'footer',
                                style = {}
                            }, function()
                                StopAnimTask(PlayerPedId(), 'FACE_HUMAN@GEN_MALE@BASE', 'mood_normal_eyes_wide', true)
                                mainAppearanceMenu:RouteTo()
                            end)
                            eyesPage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Move Cam Up',
                                current = 'Move Cam Down ',
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
                            eyesPage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Rotate Right ',
                                current = 'Rotate Left ',
                                style = {}
                            }, function(data)
                                if data.value == 'forward' then
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading + 10.0)
                                else
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading - 10.0)
                                end
                            end)
                            eyesPage:RegisterElement('button', {
                                label = "Eye Height and Depth",
                                style = {}
                            }, function()
                                EyeGrid = eyesPage:RegisterElement('gridslider', {
                                    leftlabel = 'Eye Depth -',
                                    rightlabel = 'Eye Depth +',
                                    toplabel = 'Eye Height +',
                                    bottomlabel = 'Eye Height -',
                                    maxx = 1,
                                    maxy = 1,
                                    arrowsteps = 10,
                                    precision = 1
                                }, function(data)
                                    SetCharExpression(PlayerPedId(), 60996, tonumber(data.value.x))
                                    SetCharExpression(PlayerPedId(), 56827, tonumber(data.value.y))
                                    SelectedAttributeElements['EyeDepth'] = { value = tonumber(data.value.x), hash = 60996 }
                                    SelectedAttributeElements['EyeHeight'] = { value = tonumber(data.value.y), hash = 56827 }
                                    UpdatePedVariation(PlayerPedId())
                                end)
                                eyesPage:RouteTo()
                            end)
                            eyesPage:RegisterElement('button', {
                                label = "Eye Distance and Angle",
                                style = {}
                            }, function()
                                EyeGrid2 = eyesPage:RegisterElement('gridslider', {
                                    leftlabel = 'Eye Distance -',
                                    rightlabel = 'Eye Distance +',
                                    toplabel = 'Eye Angle +',
                                    bottomlabel = 'Eye Angle -',
                                    maxx = 1,
                                    maxy = 1,
                                    arrowsteps = 10,
                                    precision = 1
                                }, function(data)
                                    SetCharExpression(PlayerPedId(), 42318, tonumber(data.value.x))
                                    SetCharExpression(PlayerPedId(), 53862, tonumber(data.value.y))
                                    SelectedAttributeElements['EyeDistance'] = { value = tonumber(data.value.x), hash = 42318 }
                                    SelectedAttributeElements['EyeAngle'] = { value = tonumber(data.value.y), hash = 53862 }
                                    UpdatePedVariation(PlayerPedId())
                                end)
                                eyesPage:RouteTo()
                            end)
                            eyesPage:RegisterElement('button', {
                                label = "Eyelid Width and Height",
                                style = {}
                            }, function()
                                EyeGrid3 = eyesPage:RegisterElement('gridslider', {
                                    leftlabel = 'Eyelid Width -',
                                    rightlabel = 'Eyelid Width +',
                                    toplabel = 'Eyelid Height +',
                                    bottomlabel = 'Eyelid Height -',
                                    maxx = 1,
                                    maxy = 1,
                                    arrowsteps = 10,
                                    precision = 1
                                }, function(data)
                                    SetCharExpression(PlayerPedId(), 7019, tonumber(data.value.x))
                                    SetCharExpression(PlayerPedId(), 35627, tonumber(data.value.y))
                                    SelectedAttributeElements['EyelidWidth'] = { value = tonumber(data.value.x), hash = 7019 }
                                    SelectedAttributeElements['EyelidHeight'] = { value = tonumber(data.value.y), hash = 35627 }
                                    UpdatePedVariation(PlayerPedId())
                                end)
                                eyesPage:RouteTo()
                            end)
                            eyesPage:RegisterElement('button', {
                                label = "Eyebrows",
                                style = {}
                            }, function()
                                local eyebrowPage = MyMenu:RegisterPage('feather-character:EyebrowPage')
                                EyebrowOpacity = 1.0
                                eyebrowPage:RegisterElement('header', {
                                    value = 'My First Menu',
                                    slot = "header",
                                    style = {}
                                })
                                eyebrowPage:RegisterElement('subheader', {
                                    value = "First Page",
                                    slot = "header",
                                    style = {}
                                })
                                eyebrowPage:RegisterElement('bottomline', {
                                    slot = "footer",
                                    style = {}
                                })
                                eyebrowPage:RegisterElement('button', {
                                    label = "Go Back",
                                    slot = 'footer',
                                    style = {}
                                }, function()
                                    StopAnimTask(PlayerPedId(), 'FACE_HUMAN@GEN_MALE@BASE', 'mood_normal_eyes_wide', true)
                                    eyesPage:RouteTo()
                                end)
                                eyebrowPage:RegisterElement('pagearrows', {
                                    slot = 'footer',
                                    total = ' Move Cam Up',
                                    current = 'Move Cam Down ',
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
                                eyebrowPage:RegisterElement('pagearrows', {
                                    slot = 'footer',
                                    total = ' Rotate Right ',
                                    current = 'Rotate Left ',
                                    style = {}
                                }, function(data)
                                    if data.value == 'forward' then
                                        local heading = GetEntityHeading(PlayerPedId())
                                        SetEntityHeading(PlayerPedId(), heading + 10.0)
                                    else
                                        local heading = GetEntityHeading(PlayerPedId())
                                        SetEntityHeading(PlayerPedId(), heading - 10.0)
                                    end
                                end)
                                eyebrowPage:RegisterElement('arrows', {
                                    label = "Opacity",
                                    start = 11,
                                    options = {
                                        0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0
                                    }
                                }, function(data)
                                    EyebrowOpacity = data.value
                                    if EyebrowOpacity == 1 then
                                        EyebrowOpacity = 1.0
                                    end
                                    ChangeOverlay(PlayerPedId(),'eyebrows', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, EyebrowOpacity, Albedo)
                                    SelectedAttributeElements['BrowOpacity'] = { value = data.value }
                                end)
                                eyebrowPage:RegisterElement('slider', {
                                    label = "Variant",
                                    start = 1,
                                    min = 0,
                                    max = #overlays_info['eyebrows'],
                                    steps = 1
                                }, function(data)
                                    ChangeOverlay(PlayerPedId(),'eyebrows', 1, data.value, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, EyebrowOpacity, Albedo)
                                    SelectedAttributeElements['EyebrowVariant'] = { value = data.value }
                                end)
                                EyebrowGrid = eyebrowPage:RegisterElement('gridslider', {
                                    leftlabel = 'Eyebrow Width -',
                                    rightlabel = 'Eyebrow Width +',
                                    toplabel = 'Eyebrow Height +',
                                    bottomlabel = 'Eyebrow Height -',
                                    maxx = 1,
                                    maxy = 1,
                                    arrowsteps = 10,
                                    precision = 1
                                }, function(data)
                                    SetCharExpression(PlayerPedId(), 0x2FF9, tonumber(data.value.x))
                                    SetCharExpression(PlayerPedId(), 0x3303, tonumber(data.value.y))
                                    SelectedAttributeElements['EyebrowWidth'] = { value = tonumber(data.value.x), hash = 0x2FF9 }
                                    SelectedAttributeElements['EyebrowHeight'] = { value = tonumber(data.value.y), hash = 0x3303 }
                                    UpdatePedVariation(PlayerPedId())
                                end)
                                eyebrowPage:RouteTo()
                            end)
                            eyesPage:RegisterElement('slider', {
                                label = "Eye Color",
                                start = 0,
                                min = 1,
                                max = #FeaturesEyes[gender],
                                steps = 1
                            }, function(data)
                                AddComponent(PlayerPedId(), FeaturesEyes[gender][data.value], nil)
                                SelectedAttributeElements['EyeColor'] = { hash = FeaturesEyes[gender][data.value] }
                            end)
                            EyesAnim("mood_normal_eyes_wide")
                            eyesPage:RouteTo()
                        end
                        if key == 'Cheeks' then
                            local cheekPage = MyMenu:RegisterPage('feather-character:CheekPage')
                            cheekPage:RegisterElement('header', {
                                value = 'My First Menu',
                                slot = "header",
                                style = {}
                            })
                            cheekPage:RegisterElement('subheader', {
                                value = "First Page",
                                slot = "header",
                                style = {}
                            })
                            cheekPage:RegisterElement('bottomline', {
                                slot = "footer",
                                style = {}
                            })
                            cheekPage:RegisterElement('button', {
                                label = "Go Back",
                                slot = 'footer',
                                style = {}
                            }, function()
                                SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                                mainAppearanceMenu:RouteTo()
                            end)
                            cheekPage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Move Cam Up',
                                current = 'Move Cam Down ',
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
                            cheekPage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Rotate Right ',
                                current = 'Rotate Left ',
                                style = {}
                            }, function(data)
                                if data.value == 'forward' then
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading + 10.0)
                                else
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading - 10.0)
                                end
                            end)
                            CheekGrid1 = cheekPage:RegisterElement('gridslider', {
                                leftlabel = 'Cheekbone Width -',
                                rightlabel = 'Cheekbone Width +',
                                toplabel = 'Cheekbone Height +',
                                bottomlabel = 'Cheekbone Height -',
                                maxx = 1,
                                maxy = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0xABCF, tonumber(data.value.x))
                                SetCharExpression(PlayerPedId(), 0x6A0B, tonumber(data.value.y))
                                SelectedAttributeElements['CheekboneWidth'] = { value = tonumber(data.value.x), hash = 0xABCF }
                                SelectedAttributeElements['CheekboneHeight'] = { value = tonumber(data.value.y), hash = 0x6A0B }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            CheekGrid2 = cheekPage:RegisterElement('gridslider', {
                                leftlabel = 'Cheekbone Depth -',
                                rightlabel = 'Cheekbone Depth +',
                                maxx = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0x358D, tonumber(data.value.x))
                                SelectedAttributeElements['CheekboneDepth'] = { value = tonumber(data.value.x), hash = 0x358D }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            cheekPage:RouteTo()
                        end
                        if key == 'Chin' then
                            local chinPage = MyMenu:RegisterPage('feather-character:ChinPage')
                            chinPage:RegisterElement('header', {
                                value = 'My First Menu',
                                slot = "header",
                                style = {}
                            })
                            chinPage:RegisterElement('subheader', {
                                value = "First Page",
                                slot = "header",
                                style = {}
                            })
                            chinPage:RegisterElement('bottomline', {
                                slot = "footer",
                                style = {}
                            })
                            chinPage:RegisterElement('button', {
                                label = "Go Back",
                                slot = 'footer',
                                style = {}
                            }, function()
                                SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                                mainAppearanceMenu:RouteTo()
                            end)
                            chinPage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Move Cam Up',
                                current = 'Move Cam Down ',
                                style = {},
                            }, function(data)
                                if data.value == 'forward' then
                                    CamZ = CamZ + 0.1
                                    SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
                                else
                                    CamZ = CamZ - 0.1
                                    SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
                                end
                            end)
                            chinPage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Rotate Right ',
                                current = 'Rotate Left ',
                                style = {},
                            }, function(data)
                                if data.value == 'forward' then
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading + 10.0)
                                else
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading - 10.0)
                                end
                            end)
                            ChinGrid1 = chinPage:RegisterElement('gridslider', {
                                leftlabel = 'Chin Width -',
                                rightlabel = 'Chin Width +',
                                toplabel = 'Chin Height +',
                                bottomlabel = 'Chin Height -',
                                maxx = 1,
                                maxy = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0xC3B2, tonumber(data.value.x))
                                SetCharExpression(PlayerPedId(), 0x3C0F, tonumber(data.value.y))
                                SelectedAttributeElements['ChinWidth'] = { value = tonumber(data.value.x), hash = 0xC3B2 }
                                SelectedAttributeElements['ChinHeight'] = { value = tonumber(data.value.y), hash = 0x3C0F }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            ChinGrid2 = chinPage:RegisterElement('gridslider', {
                                leftlabel = 'Chin Depth -',
                                rightlabel = 'Chin Depth +',
                                maxx = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0xE323, tonumber(data.value.x))
                                SelectedAttributeElements['ChinDepth'] = { value = tonumber(data.value.x), hash = 0xE323 }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            chinPage:RouteTo()
                        end
                        if key == 'Ears' then
                            local earPage = MyMenu:RegisterPage('feather-character:EarPage')
                            earPage:RegisterElement('header', {
                                value = 'My First Menu',
                                slot = "header",
                                style = {}
                            })
                            earPage:RegisterElement('subheader', {
                                value = "First Page",
                                slot = "header",
                                style = {}
                            })
                            earPage:RegisterElement('bottomline', {
                                slot = "footer",
                                style = {}
                            })
                            earPage:RegisterElement('button', {
                                label = "Go Back",
                                slot = 'footer',
                                style = {}
                            }, function()
                                SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                                mainAppearanceMenu:RouteTo()
                            end)
                            earPage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Move Cam Up',
                                current = 'Move Cam Down ',
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
                            earPage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Rotate Right ',
                                current = 'Rotate Left ',
                                style = {}
                            }, function(data)
                                if data.value == 'forward' then
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading + 10.0)
                                else
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading - 10.0)
                                end
                            end)
                            EarGrid1 = earPage:RegisterElement('gridslider', {
                                leftlabel = 'Ear Width -',
                                rightlabel = 'Ear Width +',
                                toplabel = 'Ear Height +',
                                bottomlabel = 'Ear Height -',
                                maxx = 1,
                                maxy = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0xC04F, tonumber(data.value.x))
                                SetCharExpression(PlayerPedId(), 0x2844, tonumber(data.value.y))
                                SelectedAttributeElements['EarWidth'] = { value = tonumber(data.value.x), hash = 0xC04F }
                                SelectedAttributeElements['EarHeight'] = { value = tonumber(data.value.y), hash = 0x2844 }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            EarGrid2 = earPage:RegisterElement('gridslider', {
                                leftlabel = 'Earlobe Size -',
                                rightlabel = 'Earlobe Size +',
                                toplabel = 'Ear Angle +',
                                bottomlabel = 'Ear Angle -',
                                maxx = 1,
                                maxy = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0xED30, tonumber(data.value.x))
                                SetCharExpression(PlayerPedId(), 0xB6CE, tonumber(data.value.y))
                                SelectedAttributeElements['EarSize'] = { value = tonumber(data.value.x), hash = 0xED30 }
                                SelectedAttributeElements['EarAngle'] = { value = tonumber(data.value.y), hash = 0xB6CE }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            earPage:RouteTo()
                        end
                        if key == 'Jaw' then
                            local jawPage = MyMenu:RegisterPage('feather-character:JawPage')
                            jawPage:RegisterElement('header', {
                                value = 'My First Menu',
                                slot = "header",
                                style = {}
                            })
                            jawPage:RegisterElement('subheader', {
                                value = "First Page",
                                slot = "header",
                                style = {}
                            })
                            jawPage:RegisterElement('bottomline', {
                                slot = "footer",
                                style = {}
                            })
                            jawPage:RegisterElement('button', {
                                label = "Go Back",
                                slot = 'footer',
                                style = {}
                            }, function()
                                SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                                mainAppearanceMenu:RouteTo()
                            end)
                            jawPage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Move Cam Up',
                                current = 'Move Cam Down ',
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
                            jawPage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Rotate Right ',
                                current = 'Rotate Left ',
                                style = {}
                            }, function(data)
                                if data.value == 'forward' then
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading + 10.0)
                                else
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading - 10.0)
                                end
                            end)
                            JawGrid1 = jawPage:RegisterElement('gridslider', {
                                leftlabel = 'Jaw Width -',
                                rightlabel = 'Jaw Width +',
                                toplabel = 'Jaw Height +',
                                bottomlabel = 'Jaw Height -',
                                maxx = 1,
                                maxy = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0xEBAE, tonumber(data.value.x))
                                SetCharExpression(PlayerPedId(), 0x8D0A, tonumber(data.value.y))
                                SelectedAttributeElements['JawWidth'] = { value = tonumber(data.value.x), hash = 0xEBAE }
                                SelectedAttributeElements['JawHeight'] = { value = tonumber(data.value.y), hash = 0x8D0A }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            JawGrid2 = jawPage:RegisterElement('gridslider', {
                                leftlabel = 'Jaw Depth -',
                                rightlabel = 'Jaw Depth +',
                                maxx = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0x1DF6, tonumber(data.value.x))
                                SelectedAttributeElements['JawDepth'] = { value = tonumber(data.value.x), hash = 0x1DF6 }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            jawPage:RouteTo()
                        end
                        if key == 'Mouth' then
                            local mouthPage = MyMenu:RegisterPage('feather-character:MouthPage')
                            mouthPage:RegisterElement('header', {
                                value = 'My First Menu',
                                slot = "header",
                                style = {}
                            })
                            mouthPage:RegisterElement('subheader', {
                                value = "First Page",
                                slot = "header",
                                style = {}
                            })
                            mouthPage:RegisterElement('bottomline', {
                                slot = "footer",
                                style = {}
                            })
                            mouthPage:RegisterElement('button', {
                                label = "Go Back",
                                slot = 'footer',
                                style = {}
                            }, function()
                                SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                                mainAppearanceMenu:RouteTo()
                            end)
                            mouthPage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Move Cam Up',
                                current = 'Move Cam Down ',
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
                            mouthPage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Rotate Right ',
                                current = 'Rotate Left ',
                                style = {}
                            }, function(data)
                                if data.value == 'forward' then
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading + 10.0)
                                else
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading - 10.0)
                                end
                            end)
                            UpperLipGrid = mouthPage:RegisterElement('gridslider', {
                                leftlabel = 'Upper Lip Width -',
                                rightlabel = 'Upper Lip Width +',
                                toplabel = 'Upper Lip Height +',
                                bottomlabel = 'Upper Lip Height -',
                                maxx = 1,
                                maxy = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0x91C1, tonumber(data.value.x))
                                SetCharExpression(PlayerPedId(), 0x1A00, tonumber(data.value.y))
                                SelectedAttributeElements['UpLipWidth'] = { value = tonumber(data.value.x), hash = 0x91C1 }
                                SelectedAttributeElements['UpLipHeight'] = { value = tonumber(data.value.y), hash = 0x1A00 }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            UpperLipGrid2 = mouthPage:RegisterElement('gridslider', {
                                leftlabel = 'Upper Lip Depth -',
                                rightlabel = 'Upper Lip Depth +',
                                maxx = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0xC375, tonumber(data.value.x))
                                SelectedAttributeElements['UpLipDepth'] = { value = tonumber(data.value.x), hash = 0xC375 }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            LowerLipGrid = mouthPage:RegisterElement('gridslider', {
                                leftlabel = 'Lower Lip Width -',
                                rightlabel = 'Lower Lip Width +',
                                toplabel = 'Lower Lip Height +',
                                bottomlabel = 'Lower Lip Height -',
                                maxx = 1,
                                maxy = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0xB0B0, tonumber(data.value.x))
                                SetCharExpression(PlayerPedId(), 0xBB4D, tonumber(data.value.y))
                                SelectedAttributeElements['LowLipWidth'] = { value = tonumber(data.value.x), hash = 0xB0B0 }
                                SelectedAttributeElements['LowLipHeight'] = { value = tonumber(data.value.y), hash = 0xBB4D }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            LowerLipGrid2 = mouthPage:RegisterElement('gridslider', {
                                leftlabel = 'Lower Lip Depth -',
                                rightlabel = 'Lower Lip Depth +',
                                maxx = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0x5D16, tonumber(data.value.x))
                                SelectedAttributeElements['LowLipDepth'] = { value = tonumber(data.value.x), hash = 0x5D16 }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            MouthTuning = mouthPage:RegisterElement('gridslider', {
                                leftlabel = 'Mouth Width -',
                                rightlabel = 'Mouth Width +',
                                toplabel = 'Mouth Depth +',
                                bottomlabel = 'Mouth Depth -',
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
                            MouthPlacement = mouthPage:RegisterElement('gridslider', {
                                leftlabel = 'Mouth X Pos -',
                                rightlabel = 'Mouth X Pos +',
                                toplabel = 'Mouth Y Pos +',
                                bottomlabel = 'Mouth Y Pos -',
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
                            mouthPage:RouteTo()
                        end
                        if key == 'Nose' then
                            local nosePage = MyMenu:RegisterPage('feather-character:NosePage')
                            nosePage:RegisterElement('header', {
                                value = 'My First Menu',
                                slot = "header",
                                style = {}
                            })
                            nosePage:RegisterElement('subheader', {
                                value = "First Page",
                                slot = "header",
                                style = {}
                            })
                            nosePage:RegisterElement('bottomline', {
                                slot = "footer",
                                style = {}
                            })
                            nosePage:RegisterElement('button', {
                                label = "Go Back",
                                slot = 'footer',
                                style = {}
                            }, function()
                                SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                                mainAppearanceMenu:RouteTo()
                            end)
                            nosePage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Move Cam Up',
                                current = 'Move Cam Down ',
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
                            nosePage:RegisterElement('pagearrows', {
                                slot = 'footer',
                                total = ' Rotate Right ',
                                current = 'Rotate Left ',
                                style = {}
                            }, function(data)
                                if data.value == 'forward' then
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading + 10.0)
                                else
                                    local heading = GetEntityHeading(PlayerPedId())
                                    SetEntityHeading(PlayerPedId(), heading - 10.0)
                                end
                            end)
                            NoseGrid1 = nosePage:RegisterElement('gridslider', {
                                leftlabel = 'Nose Width -',
                                rightlabel = 'Nose Width +',
                                toplabel = 'Nose Height +',
                                bottomlabel = 'Nose Height -',
                                maxx = 1,
                                maxy = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0x6E7F, tonumber(data.value.x))
                                SetCharExpression(PlayerPedId(), 0x03F5, tonumber(data.value.y))
                                SelectedAttributeElements['NoseWidth'] = { value = tonumber(data.value.x), hash = 0x6E7F }
                                SelectedAttributeElements['NoseHeight'] = { value = tonumber(data.value.y), hash = 0x03F5 }
                                UpdatePedVariation(PlayerPedId())
                            end)
                            NoseGrid2 = nosePage:RegisterElement('gridslider', {
                                leftlabel = 'Nose Curve -',
                                rightlabel = 'Nose Curve +',
                                toplabel = 'Nose Angle +',
                                bottomlabel = 'Nose Angle -',
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
                            NoseGrid3 = nosePage:RegisterElement('gridslider', {
                                leftlabel = 'Nose Size -',
                                rightlabel = 'Nose Size +',
                                toplabel = 'Nostril Distance +',
                                bottomlabel = 'Nostril Distance -',
                                maxx = 1,
                                maxy = 1,
                                arrowsteps = 10,
                                precision = 1
                            }, function(data)
                                SetCharExpression(PlayerPedId(), 0x3471, tonumber(data.value.x))
                                SetCharExpression(PlayerPedId(), 0x561E, tonumber(data.value.y))
                                UpdatePedVariation(PlayerPedId())
                            end)
                            nosePage:RouteTo()
                        end
                    end)
                end
                faceAdjMenu:RegisterElement('bottomline', {
                    slot = "footer",
                    style = {}
                })
                faceAdjMenu:RegisterElement('button', {
                    label = "Go Back",
                    slot = 'footer',
                    style = {}
                }, function()
                    SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                    mainAppearanceMenu:RouteTo()
                end)
                SwitchCam(Config.CameraCoords.creation.x - 0.25, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z + 0.7, Config.CameraCoords.creation.h, 0.0)
                faceAdjMenu:RouteTo()
            end)
            mainAppearanceMenu:RegisterElement('button', {
                label = 'Facial Features',
                style = {}
            }, function()
                local facialFeaturesPage = MyMenu:RegisterPage('feather-character:FacialFeaturesPage')
                facialFeaturesPage:RegisterElement('header', {
                    value = 'Facial Features',
                    slot = "header",
                    style = {}
                })
                facialFeaturesPage:RegisterElement('subheader', {
                    value = "First Page",
                    slot = "header",
                    style = {}
                })
                for k, v in pairs(FaceFeatures.Features) do
                    facialFeaturesPage:RegisterElement('button', {
                        label = k,
                        style = {}
                    }, function()
                        local featuresSubPage = MyMenu:RegisterPage('feather-character:featuresub:page')
                        if not SelectedOverlayElements[v] then
                            SelectedOverlayElements[v] = {
                                ['textureId'] = 1,
                                ['opacity'] = 1.0,
                                ['variant'] = 1,
                                ['color1'] = 1,
                                ['color2'] = 1,
                                ['color3'] = 1
                            }
                        end
                        SetDefaultValues(v)
                        featuresSubPage:RegisterElement('header', {
                            value = 'My First Menu',
                            slot = "header",
                            style = {}
                        })
                        featuresSubPage:RegisterElement('subheader', {
                            value = "Choose your " .. v .. " Options",
                            slot = "header",
                            style = {}
                        })
                        featuresSubPage:RegisterElement('bottomline', {
                            slot = "content",
                            style = {}
                        })
                        featuresSubPage:RegisterElement('pagearrows', {
                            total = ' Move Cam Up',
                            current = 'Move Cam Down ',
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
                        featuresSubPage:RegisterElement('pagearrows', {
                            total = ' Rotate Right ',
                            current = 'Rotate Left ',
                            style = {}
                        }, function(data)
                            if data.value == 'forward' then
                                local heading = GetEntityHeading(PlayerPedId())
                                SetEntityHeading(PlayerPedId(), heading + 10.0)
                            else
                                local heading = GetEntityHeading(PlayerPedId())
                                SetEntityHeading(PlayerPedId(), heading - 10.0)
                            end
                        end)
                        featuresSubPage:RegisterElement('slider', {
                            label = v .. ' Opacity',
                            start = 0,
                            min = 0,
                            max = 1,
                            steps = 0.1
                        }, function(data)
                            if data.value == 1 then
                                data.value = 1.0
                            end
                            if data.value > 0 then
                            ActiveOpacity[v] = data.value
                            ChangeOverlay(PlayerPedId(),v, 1, ActiveTexture[v], 0, 0, 1, 1.0, 0, 1, 0, 0, 0, 1,  ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                            else
                                ChangeOverlay(PlayerPedId(),v, 0, ActiveTexture[v], 0, 0, 1, 1.0, 0, 1, 0, 0, 0, ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                            end
                            SelectedOverlayElements[v]["opacity"] = ActiveOpacity[v]
                        end)
                        featuresSubPage:RegisterElement('slider', {
                            label = v .. ' Texture',
                            start = 0,
                            min = 0,
                            max = #overlays_info[v],
                            steps = 1
                        }, function(data)
                            ActiveTexture[v] = data.value
                            if data.value > 0 then
                                ChangeOverlay(PlayerPedId(),v, 1, ActiveTexture[v], 0, 0, 1, 1.0, 0, 1, 0, 0, 0, ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                            else
                                ChangeOverlay(PlayerPedId(),v, 0, ActiveTexture[v], 0, 0, 1, 1.0, 0, 1, 0, 0, 0, ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                            end
                            SelectedOverlayElements[v]['textureId'] = ActiveTexture[v]
                        end)
                        featuresSubPage:RegisterElement('line', {
                            slot = "content",
                            style = {}
                        })
                        featuresSubPage:RegisterElement('bottomline', {
                            slot = "footer",
                            style = {}
                        })
                        featuresSubPage:RegisterElement('button', {
                            label = "Go Back",
                            slot = 'footer',
                            style = {}
                        }, function()
                            facialFeaturesPage:RouteTo()
                        end)
                        featuresSubPage:RouteTo()
                    end)
                end
                facialFeaturesPage:RegisterElement('bottomline', {
                    slot = "footer",
                    style = {}
                })
                facialFeaturesPage:RegisterElement('button', {
                    label = "Go Back",
                    slot = 'footer',
                    style = {}
                }, function()
                    SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                    mainAppearanceMenu:RouteTo()
                end)
                SwitchCam(Config.CameraCoords.creation.x - 0.25, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z + 0.7, Config.CameraCoords.creation.h, 0.0)
                facialFeaturesPage:RouteTo()
            end)
            mainAppearanceMenu:RouteTo()
        end)
        categoriesPage:RegisterElement('button', {
            label = 'Body',
            style = {}
        }, function()
            local bodyPage = MyMenu:RegisterPage('feather-character:BodyPage')
            local bodySlidersMade = nil
            bodyPage:RegisterElement('header', {
                value = 'My First Menu',
                slot = "header",
                style = {}
            })
            bodyPage:RegisterElement('subheader', {
                value = "",
                slot = "header",
                style = {}
            })
            bodyPage:RegisterElement('button', {
                label = "Go Back",
                slot = 'footer',
                style = {}
            }, function()
                categoriesPage:RouteTo()
                SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
                Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
            end)
            if bodySlidersMade == nil then
                bodySlidersMade = true
                bodyPage:RegisterElement('pagearrows', {
                    slot = 'footer',
                    total = ' Zoom Cam In',
                    current = 'Zoom Cam Out ',
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
                    total = ' Move Cam Up',
                    current = 'Move Cam Down ',
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
                    total = ' Rotate Right ',
                    current = 'Rotate Left ',
                    style = {}
                }, function(data)
                    if data.value == 'forward' then
                        local heading = GetEntityHeading(PlayerPedId())
                        SetEntityHeading(PlayerPedId(), heading + 10.0)
                    else
                        local heading = GetEntityHeading(PlayerPedId())
                        SetEntityHeading(PlayerPedId(), heading - 10.0)
                    end
                end)
                HeightSlider = bodyPage:RegisterElement('arrows', {
                    label = "Height",
                    start = 5,
                    options = Config.Heights
                }, function(data)
                    if data.value == 1 then
                        data.value = 1.0
                    end
                    SetPedScale(PlayerPedId(), data.value)
                    SelectedAttributeElements['Height'] = { value = data.value }
                end)
                BodySlider   = bodyPage:RegisterElement('slider', {
                    label = "Body Type",
                    start = 0,
                    min = 1,
                    max = #BODYTYPES,
                    steps = 1
                }, function(data)
                    local size = data.value
                    SelectedAttributeElements['BodyType'] = { hash = BODYTYPES[size] }
                    EquipMetaPedOutfit(PlayerPedId(), BODYTYPES[size])
                end)
                ChestSlider  = bodyPage:RegisterElement('slider', {
                    label = "Chest Size",
                    start = 0,
                    min = 1,
                    max = #CHESTTYPE,
                    steps = 1
                }, function(data)
                    local size = data.value
                    SelectedAttributeElements['ChestSize'] = { hash = CHESTTYPE[size] }
                    EquipMetaPedOutfit(PlayerPedId(), CHESTTYPE[size])
                end)
                WaistSlider  = bodyPage:RegisterElement('slider', {
                    label = "Waist Size",
                    start = 0,
                    min = 1,
                    max = #WAISTTYPES,
                    steps = 1,
                }, function(data)
                    local size = data.value
                    SelectedAttributeElements['WaistSize'] = { hash = WAISTTYPES[size] }
                    EquipMetaPedOutfit(PlayerPedId(), WAISTTYPES[size])
                end)
                ForearmGrid1 = bodyPage:RegisterElement('gridslider', {
                    leftlabel = 'Forearm Size -',
                    rightlabel = 'Forearm Size +',
                    toplabel = 'Upper Arm Size +',
                    bottomlabel = 'Upper Arm Size -',
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
                    leftlabel = 'Calves Size -',
                    rightlabel = 'Calves Size +',
                    toplabel = 'Thighs Size +',
                    bottomlabel = 'Thighs Size -',
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
                    leftlabel = 'Waist Width -',
                    rightlabel = 'Waist Width +',
                    toplabel = 'Hip Width +',
                    bottomlabel = 'Hip Width -',
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
            end
            bodyPage:RouteTo()
        end)
        categoriesPage:RegisterElement('button', {
            label = 'Clothing',
            style = {
            }
        }, function()
            local clothingCategoriesPage = MyMenu:RegisterPage('feather-character:ClothingCategoriesPage')
            clothingCategoriesPage:RegisterElement('header', {
                value = 'Clothing Selection',
                slot = "header",
                style = {}
            })
            clothingCategoriesPage:RegisterElement('bottomline', {
                slot = "footer",
                style = {}
            })
            clothingCategoriesPage:RegisterElement('button', {
                label = "Go Back",
                slot = 'footer',
                style = {}
            }, function()
                categoriesPage:RouteTo()
            end)
            for k, v in pairs(CharacterConfig.Clothing.Clothes[gender]) do
                clothingCategoriesPage:RegisterElement('button', {
                    label = k,
                    style = {
                    },
                }, function()
                    local activePage = MyMenu:RegisterPage('feather-character:ActiveClothingPage')
                    if k == "Upper" then
                        activePage:RegisterElement('header', {
                            value = 'Clothing Selection',
                            slot = "header",
                            style = {}
                        })
                        activePage:RegisterElement('subheader', {
                            value = "These are the items and the variants",
                            slot = "header",
                            style = {}
                        })
                        activePage:RegisterElement('button', {
                            label = "Go Back",
                            slot = 'footer',
                            style = {},
                        }, function()
                            SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
                                Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                                clothingCategoriesPage:RouteTo()
                        end)
                        activePage:RegisterElement('pagearrows', {
                            slot = 'footer',
                            total = ' Zoom Cam In',
                            current = 'Zoom Cam Out ',
                            style = {},
                        }, function(data)
                            if data.value == 'forward' then
                                Fov = Fov - 1.0
                                SetCamFov(CharacterCamera, Fov)
                            else
                                Fov = Fov + 1.0
                                SetCamFov(CharacterCamera, Fov)
                            end
                        end)
                        activePage:RegisterElement('pagearrows', {
                            slot = 'footer',
                            total = ' Move Cam Up',
                            current = 'Move Cam Down ',
                            style = {},
                        }, function(data)
                            if data.value == 'forward' then
                                CamZ = CamZ + 0.1
                                SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
                            else
                                CamZ = CamZ - 0.1
                                SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
                            end
                        end)
                        activePage:RegisterElement('pagearrows', {
                            slot = 'footer',
                            total = ' Rotate Right ',
                            current = 'Rotate Left ',
                            style = {},
                        }, function(data)
                            if data.value == 'forward' then
                                local heading = GetEntityHeading(PlayerPedId())
                                SetEntityHeading(PlayerPedId(), heading + 10.0)
                            else
                                local heading = GetEntityHeading(PlayerPedId())
                                SetEntityHeading(PlayerPedId(), heading - 10.0)
                            end
                        end)
                        activePage:RouteTo()
                        SwitchCam(Config.CameraCoords.creation.x - 0.4, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z + 0.4, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom - 30.0)
                        CamZ = Config.CameraCoords.creation.z + 0.5
                    elseif k == "Lower" then
                        activePage:RegisterElement('header', {
                            value = 'Clothing Selection',
                            slot = "header",
                            style = {}
                        })
                        activePage:RegisterElement('subheader', {
                            value = "These are the items and the variants",
                            slot = "header",
                            style = {}
                        })
                        activePage:RegisterElement('button', {
                            label = "Go Back",
                            slot = 'footer',
                            style = {}
                        }, function()
                            SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                            clothingCategoriesPage:RouteTo()
                        end)
                        activePage:RegisterElement('pagearrows', {
                            slot = 'footer',
                            total = ' Zoom Cam In',
                            current = 'Zoom Cam Out ',
                            style = {},
                        }, function(data)
                            if data.value == 'forward' then
                                Fov = Fov - 1.0
                                SetCamFov(CharacterCamera, Fov)
                            else
                                Fov = Fov + 1.0
                                SetCamFov(CharacterCamera, Fov)
                            end
                        end)
                        activePage:RegisterElement('pagearrows', {
                            slot = 'footer',
                            total = ' Move Cam Up',
                            current = 'Move Cam Down ',
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
                        activePage:RegisterElement('pagearrows', {
                            slot = 'footer',
                            total = ' Rotate Right ',
                            current = 'Rotate Left ',
                            style = {},
                        }, function(data)
                            if data.value == 'forward' then
                                local heading = GetEntityHeading(PlayerPedId())
                                SetEntityHeading(PlayerPedId(), heading + 10.0)
                            else
                                local heading = GetEntityHeading(PlayerPedId())
                                SetEntityHeading(PlayerPedId(), heading - 10.0)
                            end
                        end)
                        activePage:RouteTo()
                        SwitchCam(Config.CameraCoords.creation.x - 0.4, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z - 0.2, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom - 30.0)
                        CamZ = Config.CameraCoords.creation.z - 0.2
                    elseif k == "Accessories" then
                        activePage:RegisterElement('header', {
                            value = 'Clothing Selection',
                            slot = "header",
                            style = {}
                        })
                        activePage:RegisterElement('subheader', {
                            value = "These are the items and the variants",
                            slot = "header",
                            style = {}
                        })
                        activePage:RegisterElement('button', {
                            label = "Go Back",
                            slot = 'footer',
                            style = {}
                        }, function()
                            SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                            clothingCategoriesPage:RouteTo()
                        end)
                        activePage:RegisterElement('pagearrows', {
                            slot = 'footer',
                            total = ' Zoom Cam In',
                            current = 'Zoom Cam Out ',
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
                        activePage:RegisterElement('pagearrows', {
                            slot = 'footer',
                            total = ' Move Cam Up',
                            current = 'Move Cam Down ',
                            style = {},
                        }, function(data)
                            if data.value == 'forward' then
                                CamZ = CamZ + 0.1
                                SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
                            else
                                CamZ = CamZ - 0.1
                                SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
                            end
                        end)
                        activePage:RegisterElement('pagearrows', {
                            slot = 'footer',
                            total = ' Rotate Right ',
                            current = 'Rotate Left ',
                            style = {}
                        }, function(data)
                            if data.value == 'forward' then
                                local heading = GetEntityHeading(PlayerPedId())
                                SetEntityHeading(PlayerPedId(), heading + 10.0)
                            else
                                local heading = GetEntityHeading(PlayerPedId())
                                SetEntityHeading(PlayerPedId(), heading - 10.0)
                            end
                        end)
                        activePage:RouteTo()
                        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
                    end
                    for index, key in pairs(CharacterConfig.Clothing.Clothes[gender][k]) do
                        table.insert(selectedClothing, index)
                        if selectedClothing[index .. 'Category'] == nil then
                            CategoryElement = activePage:RegisterElement('slider', {
                                label = index,
                                start = 1,
                                min = 0,
                                max = #key.CategoryData,
                                steps = 1
                            }, function(data)
                                MainComponent = data.value
                                if MainComponent > 0 then
                                    selectedClothing[index .. 'Variant'] = selectedClothing[index .. 'Variant']:update({
                                        label = index .. ' variant',
                                        value = 1,
                                        max = #key.CategoryData[MainComponent], --#v.CategoryData[inputvalue],
                                    })
                                    AddComponent(PlayerPedId(), key.CategoryData[MainComponent][1].hash, index)
                                    local type = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                                    ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8,
                                        key.CategoryData[MainComponent][1].hash, type, true)
                                    selectedClothingElements[index] = key.CategoryData[MainComponent][1].hash
                                else
                                    Citizen.InvokeNative(0x0D7FFA1B2F69ED82, PlayerPedId(), selectedClothingElements[index], 0, 0)
                                    selectedClothingElements[index] = nil
                                    Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
                                end
                            end)
                            VariantElement = activePage:RegisterElement('slider', {
                                label = index .. ' variant',
                                start = 1,
                                min = 1,
                                max = 5, --#v.CategoryData[inputvalue],
                                steps = 1
                            }, function(data)
                                VariantComponent = data.value
                                if VariantComponent > 0 then
                                    selectedClothing[index .. 'Variant'] = selectedClothing[index .. 'Variant']:update({
                                        label = index .. ' variant',
                                        max = #key.CategoryData[MainComponent], --#v.CategoryData[inputvalue],
                                    })
                                    AddComponent(PlayerPedId(), key.CategoryData[MainComponent][VariantComponent].hash, index)
                                    local type = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                                    ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8,
                                        key.CategoryData[MainComponent][VariantComponent].hash, type, true)
                                    selectedClothingElements[index] = key.CategoryData[MainComponent][VariantComponent].hash
                                end
                            end)
                            if Config.DyeClothes then
                                local Button = activePage:RegisterElement('button', {
                                    label = "Dye your " .. index,
                                    style = {
                                    },
                                }, function()
                                    local colorPage = MyMenu:RegisterPage('feather-character:ColorClothingPage')
                                    colorPage:RegisterElement('header', {
                                        value = 'My First Menu',
                                        slot = "header",
                                        style = {}
                                    })
                                    colorPage:RegisterElement('subheader', {
                                        value = "First Page",
                                        slot = "header",
                                        style = {}
                                    })
                                    colorPage:RegisterElement('button', {
                                        label = "Go Back",
                                        slot = 'footer',
                                        style = {}
                                    }, function()
                                        selectedColoring = nil
                                        clothingCategoriesPage:RouteTo()
                                    end)
                                    colorPage:RegisterElement('bottomline', {
                                        slot = "header",
                                        style = {}
                                    })
                                    local componentIndex = GetComponentIndexByCategory(PlayerPedId(), ActiveCatagory)
                                    local drawable, albedo, normal, material = GetMetaPedAssetGuids(PlayerPedId(), componentIndex)
                                    local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(PlayerPedId(), componentIndex)
                                    Wait(250)
                                    if selectedColoring == nil then
                                        local colorElement1 = colorPage:RegisterElement('slider', {
                                            label = 'Color 1',
                                            start = 1,
                                            min = 1,
                                            max = 254, --#v.CategoryData[inputvalue],
                                            steps = 1
                                        }, function(data)
                                            Color1 = data.value
                                            if MainComponent > 0 then
                                                RemoveTagFromMetaPed(index)
                                                AddComponent(PlayerPedId(), selectedClothingElements[index], nil)
                                                SetMetaPedTag(PlayerPedId(), drawable, albedo, normal, material, palette, Color1, tint1, tint2)
                                                UpdatePedVariation(PlayerPedId())
                                            end
                                        end)
                                        local colorElement2 = colorPage:RegisterElement('slider', {
                                            label = 'Color 2',
                                            start = 1,
                                            min = 1,
                                            max = 254, --#v.CategoryData[inputvalue],
                                            steps = 1
                                        }, function(data)
                                            Color2 = data.value
                                            if MainComponent > 0 then
                                                RemoveTagFromMetaPed(index)
                                                AddComponent(PlayerPedId(), selectedClothingElements[index], nil)
                                                SetMetaPedTag(PlayerPedId(), drawable, albedo, normal, material, palette, Color1, Color2, tint2)
                                                UpdatePedVariation(PlayerPedId())
                                            end
                                        end)
                                        local colorElement3 = colorPage:RegisterElement('slider', {
                                            label = 'Color 3',
                                            start = 1,
                                            min = 1,
                                            max = 254, --#v.CategoryData[inputvalue],
                                            steps = 1
                                        }, function(data)
                                            Color3 = data.value
                                            if MainComponent > 0 then
                                                RemoveTagFromMetaPed(index)
                                                AddComponent(PlayerPedId(), selectedClothingElements[index], nil)
                                                SetMetaPedTag(PlayerPedId(), drawable, albedo, normal, material, palette, Color1, Color2, Color3)
                                                UpdatePedVariation(PlayerPedId())
                                            end
                                        end)
                                        colorElement1 = colorElement1:update({
                                            label = "Color 1",
                                        })
                                        colorElement2 = colorElement2:update({
                                            label = "Color 2",
                                        })
                                        colorElement3 = colorElement3:update({
                                            label = "Color 3",
                                        })
                                    end
                                    selectedColoring = true
                                    colorPage:RouteTo()
                                end)
                                local Line = activePage:RegisterElement('line', {
                                    slot = "content",
                                    style = {}
                                })
                                Line = Line:update({})
                                Button = Button:update({})
                            end
                            -- Store your elements with unique keys so that we can easily retrieve these later when data needs to be updated. We are appenting strings so that it stays unique.
                            selectedClothing[index .. 'Category'] = CategoryElement
                            selectedClothing[index .. 'Variant'] = VariantElement
                            CategoryElement = CategoryElement:update({
                                label = index,
                                max = #key.CategoryData, --#v.CategoryData[inputvalue],
                            })
                            VariantElement = VariantElement:update({
                                label = index .. ' variant',
                                max = #key.CategoryData, --#v.CategoryData[inputvalue],
                            })
                            Line = activePage:RegisterElement('line', {
                                slot = "content",
                                style = {}
                            })
                            Line = Line:update({})
                        end
                    end
                end)
            end
            clothingCategoriesPage:RouteTo()
        end)
        categoriesPage:RegisterElement('button', {
            label = 'Makeup',
            style = {}
        }, function()
            local makeupPage = MyMenu:RegisterPage('feather-character:MakeupPage')
            makeupPage:RegisterElement('header', {
                value = 'My First Menu',
                slot = "header",
                style = {}
            })
            makeupPage:RegisterElement('subheader', {
                value = "First Page",
                slot = "header",
                style = {}
            })
            makeupPage:RegisterElement('bottomline', {
                slot = "footer",
                style = {}
            })
            for k, v in pairs(FaceFeatures.Makeup) do
                makeupPage:RegisterElement('button', {
                    label = k,
                    style = {}
                }, function()
                    local activeMakeupPage = MyMenu:RegisterPage('feather-character:ActiveMakeupPage')
                    if not SelectedOverlayElements[v] then
                        SelectedOverlayElements[v] = {
                            ['textureId'] = 1,
                            ['opacity'] = 1.0,
                            ['variant'] = 1,
                            ['color1'] = 1,
                            ['color2'] = 1,
                            ['color3'] = 1,
                        }
                    end
                    SetDefaultValues(v)
                    activeMakeupPage:RegisterElement('header', {
                        value = 'My First Menu',
                        slot = "header",
                        style = {}
                    })
                    activeMakeupPage:RegisterElement('subheader', {
                        value = "Choose your " .. v .. " Options",
                        slot = "header",
                        style = {}
                    })
                    activeMakeupPage:RegisterElement('bottomline', {
                        slot = "content",
                        style = {}
                    })
                    activeMakeupPage:RegisterElement('pagearrows', {
                        total = ' Move Cam Up',
                        current = 'Move Cam Down ',
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
                    activeMakeupPage:RegisterElement('pagearrows', {
                        total = ' Rotate Right ',
                        current = 'Rotate Left ',
                        style = {}
                    }, function(data)
                        if data.value == 'forward' then
                            local heading = GetEntityHeading(PlayerPedId())
                            SetEntityHeading(PlayerPedId(), heading + 10.0)
                        else
                            local heading = GetEntityHeading(PlayerPedId())
                            SetEntityHeading(PlayerPedId(), heading - 10.0)
                        end
                    end)
                    activeMakeupPage:RegisterElement('slider', {
                        label = v .. ' Opacity',
                        start = 1,
                        min = 0,
                        max = 1,
                        steps = 0.1
                    }, function(data)
                        if data.value == 1 then
                            data.value = 1.0
                        end
                        ActiveOpacity[v] = data.value
                        if data.value > 0 then
                            ChangeOverlay(PlayerPedId(), v, 1, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1, ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                        else
                            ChangeOverlay(PlayerPedId(), v, 0, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1, ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                        end
                        SelectedOverlayElements[v]["opacity"] = ActiveOpacity[v]
                    end)
                    activeMakeupPage:RegisterElement("toggle", {
                        label = v,
                        start = false
                    }, function(data)
                        if data.value then
                            ActiveTexture[v] = 1
                            ChangeOverlay(PlayerPedId(), v, 1, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1, ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v], (SelectedAttributeElements['Albedo'].hash))
                            SelectedOverlayElements[v]["textureId"] = ActiveTexture[v]
                        else
                            ChangeOverlay(PlayerPedId(), v, 0, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1, ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                            ActiveTexture[v] = 0
                            SelectedOverlayElements[v]["textureId"] = nil
                        end
                    end)
                    if v == 'eyeliners' then
                        VarMax = 15
                    elseif v == 'shadows' then
                        VarMax = 5
                    elseif v == 'lipsticks' then
                        VarMax = 7
                    end
                    if v == 'eyeliners' or v == 'shadows' or v == 'lipsticks' then
                        activeMakeupPage:RegisterElement('slider', {
                            label = v .. ' Variant',
                            start = 0,
                            min = 0,
                            max = VarMax,
                            steps = 1
                        }, function(data)
                            ActiveVariant[v] = data.value
                            if data.value > 0 then
                                ChangeOverlay(PlayerPedId(), v, 1, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1, ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                            else
                                ChangeOverlay(PlayerPedId(), v, 0, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1, ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                            end
                            SelectedOverlayElements[v]["variant"] = ActiveVariant[v]
                        end)
                    end
                    activeMakeupPage:RegisterElement('line', {
                        slot = "content",
                        style = {}
                    })
                    activeMakeupPage:RegisterElement('slider', {
                        label = v .. ' Color 1',
                        start = 1,
                        min = 1,
                        max = 254,
                        steps = 1
                    }, function(data)
                        ActiveColor1[v] = data.value
                        if ActiveColor1[v] > 0 then
                            ChangeOverlay(PlayerPedId(), v, 1, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1, ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                        else
                            ChangeOverlay(PlayerPedId(), v, 0, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1, ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                        end
                        SelectedOverlayElements[v]["color1"] = ActiveColor1[v]
                    end)
                    if v ~= { 'lipsticks', 'foundation' } then
                        activeMakeupPage:RegisterElement('slider', {
                            label = v .. ' Color 2',
                            start = 1,
                            min = 1,
                            max = 254,
                            steps = 1
                        }, function(data)
                            ActiveColor2[v] = data.value
                            if ActiveColor2[v] > 0 then
                                ChangeOverlay(PlayerPedId(), v, 1, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1, ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                            else
                                ChangeOverlay(PlayerPedId(), v, 0, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1, ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                            end
                            SelectedOverlayElements[v]["color2"] = ActiveColor2[v]
                        end)
                    end
                    if v ~= { 'lipsticks', 'foundation' } then
                        activeMakeupPage:RegisterElement('slider', {
                            label = v .. ' Color 3',
                            start = 1,
                            min = 1,
                            max = 254,
                            steps = 1
                        }, function(data)
                            ActiveColor3[v] = data.value
                            if ActiveColor3[v] > 0 then
                                ChangeOverlay(PlayerPedId(), v, 1, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1, ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                            else
                                ChangeOverlay(PlayerPedId(), v, 0, ActiveTexture[v], 0, 0, tx_color_type, 1.0, 0, 1, ActiveColor1[v], ActiveColor2[v], ActiveColor3[v], ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                            end
                            SelectedOverlayElements[v]["color3"] = ActiveColor3[v]
                        end)
                    end
                    activeMakeupPage:RegisterElement('bottomline', {
                        slot = "footer",
                        style = {}
                    })
                    activeMakeupPage:RegisterElement('button', {
                        label = "Go Back",
                        slot = 'footer',
                        style = {}
                    }, function()
                        makeupPage:RouteTo()
                    end)
                    activeMakeupPage:RouteTo()
                end)
            end
            makeupPage:RegisterElement('button', {
                label = "Go Back",
                slot = 'footer',
                style = {}
            }, function()
                categoriesPage:RouteTo()
            end)
            SwitchCam(Config.CameraCoords.creation.x - 0.25, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z + 0.7, Config.CameraCoords.creation.h, 0.0)
            makeupPage:RouteTo()
        end)
        categoriesPage:RegisterElement('header', {
            value = 'Clothing Selection',
            slot = "header",
            style = {}
        })
        categoriesPage:RegisterElement('bottomline', {
            slot = "footer",
            style = {}
        })
        categoriesPage:RegisterElement('button', {
            label = "Go Back",
            slot = 'footer',
            style = {}
        }, function()
            mainCreationPage:RouteTo()
        end)
        categoriesPage:RouteTo()
    end)
    mainCreationPage:RegisterElement('input', {
        label = "First Name",
        placeholder = "Enter First Name",
        style = {
        }
    }, function(data)
        firstName = data.value
    end)
    mainCreationPage:RegisterElement('input', {
        label = "Last Name",
        placeholder = "Enter Last Name",
        style = {
        }
    }, function(data)
        lastName = data.value
    end)
    mainCreationPage:RegisterElement('input', {
        label = "Birthday",
        placeholder = "Birthday",
        style = {
        }
    }, function(data)
        dob = data.value
    end)
    mainCreationPage:RegisterElement('textarea', {
        label = "Character Description",
        placeholder = "Enter text",
        rows = "5",
        resize = false,
        style = {
        }
    }, function(data)
        charDesc = data.value
    end)
    mainCreationPage:RegisterElement('input', {
        label = "Image Link",
        placeholder = "Link",
        style = {
        }
    }, function(data)
        imgLink = data.value
    end)
    if imgLink == nil then
        imgLink = 'None'
    end
    mainCreationPage:RegisterElement('arrows', {
        label = "Gender",
        start = 1,
        options = {
            "Male",
            "Female"
        },
    }, function(data)
        if data.value == "Male" then
            Model = 'mp_male'
        else
            Model = 'mp_female'
        end
        LoadPlayer(Model)
    end)
    mainCreationPage:RegisterElement('button', {
        label = "Save Character",
        style = {
        }
    }, function()
        Clothing = json.encode(selectedClothingElements)
        Attributes = json.encode(SelectedAttributeElements)
        Overlays = json.encode(SelectedOverlayElements)
        local data = {
            firstname = firstName,
            lastname = lastName,
            dob = dob,
            model = Model,
            desc = charDesc,
            img = imgLink,
        }

        FeatherCore.RPC.Call("SaveCharacterData", { data }, function(result)
            TriggerEvent('feather-character:SpawnSelect', result)
            TriggerServerEvent('feather-character:UpdateAttributeDB', result, Attributes, Clothing, Overlays)
        end)
    end)

    MyMenu:Open({
        startupPage = mainCreationPage
    })
end)

RegisterNetEvent('FeatherMenu:closed', function(data)
    MenuOpened = false
end)

--Global function goes here as our local textureId is used
function ChangeOverlay(ped, name, visibility, tx_id, tx_normal, tx_material, tx_color_type, tx_opacity, tx_unk, palette_id, palette_color_primary, palette_color_secondary, palette_color_tertiary, var, opacity, albedo)
    for k, v in pairs(overlay_all_layers) do
        if v.name == name then
            v.visibility = visibility
            if visibility ~= 0 then
                v.tx_normal = tx_normal
                v.tx_material = tx_material
                v.tx_color_type = tx_color_type
                v.tx_opacity = tx_opacity
                v.tx_unk = tx_unk
                if tx_color_type == 0 then
                    v.palette = color_palettes[palette_id][1]
                    v.palette_color_primary = palette_color_primary
                    v.palette_color_secondary = palette_color_secondary
                    v.palette_color_tertiary = palette_color_tertiary
                end
                if name == "shadows" or name == "eyeliners" or name == "lipsticks" then
                    v.var = var
                    v.tx_id = overlays_info[name][1].id
                else
                    v.var = 0
                    v.tx_id = overlays_info[name][tx_id].id
                end
                v.opacity = opacity
            end
        end
    end
    if textureId ~= -1 then
        Citizen.InvokeNative(0xB63B9178D0F58D82, textureId)
        Citizen.InvokeNative(0x6BEFAA907B076859, textureId)
    end
    local current_texture_settings = texture_types[gender]
    if visibility > 0 then
        textureId = Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, current_texture_settings.normal, current_texture_settings.material)
    end
    for k, v in pairs(overlay_all_layers) do
        if v.visibility and v.visibility ~= 0 then
            local overlay_id = Citizen.InvokeNative(0x86BB5FF45F193A02, textureId, v.tx_id, v.tx_normal,
                v.tx_material, v.tx_color_type, v.tx_opacity, v.tx_unk)
            if v.tx_color_type == 0 then
                Citizen.InvokeNative(0x1ED8588524AC9BE1, textureId, overlay_id, v.palette)
                Citizen.InvokeNative(0x2DF59FFE6FFD6044, textureId, overlay_id, v.palette_color_primary, v.palette_color_secondary, v.palette_color_tertiary)
            end
            Citizen.InvokeNative(0x3329AAE2882FC8E4, textureId, overlay_id, v.var)
            Citizen.InvokeNative(0x6C76BC24F8BB709A, textureId, overlay_id, v.opacity)
        end
    end
    while not Citizen.InvokeNative(0x31DC8D3F216D8509, textureId) do
        Wait(5)
    end
    Citizen.InvokeNative(0x92DAABA2C1C10B0E, textureId)
    Citizen.InvokeNative(0x0B46E25761519058, ped, joaat("heads"), textureId)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
end

-- global funct goes here as our local tx_color_type is used
function SetDefaultValues(selected) -- make local in creation menu
    if ActiveTexture[selected] == nil then
        ActiveTexture[selected] = 1
    end
    if ActiveColor1[selected] == nil then
        ActiveColor1[selected] = 1
    end
    if ActiveColor2[selected] == nil then
        ActiveColor2[selected] = 1
    end
    if ActiveColor3[selected] == nil then
        ActiveColor3[selected] = 1
    end
    if ActiveVariant[selected] == nil then
        ActiveVariant[selected] = 1
    end
    if ActiveOpacity[selected] == nil then
        ActiveOpacity[selected] = 1.0
    end
    if selected == "scars" or selected == "spots" or selected == "disc" or selected == "complex" or selected == "acne" or selected == "ageing" or selected == "moles" or selected == "freckles" then
        tx_color_type = 1
    else
        tx_color_type = 0
    end
end
-- TODO: REMOVE ALL THIS STUFF AS MENUAPI/REDEMTP_MENU_BASE WILL NOT BE NEEDED.
FeatherMenu = exports['feather-menu'].initiate()

MyMenu = FeatherMenu:RegisterMenu('feather:character:menu', {
    top = '1%',
    left = '1%',
    ['720width'] = '500px',
    ['1080width'] = '600px',
    ['2kwidth'] = '700px',
    ['4kwidth'] = '900px',
    style = {
    },
    contentslot = {
        style = { --This style is what is currently making the content slot scoped and scrollable. If you delete this, it will make the content height dynamic to its inner content.
            ['height'] = '800px',
            ['width'] = '500px',
            ['min-height'] = '500px'
        }
    },
    draggable = false,
    canclose = true
})

MainAppearanceMenu = MyMenu:RegisterPage('appearance:page')

Gender = GetGender()

SelectedAttributes = {}        -- This can keep track of what was selected data wise
SelectedAttributeElements = {} --This table keeps track of your clothing elements

MainAppearanceMenu:RegisterElement('header', {
    value = 'My First Menu',
    slot = "header",
    style = {}
})
MainAppearanceMenu:RegisterElement('subheader', {
    value = "First Page",
    slot = "header",
    style = {}
})

MainAppearanceMenu:RegisterElement('button', {
    label = 'Hair',
    style = {
    }
}, function()
    HairCategoryPage = MyMenu:RegisterPage('eyes:page')
    CreateHairPage()
    HairCategoryPage:RouteTo()
end)

for key, v in pairs(FeatureNames) do
    MainAppearanceMenu:RegisterElement('button', {
        label = key,
        style = {
        }
    }, function()
        if key == 'Eyes' then
            EyesPage = MyMenu:RegisterPage('eyes:page')
            CreateEyesPage()
            EyesPage:RouteTo()
        end
        if key == 'Cheeks' then
            CheekPage = MyMenu:RegisterPage('cheeks:page')
            CreateCheekPage()
            CheekPage:RouteTo()
        end
        if key == 'Chin' then
            ChinPage = MyMenu:RegisterPage('chin:page')
            CreateChinPage()
            ChinPage:RouteTo()
        end
        if key == 'Eyebrows' then
            EyebrowPage = MyMenu:RegisterPage('eyebrows:page')
            CreateEyebrowPage()
            EyebrowPage:RouteTo()
        end
        if key == 'Ears' then
            EarPage = MyMenu:RegisterPage('ears:page')
            CreateEarsPage()
            EarPage:RouteTo()
        end
        if key == 'Face' then
            FacePage = MyMenu:RegisterPage('face:page')
            CreateFacePage()
            FacePage:RouteTo()
        end
        if key == 'Jaw' then
            JawPage = MyMenu:RegisterPage('jaw:page')
            CreateJawPage()
            JawPage:RouteTo()
        end
        if key == 'Mouth' then
            MouthPage = MyMenu:RegisterPage('mouth:page')
            CreateMouthPage()
            MouthPage:RouteTo()
        end
    end)
end
MainAppearanceMenu:RegisterElement('button', {
    label = "Save Appearance",
    style = {
    }
}, function()
    print(json.encode(SelectedAttributeElements))
    TriggerServerEvent('feather-character:UpdateAttributeDB', SelectedAttributeElements)
end)

MainAppearanceMenu:RegisterElement('button', {
    label = "Go Back",
    style = {
    },
}, function()
    MainCharacterPage:RouteTo()
end)

--second page
function CreateEyesPage()
    EyesPage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    EyesPage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    EyesPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        MainAppearanceMenu:RouteTo()
    end)

    local imgPath =
    [[
    <img width="250px" height="250px" style="margin: 0 auto;" src="nui://feather-character/ui/img/%s.png"/>
    ]]

    EyesPage:RegisterElement('button', {
        label = "Eye Height and Depth",
        style = {
        },
    }, function()
        if EyeGrid then
            EyeGrid:unRegister()
        end
        if EyeGrid2 then
            EyeGrid2:unRegister()
        end
        CreateEyePlacement()
        EyesPage:RouteTo()
    end)
    EyesPage:RegisterElement('button', {
        label = "Eye Distance and Angle",
        style = {
        },
    }, function()
        if EyeGrid then
            EyeGrid:unRegister()
        end
        if EyeGrid2 then
            EyeGrid2:unRegister()
        end
        CreateEyeDistance()
        EyesPage:RouteTo()
    end)

    EyesPage:RegisterElement('slider', {
        label = "Eye Color",
        start = 0,
        min = 0,
        max = #Features.Eyes[Gender],
        steps = 1,
    }, function(data)
        local coords = GetEntityCoords(PlayerPedId())
        print(Features.Eyes[Gender][data.value].color)
        StartAnimation("mood_normal_eyes_wide")
        AddComponent(PlayerPedId(), Features.Eyes[Gender][data.value].hash, nil)
        StartCam(coords.x, coords.y - 1, coords.z + 0.7, 2.0, 30.0)

        if EyePic and data.value > 0 then
            EyePic:unRegister()
            EyePic = EyesPage:RegisterElement("html", {

            })
            EyePic:update({
                value = {
                    imgPath:format(data.value)
                }
            })
            EyesPage:RouteTo()
        end
    end)

    EyePic = EyesPage:RegisterElement("html", {

    })
end

function CreateEyePlacement()
    EyeGrid = EyesPage:RegisterElement('gridslider', {
        leftlabel = 'Eye Depth -',
        rightlabel = 'Eye Depth +',
        toplabel = 'Eye Height +',
        bottomlabel = 'Eye Height -',
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        print(data.value.x)
        print(data.value.y)

        SetCharExpression(PlayerPedId(), 60996, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 56827, tonumber(data.value.y))
        UpdatePedVariation(PlayerPedId())
    end)

    EyeGrid2 = EyesPage:RegisterElement('gridslider', {
        leftlabel = 'Eye Distance -',
        rightlabel = 'Eye Distance +',
        toplabel = 'Eye Angle +',
        bottomlabel = 'Eye Angle -',
        maxx = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 42318, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 53862, tonumber(data.value.y))

        UpdatePedVariation(PlayerPedId())
    end)
end

function CreateEyeDistance()
    EyeGrid2 = EyesPage:RegisterElement('gridslider', {
        leftlabel = 'Eye Distance -',
        rightlabel = 'Eye Distance +',
        toplabel = 'Eye Angle +',
        bottomlabel = 'Eye Angle -',
        maxx = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 42318, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 53862, tonumber(data.value.y))

        UpdatePedVariation(PlayerPedId())
    end)
end

function CreateCheekPage()
    CheekPage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    CheekPage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    CheekPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        MainAppearanceMenu:RouteTo()
    end)
    for key, v in pairs(FeatureNames.Cheeks) do
        CheekPage:RegisterElement('button', {
            label = v,
            style = {
            }
        }, function()

        end)
    end
end

function CreateChinPage()
    ChinPage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    ChinPage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    ChinPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        MainAppearanceMenu:RouteTo()
    end)
    for key, v in pairs(FeatureNames.Chin) do
        ChinPage:RegisterElement('button', {
            label = v,
            style = {
            }
        }, function()

        end)
    end
end

function CreateEyebrowPage()
    EyebrowPage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    EyebrowPage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    EyebrowPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        MainAppearanceMenu:RouteTo()
    end)
    for key, v in pairs(FeatureNames.Eyebrows) do
        EyebrowPage:RegisterElement('button', {
            label = v,
            style = {
            }
        }, function()

        end)
    end
end

function CreateEarsPage()
    EarPage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    EarPage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    EarPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        MainAppearanceMenu:RouteTo()
    end)
    for key, v in pairs(FeatureNames.Ears) do
        EarPage:RegisterElement('button', {
            label = v,
            style = {
            }
        }, function()

        end)
    end
end

function CreateFacePage()
    FacePage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    FacePage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    FacePage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        MainAppearanceMenu:RouteTo()
    end)
    for key, v in pairs(FeatureNames.Face) do
        FacePage:RegisterElement('button', {
            label = v,
            style = {
            }
        }, function()

        end)
    end
end

function CreateJawPage()
    JawPage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    JawPage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    JawPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        MainAppearanceMenu:RouteTo()
    end)
    for key, v in pairs(FeatureNames.Jaw) do
        JawPage:RegisterElement('button', {
            label = v,
            style = {
            }
        }, function()

        end)
    end
end

function CreateMouthPage()
    MouthPage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    MouthPage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    MouthPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        MouthPlacement = nil
        MouthTuning = nil
        MainAppearanceMenu:RouteTo()
    end)
    MouthPage:RegisterElement('button', {
        label = "Mouth Placement",
        style = {
        },
    }, function()
        if MouthPlacement then
            MouthPlacement:unRegister()
        end
        if UpperLipGrid then
            UpperLipGrid:unRegister()
        end
        if UpperLipGrid2 then
            UpperLipGrid2:unRegister()
        end
        if LowerLipGrid then
            LowerLipGrid:unRegister()
        end
        if LowerLipGrid2 then
            LowerLipGrid2:unRegister()
        end
        if MouthTuning then
            MouthTuning:unRegister()
        end
        CreateMouthPlacement()
        MouthPage:RouteTo()
    end)
    MouthPage:RegisterElement('button', {
        label = "Mouth Fine Tuning",
        style = {
        },
    }, function()
        if MouthPlacement then
            MouthPlacement:unRegister()
        end
        if UpperLipGrid then
            UpperLipGrid:unRegister()
        end
        if UpperLipGrid2 then
            UpperLipGrid2:unRegister()
        end
        if LowerLipGrid then
            LowerLipGrid:unRegister()
        end
        if LowerLipGrid2 then
            LowerLipGrid2:unRegister()
        end
        if MouthTuning then
            MouthTuning:unRegister()
        end
        MouthTuning = true
        CreateMouthTuning()
        MouthPage:RouteTo()
        --end
    end)
    MouthPage:RegisterElement('button', {
        label = "Upper Lip",
        style = {
        },
    }, function()
        if MouthPlacement then
            MouthPlacement:unRegister()
        end
        if UpperLipGrid then
            UpperLipGrid:unRegister()
        end
        if UpperLipGrid2 then
            UpperLipGrid2:unRegister()
        end
        if LowerLipGrid then
            LowerLipGrid:unRegister()
        end
        if LowerLipGrid2 then
            LowerLipGrid2:unRegister()
        end
        if MouthTuning then
            MouthTuning:unRegister()
        end
        UpperLip = true
        CreateUpperLipTuning()
        MouthPage:RouteTo()
    end)
    MouthPage:RegisterElement('button', {
        label = "Lower Lip",
        style = {
        },
    }, function()
        if MouthPlacement then
            MouthPlacement:unRegister()
        end
        if UpperLipGrid then
            UpperLipGrid:unRegister()
        end
        if UpperLipGrid2 then
            UpperLipGrid2:unRegister()
        end
        if LowerLipGrid then
            LowerLipGrid:unRegister()
        end
        if LowerLipGrid2 then
            LowerLipGrid2:unRegister()
        end
        if MouthTuning then
            MouthTuning:unRegister()
        end
        LowerLip = true
        CreateLowerLipTuning()
        MouthPage:RouteTo()
    end)
end

function CreateUpperLipTuning()
    UpperLipGrid = MouthPage:RegisterElement('gridslider', {
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
        UpdatePedVariation(PlayerPedId())
    end)

    UpperLipGrid2 = MouthPage:RegisterElement('gridslider', {
        leftlabel = 'Upper Lip Depth -',
        rightlabel = 'Upper Lip Depth +',
        maxx = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0xC375, tonumber(data.value.x))
        UpdatePedVariation(PlayerPedId())
    end)
end

function CreateLowerLipTuning()
    LowerLipGrid = MouthPage:RegisterElement('gridslider', {
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
        UpdatePedVariation(PlayerPedId())
    end)
    LowerLipGrid2 = MouthPage:RegisterElement('gridslider', {
        leftlabel = 'Lower Lip Depth -',
        rightlabel = 'Lower Lip Depth +',
        maxx = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 0x5D16, tonumber(data.value.x))
        UpdatePedVariation(PlayerPedId())
    end)
end

function CreateMouthTuning()
    MouthTuning = MouthPage:RegisterElement('gridslider', {
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
        UpdatePedVariation(PlayerPedId())
    end)
end

function CreateMouthPlacement()
    MouthPlacement = MouthPage:RegisterElement('gridslider', {
        leftlabel = 'Mouth X Pos -',
        rightlabel = 'Mouth X Pos +',
        toplabel = 'Mouth Y Pos +',
        bottomlabel = 'Mouth Y Pos -',
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        print(data.value.x)
        print(data.value.y)
        SetCharExpression(PlayerPedId(), 31427, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 16653, tonumber(data.value.y))
    end)
end

function CreateHairPage()
    HairCategoryPage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    HairCategoryPage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    HairCategoryPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        MainAppearanceMenu:RouteTo()
    end)
    for key, v in pairs(HairandBeards[Gender]) do
        HairCategoryPage:RegisterElement('button', {
            label = key,
            style = {
            }
        }, function()
            HairandBeardPage = MyMenu:RegisterPage('hair:page')
            CreateHairandBeardPage()
            HairandBeardPage:RouteTo()


            table.insert(SelectedAttributes, key)
            if SelectedAttributes[key .. 'Category'] == nil then
                CategoryElement = HairandBeardPage:RegisterElement('slider', {
                    label = value,
                    start = 1,
                    min = 1,
                    max = #HairandBeards[Gender][key],
                    steps = 1
                }, function(data)
                    MainComponent = data.value
                    if VariantComponent == nil then
                        VariantComponent = 1
                    end
                    if MainComponent > 0 then
                        SelectedAttributes[key .. 'Variant'] = SelectedAttributes[key .. 'Variant']:update({
                            label = key .. ' variant',
                            max = #HairandBeards[Gender][key][MainComponent], --#v.CategoryData[inputvalue],
                        })
                        AddComponent(PlayerPedId(), HairandBeards[Gender][key][MainComponent][VariantComponent].hash, key)
                        SelectedAttributeElements[key] = HairandBeards[Gender][key][MainComponent][1].hash

                        TextElement = TextElement:update({
                            value = HairandBeards[Gender][key][MainComponent][VariantComponent].color
                        })
                    else
                        Citizen.InvokeNative(0xDF631E4BCE1B1FC4, PlayerPedId(), ActiveCatagory, 0, 0)
                        Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
                    end
                end)

                VariantElement = HairandBeardPage:RegisterElement('slider', {
                    label = key .. ' variant',
                    start = 1,
                    min = 1,
                    max = 5, --#v.CategoryData[inputvalue],
                    steps = 1
                }, function(data)
                    VariantComponent = data.value
                    if VariantComponent > 0 then
                        SelectedAttributes[key .. 'Variant'] = SelectedAttributes[key .. 'Variant']:update({
                            label = key .. ' variant',
                            max = #HairandBeards[Gender][key][MainComponent], --#v.CategoryData[inputvalue],
                        })

                        AddComponent(PlayerPedId(), HairandBeards[Gender][key][MainComponent][VariantComponent].hash, key)
                        TextElement = TextElement:update({
                            value = HairandBeards[Gender][key][MainComponent][VariantComponent].color
                        })
                    else
                        Citizen.InvokeNative(0xDF631E4BCE1B1FC4, PlayerPedId(), ActiveCatagory, 0, 0)
                        Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
                    end
                end)

                -- Store your elements with unique keys so that we can easily retrieve these later when data needs to be updated. We are appenting strings so that it stays unique.
                SelectedAttributes[key .. 'Category'] = CategoryElement
                SelectedAttributes[key .. 'Variant'] = VariantElement
                CategoryElement = CategoryElement:update({
                    label = key,
                    max = #HairandBeards[Gender][key], --#v.CategoryData[inputvalue],
                })

                VariantElement = VariantElement:update({
                    label = key .. ' variant',
                    max = #HairandBeards[Gender][key], --#v.CategoryData[inputvalue],
                })
            end
            TextElement = HairandBeardPage:RegisterElement('textdisplay', {
                value = 'test',
                style = {}
            })
        end)
    end
end

function CreateHairandBeardPage()
    HairandBeardPage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    HairandBeardPage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    HairandBeardPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        MainAppearanceMenu:RouteTo()
    end)
    HairandBeardPage:RegisterElement('bottomline', {
        slot = "header",
        style = {

        }
    })
    HairandBeardPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        HairCategoryPage:RouteTo()
        CategoryElement:unRegister()
        VariantElement:unRegister()
        TextElement:unRegister()
        for k, v in pairs(HairandBeards[Gender]) do
            SelectedAttributes[k .. 'Category'] = nil
        end
    end)
end

RegisterNetEvent('FeatherMenu:closed', function(data)
    MenuOpened = false
    Header1:unRegister()
end)


function TableToString(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. TableToString(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

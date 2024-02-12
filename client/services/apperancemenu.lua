-- TODO: REMOVE ALL THIS STUFF AS MENUAPI/REDEMTP_MENU_BASE WILL NOT BE NEEDED.
FeatherMenu = exports['feather-menu'].initiate()

RegisterCommand('brow', function()
    ChangeOverlay("eyebrows", tonumber(1), tonumber(1), 0, 0, 1, 1.0, 0, tonumber(1), tonumber(1), tonumber(0), tonumber(0), tonumber(1), tonumber(1.0),Albedo)

end)


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
FaceActive = nil
SelectedAttributes = {}        -- This can keep track of what was selected data wise
SelectedAttributeElements = {} --This table keeps track of your clothing elements

MainAppearanceMenu:RegisterElement('header', {
    value = 'Appearance Menu',
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
    SwitchCam(Config.CameraCoords.creation.x - 0.25, Config.CameraCoords.creation.y,
        Config.CameraCoords.creation.z + 0.7, Config.CameraCoords.creation.h, 0.0)
    CreateHairPage()
    HairCategoryPage:RouteTo()
end)

MainAppearanceMenu:RegisterElement('button', {
    label = 'Facial Features',
    style = {
    }
}, function()
    ChangeOverlay("eyebrows", 1, 1, 1, 0, 0, 1.0, 0, 1, 1, 0, 0, 1, 1.0,Albedo)

    FacialMenu = MyMenu:RegisterPage('face:page')
    SwitchCam(Config.CameraCoords.creation.x - 0.25, Config.CameraCoords.creation.y,
        Config.CameraCoords.creation.z + 0.7, Config.CameraCoords.creation.h, 0.0)
    FacialFeaturesPage()
    FacialMenu:RouteTo()
end)


MainAppearanceMenu:RegisterElement('button', {
    label = "Save Appearance",
    style = {
    }
}, function()
    TriggerServerEvent('feather-character:UpdateAttributeDB', SelectedAttributeElements)
end)

MainAppearanceMenu:RegisterElement('button', {
    label = "Go Back",
    style = {
    },
}, function()
    MainCharacterPage:RouteTo()
end)

function FacialFeaturesPage()
    if FaceActive == nil then
        FacialMenu:RegisterElement('header', {
            value = 'Facial Features',
            slot = "header",
            style = {}
        })
        FacialMenu:RegisterElement('subheader', {
            value = "First Page",
            slot = "header",
            style = {}
        })
        for key, v in pairs(FeatureNames) do
            FaceButton = FacialMenu:RegisterElement('button', {
                label = key,
                style = {
                }
            }, function()
                if key == 'Eyes and Brows' then
                    EyesPage = MyMenu:RegisterPage('eyes:page')

                    EyesAnim("mood_normal_eyes_wide")
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
        FacialMenu:RegisterElement('button', {
            label = "Go Back",
            style = {
            },
        }, function()
            SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y,
                Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
            MainAppearanceMenu:RouteTo()
        end)
    end
end

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
        StopAnimTask(PlayerPedId(), 'FACE_HUMAN@GEN_MALE@BASE', 'mood_normal_eyes_wide', true)
        MainAppearanceMenu:RouteTo()
    end)

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
    EyesPage:RegisterElement('button', {
        label = "Eyelid Width and Height",
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
    EyesPage:RegisterElement('button', {
        label = "Eyebrows",
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
        min = 1,
        max = #Features.Eyes[Gender],
        steps = 1,
    }, function(data)
        AddComponent(PlayerPedId(), Features.Eyes[Gender][data.value], nil)
    end)
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
        SetCharExpression(PlayerPedId(), 60996, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 56827, tonumber(data.value.y))
        UpdatePedVariation(PlayerPedId())
    end)
end

function CreateEyebrowPage()

end

function CreateEyeDistance()
    EyeGrid2 = EyesPage:RegisterElement('gridslider', {
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
    EyebrowPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()

    end)

    EyebrowPage:RegisterElement('arrows', {
        label = "Visibility",
        start = 0.0,
        options = {
            0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0
        },

    }, function(data)
        -- This gets triggered whenever the arrow selected value changes

        print(TableToString(data.value))
    end)

    EyebrowPage:RegisterElement('slider', {
        label = "Variant",
        start = 1,
        min = 0,
        max = 100,
        steps = 1,
        -- persist = false,
        -- sound = {
        --     action = "SELECT",
        --     soundset = "RDRO_Character_Creator_Sounds"
        -- },
    }, function(data)
        print(TableToString(data.value))
    end)



    EyebrowGrid = EyesPage:RegisterElement('gridslider', {
        leftlabel = 'Eyebrow Width -',
        rightlabel = 'Eyebrow Width +',
        toplabel = 'Eyebrow Height +',
        bottomlabel = 'Eyebrow Height -',
        maxx = 1,
        maxy = 1,
        arrowsteps = 10,
        precision = 1
    }, function(data)
        SetCharExpression(PlayerPedId(), 42318, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 53862, tonumber(data.value.y))
        UpdatePedVariation(PlayerPedId())
    end)
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

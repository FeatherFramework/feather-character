-- TODO: REMOVE ALL THIS STUFF AS MENUAPI/REDEMTP_MENU_BASE WILL NOT BE NEEDED.
CamZ = Config.CameraCoords.creation.z + 0.5
local gender = GetGender()
ActiveTexture, ActiveColor1, ActiveColor2, ActiveColor3, ActiveOpacity, ActiveVariant = {}, {}, {}, {}, {},{}

MainAppearanceMenu = MyMenu:RegisterPage('appearance:page')
FaceActive = nil
SelectedAttributes = {} -- This can keep track of what was selected data wise
SelectedOverlayElements = {}

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
MainAppearanceMenu:RegisterElement('bottomline', {
    slot = "content",
})

HeritageSlider = MainAppearanceMenu:RegisterElement('slider', {
    label = "Heritage",
    start = 1,
    min = 1,
    max = #CharacterConfig.General.DefaultChar[gender],
    steps = 1,
}, function(data)
    Race = data.value
    local Head = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Heads[1])
    local Body = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Body[1])
    local Legs = tonumber("0x" .. CharacterConfig.General.DefaultChar[gender][Race].Legs[1])
    local Albedo = tonumber(CharacterConfig.General.DefaultChar[gender][Race].HeadTexture[1])
    SelectedAttributeElements['Albedo'] = { hash = Albedo }

    -- This gets triggered whenever the sliders selected value changes
    AddComponent(PlayerPedId(), Head, nil)
    AddComponent(PlayerPedId(), Body, nil)
    AddComponent(PlayerPedId(), Legs, nil)
    HeritageDisplay:update({
        value = CharacterConfig.General.DefaultChar[gender][Race].label,
    })
    HeadVariantSlider = HeadVariantSlider:update({
        value = 1,
    })
    BodyVariantSlider = BodyVariantSlider:update({
        value = 1,
    })
    LegVariantSlider = LegVariantSlider:update({
        value = 1,
    })
end)
HeritageDisplay = MainAppearanceMenu:RegisterElement('textdisplay', {
    value = "European",
    style = {}
})

HeadVariantSlider = MainAppearanceMenu:RegisterElement('slider', {
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

    -- This gets triggered whenever the sliders selected value changes
end)
BodyVariantSlider = MainAppearanceMenu:RegisterElement('slider', {
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

    -- This gets triggered whenever the sliders selected value changes
end)
LegVariantSlider = MainAppearanceMenu:RegisterElement('slider', {
    label = "Leg Variations",
    start = 1,
    min = 1,
    max = #CharacterConfig.General.DefaultChar[gender][1].Legs,
    steps = 1,
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

    -- This gets triggered whenever the sliders selected value changes
end)

MainAppearanceMenu:RegisterElement('button', {
    label = 'Hair',
    style = {
    }
}, function()
    HairCategoryPage = MyMenu:RegisterPage('hair:page')
    SwitchCam(Config.CameraCoords.creation.x - 0.25, Config.CameraCoords.creation.y,
        Config.CameraCoords.creation.z + 0.7, Config.CameraCoords.creation.h, 0.0)
    CreateHairPage()
    HairCategoryPage:RouteTo()
end)

MainAppearanceMenu:RegisterElement('button', {
    label = 'Facial Adjustments',
    style = {
    }
}, function()
    FaceAdjMenu = MyMenu:RegisterPage('faceadj:page')
    SwitchCam(Config.CameraCoords.creation.x - 0.25, Config.CameraCoords.creation.y,
        Config.CameraCoords.creation.z + 0.7, Config.CameraCoords.creation.h, 0.0)
    FacialAdjustmentPage()
    FaceAdjMenu:RouteTo()
end)


MainAppearanceMenu:RegisterElement('button', {
    label = 'Facial Features',
    style = {
    }
}, function()
    FaceFeatMenu = MyMenu:RegisterPage('facefeat:page')
    SwitchCam(Config.CameraCoords.creation.x - 0.25, Config.CameraCoords.creation.y,
        Config.CameraCoords.creation.z + 0.7, Config.CameraCoords.creation.h, 0.0)
    FacialFeatPage()
    FaceFeatMenu:RouteTo()
end)

MainAppearanceMenu:RegisterElement('bottomline', {
    slot = "footer",
    style = {

    }
})

MainAppearanceMenu:RegisterElement('button', {
    label = "Go Back",
    slot = 'footer',

    style = {
    },
}, function()
    SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
        Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
    MainCharacterPage:RouteTo()
end)


function FacialFeatPage()
    FaceFeatMenu:RegisterElement('header', {
        value = 'Facial Features',
        slot = "header",
        style = {}
    })
    FaceFeatMenu:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    for k, v in pairs(FaceFeatures.Features) do
        FaceFeatMenu:RegisterElement('button', {
            label = k,
            style = {
            },
        }, function()
            FeatSubMenu = MyMenu:RegisterPage('featsub:page')
            FeatSubPage(FeatSubMenu, v)
            FeatSubMenu:RouteTo()
        end)
    end
    FaceFeatMenu:RegisterElement('bottomline', {
        slot = "footer",
        style = {

        }
    })
    FaceFeatMenu:RegisterElement('button', {
        label = "Go Back",
        slot = 'footer',

        style = {
        },
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
            Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        MainAppearanceMenu:RouteTo()
    end)
end

function FeatSubPage(ActivePage, selected)
    if not SelectedOverlayElements[selected] then
        SelectedOverlayElements[selected] = {
            ['textureId'] = 1,
            ['opacity'] = 1.0,
            ['variant'] = 1,
            ['color1'] = 1,
            ['color2'] = 1,
            ['color3'] = 1,
        }
    end
    SetDefaultValues(selected)
    ActivePage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    ActivePage:RegisterElement('subheader', {
        value = "Choose your " .. selected .. " Options",
        slot = "header",
        style = {}
    })
    ActivePage:RegisterElement('bottomline', {
        slot = "content",
        style = {

        }
    })

    ActivePage:RegisterElement('pagearrows', {
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
    ActivePage:RegisterElement('pagearrows', {
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
    ActivePage:RegisterElement('slider', {
        label = selected .. ' Opacity',
        start = 0,
        min = 0,
        max = 1,
        steps = 0.1,

    }, function(data)
        if data.value == 1 then
            data.value = 1.0
        end
        if data.value > 0 then
        ActiveOpacity[selected] = data.value
        -- This gets triggered whenever the sliders selected value changes
        ChangeOverlay(PlayerPedId(),selected, 1, ActiveTexture[selected], 0, 0, 1, 1.0, 0, 1, 0, 0, 0, 1,  ActiveOpacity[selected],
            SelectedAttributeElements['Albedo'].hash)
        else
            ChangeOverlay(PlayerPedId(),selected, 0, ActiveTexture[selected], 0, 0, 1, 1.0, 0, 1,
                0, 0, 0, ActiveVariant[selected], ActiveOpacity[selected],
                SelectedAttributeElements['Albedo'].hash)
        end
        SelectedOverlayElements[selected]["opacity"] = ActiveOpacity[selected]
    end)
    ActivePage:RegisterElement('slider', {
        label = selected .. ' Texture',
        start = 0,
        min = 0,
        max = #overlays_info[selected],
        steps = 1,

    }, function(data)
        ActiveTexture[selected] = data.value
        if data.value > 0 then
            ChangeOverlay(PlayerPedId(),selected, 1, ActiveTexture[selected], 0, 0, 1, 1.0, 0, 1, 0, 0, 0,
                ActiveVariant[selected], ActiveOpacity[selected],
                SelectedAttributeElements['Albedo'].hash)
        else
            ChangeOverlay(PlayerPedId(),selected, 0, ActiveTexture[selected], 0, 0, 1, 1.0, 0, 1,
                0, 0, 0, ActiveVariant[selected], ActiveOpacity[selected],
                SelectedAttributeElements['Albedo'].hash)
        end
        SelectedOverlayElements[selected]['textureId'] = ActiveTexture[selected]
        -- This gets triggered whenever the sliders selected value changes
    end)
    ActivePage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    ActivePage:RegisterElement('bottomline', {
        slot = "footer",
        style = {

        }
    })
    ActivePage:RegisterElement('button', {
        label = "Go Back",
        slot = 'footer',

        style = {
        },
    }, function()
        FaceFeatMenu:RouteTo()
    end)
end

function FacialAdjustmentPage()
    if FaceActive == nil then
        FaceAdjMenu:RegisterElement('header', {
            value = 'Facial Features',
            slot = "header",
            style = {}
        })
        FaceAdjMenu:RegisterElement('subheader', {
            value = "First Page",
            slot = "header",
            style = {}
        })
        for key, v in pairs(FaceFeatures.Adjustments) do
            FaceButton = FaceAdjMenu:RegisterElement('button', {
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
                if key == 'Nose' then
                    NosePage = MyMenu:RegisterPage('nose:page')
                    CreateNosePage()
                    NosePage:RouteTo()
                end
            end)
        end

        FaceAdjMenu:RegisterElement('bottomline', {
            slot = "footer",
            style = {

            }
        })
        FaceAdjMenu:RegisterElement('button', {
            label = "Go Back",
            slot = 'footer',

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
    EyesPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {

        }
    })
    EyesPage:RegisterElement('button', {
        label = "Go Back",
        slot = 'footer',

        style = {
        },
    }, function()
        StopAnimTask(PlayerPedId(), 'FACE_HUMAN@GEN_MALE@BASE', 'mood_normal_eyes_wide', true)
        MainAppearanceMenu:RouteTo()
    end)
    EyesPage:RegisterElement('pagearrows', {
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
    EyesPage:RegisterElement('pagearrows', {
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
    EyesPage:RegisterElement('button', {
        label = "Eye Height and Depth",
        style = {
        },
    }, function()
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
            SelectedAttributeElements['EyeDepth'] = { value = tonumber(data.value.x), hash = 60996 }
            SelectedAttributeElements['EyeHeight'] = { value = tonumber(data.value.y), hash = 56827 }

            UpdatePedVariation(PlayerPedId())
        end)
        EyesPage:RouteTo()
    end)
    EyesPage:RegisterElement('button', {
        label = "Eye Distance and Angle",
        style = {
        },
    }, function()
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
            SelectedAttributeElements['EyeDistance'] = { value = tonumber(data.value.x), hash = 42318 }
            SelectedAttributeElements['EyeAngle'] = { value = tonumber(data.value.y), hash = 53862 }
            UpdatePedVariation(PlayerPedId())
        end)
        EyesPage:RouteTo()
    end)
    EyesPage:RegisterElement('button', {
        label = "Eyelid Width and Height",
        style = {
        },
    }, function()
        EyeGrid3 = EyesPage:RegisterElement('gridslider', {
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
        EyesPage:RouteTo()
    end)
    EyesPage:RegisterElement('button', {
        label = "Eyebrows",
        style = {
        },
    }, function()
        EyebrowPage = MyMenu:RegisterPage('eyebrows:page')
        CreateEyebrowPage()
        EyebrowPage:RouteTo()
    end)
    EyesPage:RegisterElement('slider', {
        label = "Eye Color",
        start = 0,
        min = 1,
        max = #FeaturesEyes[gender],
        steps = 1,
    }, function(data)
        AddComponent(PlayerPedId(), FeaturesEyes[gender][data.value], nil)
        SelectedAttributeElements['EyeColor'] = { hash = FeaturesEyes[gender][data.value] }
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
    CheekPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {

        }
    })
    CheekPage:RegisterElement('button', {
        label = "Go Back",
        slot = 'footer',

        style = {
        },
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y,
            Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        MainAppearanceMenu:RouteTo()
    end)
    CheekPage:RegisterElement('pagearrows', {
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
    CheekPage:RegisterElement('pagearrows', {
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
    CheekGrid1 = CheekPage:RegisterElement('gridslider', {
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
    CheekGrid2 = CheekPage:RegisterElement('gridslider', {
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
    ChinPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {

        }
    })
    ChinPage:RegisterElement('button', {
        label = "Go Back",
        slot = 'footer',

        style = {
        },
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y,
            Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        MainAppearanceMenu:RouteTo()
    end)
    ChinPage:RegisterElement('pagearrows', {
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
    ChinPage:RegisterElement('pagearrows', {
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
    ChinGrid1 = ChinPage:RegisterElement('gridslider', {
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
    ChinGrid2 = ChinPage:RegisterElement('gridslider', {
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
end

function CreateEyebrowPage()
    EyebrowOpacity = 1.0
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
    EyebrowPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {

        }
    })
    EyebrowPage:RegisterElement('button', {
        label = "Go Back",
        slot = 'footer',

        style = {
        },
    }, function()
        StopAnimTask(PlayerPedId(), 'FACE_HUMAN@GEN_MALE@BASE', 'mood_normal_eyes_wide', true)
        EyesPage:RouteTo()
    end)
    EyebrowPage:RegisterElement('pagearrows', {
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
    EyebrowPage:RegisterElement('pagearrows', {
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
    EyebrowPage:RegisterElement('arrows', {
        label = "Opacity",
        start = 11,
        options = {
            0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0
        },

    }, function(data)
        -- This gets triggered whenever the arrow selected value changes
        EyebrowOpacity = data.value
        if EyebrowOpacity == 1 then
            EyebrowOpacity = 1.0
        end
        ChangeOverlay(PlayerPedId(),'eyebrows', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, EyebrowOpacity, Albedo)
        SelectedAttributeElements['BrowOpacity'] = { value = data.value }
    end)

    EyebrowPage:RegisterElement('slider', {
        label = "Variant",
        start = 1,
        min = 0,
        max = #overlays_info['eyebrows'],
        steps = 1,

    }, function(data)
        ChangeOverlay(PlayerPedId(),'eyebrows', 1, data.value, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, EyebrowOpacity, Albedo)
        SelectedAttributeElements['EyebrowVariant'] = { value = data.value }
    end)

    EyebrowGrid = EyebrowPage:RegisterElement('gridslider', {
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
    EarPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {

        }
    })
    EarPage:RegisterElement('button', {
        label = "Go Back",
        slot = 'footer',

        style = {
        },
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y,
            Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        MainAppearanceMenu:RouteTo()
    end)
    EarPage:RegisterElement('pagearrows', {
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
    EarPage:RegisterElement('pagearrows', {
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

    EarGrid1 = EarPage:RegisterElement('gridslider', {
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
    EarGrid2 = EarPage:RegisterElement('gridslider', {
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
    JawPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {

        }
    })
    JawPage:RegisterElement('button', {
        label = "Go Back",
        slot = 'footer',

        style = {
        },
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y,
            Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        MainAppearanceMenu:RouteTo()
    end)
    JawPage:RegisterElement('pagearrows', {
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
    JawPage:RegisterElement('pagearrows', {
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
    JawGrid1 = JawPage:RegisterElement('gridslider', {
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
    JawGrid2 = JawPage:RegisterElement('gridslider', {
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
    MouthPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {

        }
    })
    MouthPage:RegisterElement('button', {
        label = "Go Back",
        slot = 'footer',

        style = {
        },
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y,
            Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        MainAppearanceMenu:RouteTo()
    end)
    MouthPage:RegisterElement('pagearrows', {
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
    MouthPage:RegisterElement('pagearrows', {
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
    MouthPage:RegisterElement('button', {
        label = "Mouth Placement",
        style = {
        },
    }, function()
        CreateMouthPlacement()
        MouthPage:RouteTo()
    end)
    MouthPage:RegisterElement('button', {
        label = "Mouth Fine Tuning",
        style = {
        },
    }, function()
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
        UpperLip = true
        CreateUpperLipTuning()
        MouthPage:RouteTo()
    end)
    MouthPage:RegisterElement('button', {
        label = "Lower Lip",
        style = {
        },
    }, function()
        LowerLip = true
        CreateLowerLipTuning()
        MouthPage:RouteTo()
    end)
end

function CreateNosePage()
    NosePage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    NosePage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    NosePage:RegisterElement('bottomline', {
        slot = "footer",
        style = {

        }
    })
    NosePage:RegisterElement('button', {
        label = "Go Back",
        slot = 'footer',

        style = {
        },
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y,
            Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        MainAppearanceMenu:RouteTo()
    end)

    NosePage:RegisterElement('pagearrows', {
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
    NosePage:RegisterElement('pagearrows', {
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

    NosePage:RegisterElement('button', {
        label = "Nose Width/Height and Curve/Angle",
        style = {
        },
    }, function()
        CreateNoseWidthHeight()
        NosePage:RouteTo()
    end)
    NosePage:RegisterElement('button', {
        label = "Nose Size and Nostrils",
        style = {
        },
    }, function()
        CreateNoseSize()
        NosePage:RouteTo()
    end)
end

function CreateNoseWidthHeight()
    NoseGrid1 = NosePage:RegisterElement('gridslider', {
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
    NoseGrid2 = NosePage:RegisterElement('gridslider', {
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
end

function CreateNoseSize()
    NoseGrid3 = NosePage:RegisterElement('gridslider', {
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
end

--Mouth Tuning
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
        SelectedAttributeElements['UpLipWidth'] = { value = tonumber(data.value.x), hash = 0x91C1 }
        SelectedAttributeElements['UpLipHeight'] = { value = tonumber(data.value.y), hash = 0x1A00 }
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
        SelectedAttributeElements['UpLipDepth'] = { value = tonumber(data.value.x), hash = 0xC375 }
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
        SelectedAttributeElements['LowLipWidth'] = { value = tonumber(data.value.x), hash = 0xB0B0 }
        SelectedAttributeElements['LowLipHeight'] = { value = tonumber(data.value.y), hash = 0xBB4D }
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
        SelectedAttributeElements['LowLipDepth'] = { value = tonumber(data.value.x), hash = 0x5D16 }
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
        SelectedAttributeElements['MouthWidth'] = { value = tonumber(data.value.x), hash = 61541 }
        SelectedAttributeElements['MouthDepth'] = { value = tonumber(data.value.y), hash = 43625 }
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
        SetCharExpression(PlayerPedId(), 31427, tonumber(data.value.x))
        SetCharExpression(PlayerPedId(), 16653, tonumber(data.value.y))
        SelectedAttributeElements['MouthXPos'] = { value = tonumber(data.value.x), hash = 31427 }
        SelectedAttributeElements['MouthYPos'] = { value = tonumber(data.value.y), hash = 16653 }
    end)
end

--Hair Page
function CreateHairPage()
    gender = GetGender()

    HairandBeardPage = MyMenu:RegisterPage('hairandbeard:page')

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
    HairCategoryPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {

        }
    })
    HairCategoryPage:RegisterElement('button', {
        label = "Go Back",
        slot = 'footer',

        style = {
        },
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y,
            Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        MainAppearanceMenu:RouteTo()
    end)


    for key, v in pairs(HairandBeards[gender]) do
        HairCategoryPage:RegisterElement('button', {
            label = key,
            style = {
            }
        }, function()
            CreateHairandBeardPage(key)
            MainComponent = 0
            HairandBeardPage:RouteTo()
            table.insert(SelectedAttributes, key)
            --if SelectedAttributes[key .. 'Category'] == nil then
            CategoryElement = HairandBeardPage:RegisterElement('slider', {
                label = value,
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
                    SelectedAttributes[key .. 'Variant'] = SelectedAttributes[key .. 'Variant']:update({
                        label = key .. ' variant',
                        max = #HairandBeards[gender][key][MainComponent], --#v.CategoryData[inputvalue],
                    })
                    AddComponent(PlayerPedId(), HairandBeards[gender][key][MainComponent][VariantComponent].hash, key)
                    local type = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                    ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8,
                        HairandBeards[gender][key][MainComponent][1].hash, type, true)
                    SelectedAttributeElements[key .. 'Category'] = {
                        hash = HairandBeards[gender][key][MainComponent][1]
                            .hash
                    }
                    SelectedAttributeElements[key .. 'Variant'] = {
                        hash = HairandBeards[gender][key][MainComponent][1]
                            .hash
                    }

                    TextElement = TextElement:update({
                        value = HairandBeards[gender][key][MainComponent][VariantComponent].color
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
                if VariantComponent > 0 and MainComponent > 0 then
                    SelectedAttributes[key .. 'Variant'] = SelectedAttributes[key .. 'Variant']:update({
                        label = key .. ' variant',
                        max = #HairandBeards[gender][key][MainComponent], --#v.CategoryData[inputvalue],
                    })

                    AddComponent(PlayerPedId(), HairandBeards[gender][key][MainComponent][VariantComponent].hash, key)
                    local type = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                    ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8,
                        HairandBeards[gender][key][MainComponent][VariantComponent].hash, type, true)
                    SelectedAttributeElements[key .. 'Variant'] = {
                        hash = HairandBeards[gender][key][MainComponent]
                            [VariantComponent].hash
                    }

                    TextElement = TextElement:update({
                        value = HairandBeards[gender][key][MainComponent][VariantComponent].color
                    })
                end
            end)

            -- Store your elements with unique keys so that we can easily retrieve these later when data needs to be updated. We are appenting strings so that it stays unique.


            SelectedAttributes[key .. 'Category'] = CategoryElement
            SelectedAttributes[key .. 'Variant'] = VariantElement
            CategoryElement = CategoryElement:update({
                label = key,
                max = #HairandBeards[gender][key], --#v.CategoryData[inputvalue],
            })

            VariantElement = VariantElement:update({
                label = key .. ' variant',
                max = #HairandBeards[gender][key], --#v.CategoryData[inputvalue],
            })
            --end
            TextElement = HairandBeardPage:RegisterElement('textdisplay', {
                value = 'test',
                style = {}
            })
        end)
    end
end

function CreateHairandBeardPage(choice)
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
    HairandBeardPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {

        }
    })
    HairandBeardPage:RegisterElement('button', {
        label = "Go Back",
        slot = 'footer',
        style = {
        },
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y,
            Config.CameraCoords.creation.z, Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        MainAppearanceMenu:RouteTo()
    end)
    HairandBeardPage:RegisterElement('pagearrows', {
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
    HairandBeardPage:RegisterElement('pagearrows', {
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
    if choice == 'beard' then
        if gender == "Male" then
            HairandBeardPage:RegisterElement("toggle", {
                label = "Beard Stuble",
                start = false,

            }, function(data)
                if data.value == true then
                    ChangeOverlay(PlayerPedId(),'beardstabble', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, 1.0, Albedo)
                else
                    ChangeOverlay(PlayerPedId(),'beardstabble', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, 0.0, Albedo)
                end
                -- This gets triggered whenever the toggle value changes
            end)
            HairandBeardPage:RegisterElement('arrows', {
                label = "Opacity",
                start = 11,
                options = {
                    0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0
                },
            }, function(data)
                -- This gets triggered whenever the arrow selected value changes
                BeardOpacity = data.value
                if BeardOpacity == 1 then
                    BeardOpacity = 1.0
                end
                ChangeOverlay(PlayerPedId(),'beardstabble', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, BeardOpacity, Albedo)
            end)
        end
    end
    if choice == 'hair' then
        hairacc = 'Hair Accessories'
        if gender == "Female" then
            CategoryElement = HairandBeardPage:RegisterElement('slider', {
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
                    SelectedAttributes[hairacc .. 'Variant'] = SelectedAttributes[hairacc .. 'Variant']:update({
                        label = hairacc .. ' variant',
                        max = #CharacterConfig.Clothing.Clothes[gender].Accessories.HairAccesories.CategoryData
                            [MainHairComponent], --#v.CategoryData[inputvalue],
                    })
                    AddComponent(PlayerPedId(), HairPiece[MainHairComponent][VariantComponent].hash, hairacc)
                    SelectedAttributeElements[hairacc] = CharacterConfig.Clothing.Clothes[gender].Accessories
                        .HairAccesories.CategoryData[MainHairComponent][1].hash
                    local type = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                    ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8, HairPiece[MainHairComponent][1].hash, type,
                        true)
                    VariantElement = VariantElement:update({
                        label = hairacc .. ' variant',
                        max = #HairPiece[MainHairComponent], --#v.CategoryData[inputvalue],
                    })
                else
                    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, PlayerPedId(), ActiveCatagory, 0, 0)
                    Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
                end
            end)
            VariantElement = HairandBeardPage:RegisterElement('slider', {
                label = "Hair Accessories Variants",
                start = 1,
                min = 1,
                max = 10,
                steps = 1,

            }, function(data)
                HairPiece = CharacterConfig.Clothing.Clothes[gender].Accessories.HairAccesories.CategoryData
                    [MainHairComponent]
                AddComponent(PlayerPedId(), HairPiece[data.value].hash, nil)
            end)
            SelectedAttributes[hairacc .. 'Category'] = CategoryElement
            SelectedAttributes[hairacc .. 'Variant'] = VariantElement
        end
    end
end

RegisterNetEvent('FeatherMenu:closed', function(data)
    MenuOpened = false
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

-- client/creationmenu/facialadjustments/eyes_brows.lua

function OpenEyesAndBrowsPage(mainAppearanceMenu, gender)
    local eyesPage = CharacterMenu:RegisterPage('feather-character:EyesPage')

    eyesPage:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "eyebrowPage"),
        slot = "header",
        style = {}
    })

    eyesPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "eyeHeightAndDepth"),
        style = {}
    }, function()
        local eyeHeightAndDepthPage = CharacterMenu:RegisterPage('feather-character:EyeHeightAndDepthPage')

        eyeHeightAndDepthPage:RegisterElement('header', {
            value = FeatherCore.Locale.translate(0, "eyeHeightAndDepth"),
            slot = "header",
            style = {}
        })
        local EyeGrid = eyeHeightAndDepthPage:RegisterElement('gridslider', {
            leftlabel = FeatherCore.Locale.translate(0, "eyeDepthMinus"),
            rightlabel = FeatherCore.Locale.translate(0, "eyeDepthPlus"),
            toplabel = FeatherCore.Locale.translate(0, "eyeHeightPlus"),
            bottomlabel = FeatherCore.Locale.translate(0, "eyeHeightMinus"),
            maxx = 1,
            maxy = 1,
            arrowsteps = 10,
            precision = 1
        }, function(data)
            SetCharExpression(PlayerPedId(), 60996, tonumber(data.value.x))
            SetCharExpression(PlayerPedId(), 56827, tonumber(data.value.y))
            SelectedAttributeElements['EyeDepth']  = { value = tonumber(data.value.x), hash = 60996 }
            SelectedAttributeElements['EyeHeight'] = { value = tonumber(data.value.y), hash = 56827 }
            UpdatePedVariation(PlayerPedId())
        end)
        eyeHeightAndDepthPage:RegisterElement('line', {
            slot = "footer",
            style = {}
        })

        eyeHeightAndDepthPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "goBack"),
            slot = 'footer',
            style = {}
        }, function()
            StopAnimTask(PlayerPedId(), 'FACE_HUMAN@GEN_MALE@BASE', 'mood_normal_eyes_wide', true)
            eyesPage:RouteTo()
        end)

        eyeHeightAndDepthPage:RegisterElement('bottomline', {
            slot = "footer",
            style = {}
        })
        eyeHeightAndDepthPage:RegisterElement('pagearrows', {
            slot = 'footer',
            total = FeatherCore.Locale.translate(0, "moveCamUp"),
            current = FeatherCore.Locale.translate(0, "moveCamDown"),
            style = {}
        }, function(data)
            if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
            SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
        end)

        eyeHeightAndDepthPage:RegisterElement('pagearrows', {
            slot = 'footer',
            total = FeatherCore.Locale.translate(0, "rotateRight"),
            current = FeatherCore.Locale.translate(0, "rotateLeft"),
            style = {}
        }, function(data)
            local heading = GetEntityHeading(PlayerPedId())
            if data.value == 'forward' then heading = heading + 10.0 else heading = heading - 10.0 end
            SetEntityHeading(PlayerPedId(), heading)
        end)

        eyeHeightAndDepthPage:RouteTo()
    end)

    eyesPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "eyeDistAndAngle"),
        style = {}
    }, function()
        local eyeDistAndAnglePage = CharacterMenu:RegisterPage('feather-character:EyeDistAndAnglePage')
        eyeDistAndAnglePage:RegisterElement('header', {
            value = FeatherCore.Locale.translate(0, "eyeDistAndAngle"),
            slot = "header",
            style = {}
        })
        local EyeGrid2 = eyeDistAndAnglePage:RegisterElement('gridslider', {
            leftlabel = FeatherCore.Locale.translate(0, "eyeDistPlus"),
            rightlabel = FeatherCore.Locale.translate(0, "eyeDistMinus"),
            toplabel = FeatherCore.Locale.translate(0, "eyeAnglePlus"),
            bottomlabel = FeatherCore.Locale.translate(0, "eyeAngleMinus"),
            maxx = 1,
            maxy = 1,
            arrowsteps = 10,
            precision = 1
        }, function(data)
            SetCharExpression(PlayerPedId(), 42318, tonumber(data.value.x))
            SetCharExpression(PlayerPedId(), 53862, tonumber(data.value.y))
            SelectedAttributeElements['EyeDistance'] = { value = tonumber(data.value.x), hash = 42318 }
            SelectedAttributeElements['EyeAngle']    = { value = tonumber(data.value.y), hash = 53862 }
            UpdatePedVariation(PlayerPedId())
        end)

        eyeDistAndAnglePage:RegisterElement('line', {
            slot = "footer",
            style = {}
        })

        eyeDistAndAnglePage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "goBack"),
            slot = 'footer',
            style = {}
        }, function()
            StopAnimTask(PlayerPedId(), 'FACE_HUMAN@GEN_MALE@BASE', 'mood_normal_eyes_wide', true)
            eyesPage:RouteTo()
        end)
        eyeDistAndAnglePage:RegisterElement('bottomline', {
            slot = "footer",
            style = {}
        })
        eyeDistAndAnglePage:RegisterElement('pagearrows', {
            slot = 'footer',
            total = FeatherCore.Locale.translate(0, "moveCamUp"),
            current = FeatherCore.Locale.translate(0, "moveCamDown"),
            style = {}
        }, function(data)
            if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
            SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
        end)

        eyeDistAndAnglePage:RegisterElement('pagearrows', {
            slot = 'footer',
            total = FeatherCore.Locale.translate(0, "rotateRight"),
            current = FeatherCore.Locale.translate(0, "rotateLeft"),
            style = {}
        }, function(data)
            local heading = GetEntityHeading(PlayerPedId())
            if data.value == 'forward' then heading = heading + 10.0 else heading = heading - 10.0 end
            SetEntityHeading(PlayerPedId(), heading)
        end)
        eyeDistAndAnglePage:RouteTo()
    end)

    eyesPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "eyelidWidthAndHeight"),
        style = {}
    }, function()
        local eyeLidPage = CharacterMenu:RegisterPage('feather-character:EyelidPage')
        eyeLidPage:RegisterElement('header', {
            value = FeatherCore.Locale.translate(0, "eyelidWidthAndHeight"),
            slot = "header",
            style = {}
        })
        local EyeGrid3 = eyeLidPage:RegisterElement('gridslider', {
            leftlabel = FeatherCore.Locale.translate(0, "eyelidWidthMinus"),
            rightlabel = FeatherCore.Locale.translate(0, "eyelidWidthPlus"),
            toplabel = FeatherCore.Locale.translate(0, "eyelidHeightPlus"),
            bottomlabel = FeatherCore.Locale.translate(0, "eyelidHeightMinus"),
            maxx = 1,
            maxy = 1,
            arrowsteps = 10,
            precision = 1
        }, function(data)
            SetCharExpression(PlayerPedId(), 7019, tonumber(data.value.x))
            SetCharExpression(PlayerPedId(), 35627, tonumber(data.value.y))
            SelectedAttributeElements['EyelidWidth']  = { value = tonumber(data.value.x), hash = 7019 }
            SelectedAttributeElements['EyelidHeight'] = { value = tonumber(data.value.y), hash = 35627 }
            UpdatePedVariation(PlayerPedId())
        end)
        eyeLidPage:RegisterElement('line', {
            slot = "footer",
            style = {}
        })

        eyeLidPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "goBack"),
            slot = 'footer',
            style = {}
        }, function()
            StopAnimTask(PlayerPedId(), 'FACE_HUMAN@GEN_MALE@BASE', 'mood_normal_eyes_wide', true)
            eyesPage:RouteTo()
        end)

        eyeLidPage:RegisterElement('bottomline', {
            slot = "footer",
            style = {}
        })

        eyeLidPage:RegisterElement('pagearrows', {
            slot = 'footer',
            total = FeatherCore.Locale.translate(0, "moveCamUp"),
            current = FeatherCore.Locale.translate(0, "moveCamDown"),
            style = {}
        }, function(data)
            if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
            SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
        end)

        eyeLidPage:RegisterElement('pagearrows', {
            slot = 'footer',
            total = FeatherCore.Locale.translate(0, "rotateRight"),
            current = FeatherCore.Locale.translate(0, "rotateLeft"),
            style = {}
        }, function(data)
            local heading = GetEntityHeading(PlayerPedId())
            if data.value == 'forward' then heading = heading + 10.0 else heading = heading - 10.0 end
            SetEntityHeading(PlayerPedId(), heading)
        end)

        eyeLidPage:RouteTo()
    end)

    eyesPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "eyebrows"),
        style = {}
    }, function()
        local eyebrowPage = CharacterMenu:RegisterPage('feather-character:EyebrowPage')
        EyebrowOpacity = 1.0

        eyebrowPage:RegisterElement('header', {
            value = FeatherCore.Locale.translate(0, "eyebrows"),
            slot = "header",
            style = {}
        })

        eyebrowPage:RegisterElement('arrows', {
            label = FeatherCore.Locale.translate(0, "opacity"),
            start = 11,
            options = { 0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 }
        }, function(data)
            EyebrowOpacity = data.value
            if EyebrowOpacity == 1 then EyebrowOpacity = 1.0 end
            ChangeOverlay(PlayerPedId(), 'eyebrows', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, EyebrowOpacity, Albedo)
            SelectedAttributeElements['BrowOpacity'] = { value = data.value }
        end)

        eyebrowPage:RegisterElement('slider', {
            label = FeatherCore.Locale.translate(0, "variant"),
            start = 1,
            min = 0,
            max = #OverlayInfo['eyebrows'],
            steps = 1
        }, function(data)
            ChangeOverlay(PlayerPedId(), 'eyebrows', 1, data.value, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, EyebrowOpacity,
                Albedo)
            SelectedAttributeElements['EyebrowVariant'] = { value = data.value }
        end)

        local EyebrowGrid = eyebrowPage:RegisterElement('gridslider', {
            leftlabel = FeatherCore.Locale.translate(0, "eyebrowWidthMinus"),
            rightlabel = FeatherCore.Locale.translate(0, "eyebrowWidthPlus"),
            toplabel = FeatherCore.Locale.translate(0, "eyebrowHeightPlus"),
            bottomlabel = FeatherCore.Locale.translate(0, "eyebrowHeightMinus"),
            maxx = 1,
            maxy = 1,
            arrowsteps = 10,
            precision = 1
        }, function(data)
            SetCharExpression(PlayerPedId(), 0x2FF9, tonumber(data.value.x))
            SetCharExpression(PlayerPedId(), 0x3303, tonumber(data.value.y))
            SelectedAttributeElements['EyebrowWidth']  = { value = tonumber(data.value.x), hash = 0x2FF9 }
            SelectedAttributeElements['EyebrowHeight'] = { value = tonumber(data.value.y), hash = 0x3303 }
            UpdatePedVariation(PlayerPedId())
        end)
        eyebrowPage:RegisterElement('line', { slot = "footer", style = {} })

        eyebrowPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "goBack"),
            slot = 'footer',
            style = {}
        }, function()
            StopAnimTask(PlayerPedId(), 'FACE_HUMAN@GEN_MALE@BASE', 'mood_normal_eyes_wide', true)
            eyesPage:RouteTo()
        end)

        eyebrowPage:RegisterElement('bottomline', { slot = "footer", style = {} })

        eyebrowPage:RegisterElement('pagearrows', {
            slot = 'footer',
            total = FeatherCore.Locale.translate(0, "moveCamUp"),
            current = FeatherCore.Locale.translate(0, "moveCamDown"),
            style = {}
        }, function(data)
            if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
            SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
        end)

        eyebrowPage:RegisterElement('pagearrows', {
            slot = 'footer',
            total = FeatherCore.Locale.translate(0, "rotateRight"),
            current = FeatherCore.Locale.translate(0, "rotateLeft"),
            style = {}
        }, function(data)
            local heading = GetEntityHeading(PlayerPedId())
            if data.value == 'forward' then heading = heading + 10.0 else heading = heading - 10.0 end
            SetEntityHeading(PlayerPedId(), heading)
        end)

        eyebrowPage:RouteTo()
    end)

    eyesPage:RegisterElement('slider', {
        label = FeatherCore.Locale.translate(0, "eyeColor"),
        start = 0,
        min = 1,
        max = #FeaturesEyes[gender],
        steps = 1
    }, function(data)
        AddComponent(PlayerPedId(), FeaturesEyes[gender][data.value], nil)
        SelectedAttributeElements['EyeColor'] = { hash = FeaturesEyes[gender][data.value] }
    end)

    while not HasAnimDictLoaded("FACE_HUMAN@GEN_MALE@BASE") do
        RequestAnimDict("FACE_HUMAN@GEN_MALE@BASE"); Wait(50)
    end
    if not IsEntityPlayingAnim(PlayerPedId(), "FACE_HUMAN@GEN_MALE@BASE", "FACE_HUMAN@GEN_MALE@BASE", 3) then
        TaskPlayAnim(PlayerPedId(), "FACE_HUMAN@GEN_MALE@BASE", "FACE_HUMAN@GEN_MALE@BASE",
            1090519040, -4, -1, 17, 0, 0, 0, 0, 0, 0)
    end
    RemoveAnimDict("FACE_HUMAN@GEN_MALE@BASE")

    eyesPage:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    eyesPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "goBack"),
        slot = 'footer',
        style = {}
    }, function()
        StopAnimTask(PlayerPedId(), 'FACE_HUMAN@GEN_MALE@BASE', 'mood_normal_eyes_wide', true)
        OpenFaceAdjustmentsMenu(mainAppearanceMenu, gender)
    end)

    eyesPage:RegisterElement('bottomline', {
        slot = "footer",
        style = {}
    })

    eyesPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "moveCamUp"),
        current = FeatherCore.Locale.translate(0, "moveCamDown"),
        style = {}
    }, function(data)
        if data.value == 'forward' then CamZ = CamZ + 0.1 else CamZ = CamZ - 0.1 end
        SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
    end)

    eyesPage:RegisterElement('pagearrows', {
        slot = 'footer',
        total = FeatherCore.Locale.translate(0, "rotateRight"),
        current = FeatherCore.Locale.translate(0, "rotateLeft"),
        style = {}
    }, function(data)
        local heading = GetEntityHeading(PlayerPedId())
        if data.value == 'forward' then heading = heading + 10.0 else heading = heading - 10.0 end
        SetEntityHeading(PlayerPedId(), heading)
    end)
    eyesPage:RouteTo()
end

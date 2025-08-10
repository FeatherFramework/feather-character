function OpenFacialFeaturesMenu(mainAppearanceMenu, gender)
    local facialFeaturesPage = CharacterMenu:RegisterPage('feather-character:FacialFeaturesPage')

    facialFeaturesPage:RegisterElement('header', {
        value = FeatherCore.Locale.translate(0, "facialFeatures"),
        slot = "header",
        style = {}
    })

    for k, v in pairs(FaceFeatures.Features) do
        facialFeaturesPage:RegisterElement('button', {
            label = k,
            style = {}
        }, function()
            local featuresSubPage = CharacterMenu:RegisterPage('feather-character:featuresub:page')

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
                value = FeatherCore.Locale.translate(0, "facialFeaturesSubPage"),
                slot = "header",
                style = {}
            })
            featuresSubPage:RegisterElement('subheader', {
                value = FeatherCore.Locale.translate(0, "chooseYour") .. v .. FeatherCore.Locale.translate(0, "options"),
                slot = "header",
                style = {}
            })
            featuresSubPage:RegisterElement('bottomline', {
                slot = "content",
                style = {}
            })

            featuresSubPage:RegisterElement('pagearrows', {
                total = FeatherCore.Locale.translate(0, "moveCamUp"),
                current = FeatherCore.Locale.translate(0, "moveCamDown"),
                style = {}
            }, function(data)
                if data.value == 'forward' then
                    CamZ = CamZ + 0.1
                else
                    CamZ = CamZ - 0.1
                end
                SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
            end)

            featuresSubPage:RegisterElement('pagearrows', {
                total = FeatherCore.Locale.translate(0, "rotateRight"),
                current = FeatherCore.Locale.translate(0, "rotateLeft"),
                style = {}
            }, function(data)
                local heading = GetEntityHeading(PlayerPedId())
                if data.value == 'forward' then
                    heading = heading + 10.0
                else
                    heading = heading - 10.0
                end
                SetEntityHeading(PlayerPedId(), heading)
            end)

            featuresSubPage:RegisterElement('slider', {
                label = v .. ' ' .. FeatherCore.Locale.translate(0, "opacity"),
                start = 0,
                min = 0,
                max = 1,
                steps = 0.1
            }, function(data)
                if data.value == 1 then data.value = 1.0 end
                if data.value > 0 then
                    ActiveOpacity[v] = data.value
                    ChangeOverlay(PlayerPedId(), v, 1, ActiveTexture[v], 0, 0, 1, 1.0, 0, 1, 0, 0, 0, 1,
                        ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                else
                    ChangeOverlay(PlayerPedId(), v, 0, ActiveTexture[v], 0, 0, 1, 1.0, 0, 1, 0, 0, 0,
                        ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                end
                SelectedOverlayElements[v]["opacity"] = ActiveOpacity[v]
            end)

            featuresSubPage:RegisterElement('slider', {
                label = v .. ' ' .. FeatherCore.Locale.translate(0, "texture"),
                start = 0,
                min = 0,
                max = #OverlayInfo[v],
                steps = 1
            }, function(data)
                ActiveTexture[v] = data.value
                if data.value > 0 then
                    ChangeOverlay(PlayerPedId(), v, 1, ActiveTexture[v], 0, 0, 1, 1.0, 0, 1, 0, 0, 0,
                        ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                else
                    ChangeOverlay(PlayerPedId(), v, 0, ActiveTexture[v], 0, 0, 1, 1.0, 0, 1, 0, 0, 0,
                        ActiveVariant[v], ActiveOpacity[v], SelectedAttributeElements['Albedo'].hash)
                end
                SelectedOverlayElements[v]['textureId'] = ActiveTexture[v]
            end)

            featuresSubPage:RegisterElement('line', { slot = "content", style = {} })
            featuresSubPage:RegisterElement('line', { slot = "footer", style = {} })

            featuresSubPage:RegisterElement('button', {
                label = FeatherCore.Locale.translate(0, "goBack"),
                slot = 'footer',
                style = {}
            }, function()
                facialFeaturesPage:RouteTo()
            end)

            featuresSubPage:RegisterElement('bottomline', {
                slot = "footer",
                style = {}
            })

            featuresSubPage:RouteTo()
        end)
    end

    facialFeaturesPage:RegisterElement('line', { slot = "footer", style = {} })
    facialFeaturesPage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "goBack"),
        slot = 'footer',
        style = {}
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
            Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        mainAppearanceMenu:RouteTo()
    end)

    facialFeaturesPage:RegisterElement('bottomline', { slot = "footer", style = {} })

    SwitchCam(Config.CameraCoords.creation.x - 0.25, Config.CameraCoords.creation.y,
        Config.CameraCoords.creation.z + 0.7, Config.CameraCoords.creation.h, 0.0)

    facialFeaturesPage:RouteTo()
end

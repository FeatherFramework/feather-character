local textureId = -1
Gender = GetGender()

MainMakeupMenu = MyMenu:RegisterPage('mainmakeup:page')

MainMakeupMenu:RegisterElement('header', {
    value = 'My First Menu',
    slot = "header",
    style = {}
})
MainMakeupMenu:RegisterElement('subheader', {
    value = "First Page",
    slot = "header",
    style = {}
})

MainMakeupMenu:RegisterElement('bottomline', {
    slot = "footer",
    style = {

    }
})

for k, v in pairs(FaceFeatures.Makeup) do
    MainMakeupMenu:RegisterElement('button', {
        label = k,
        style = {
        },
    }, function()
        MakeupPage = MyMenu:RegisterPage('activemakeup:page')
        CreateMakeupSubPage(MakeupPage, v)
        MakeupPage:RouteTo()
    end)
end

MainMakeupMenu:RegisterElement('button', {
    label = "Go Back",
    slot = 'footer',

    style = {
    },
}, function()
    CategoriesPage:RouteTo()
end)

local tx_color_type = 0

function CreateMakeupSubPage(ActivePage, selected)
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
        start = 1,
        min = 0,
        max = 1,
        steps = 0.1,

    }, function(data)
        if data.value == 1 then
            data.value = 1.0
        end
        ActiveOpacity[selected] = data.value
        -- This gets triggered whenever the sliders selected value changes
        if data.value > 0 then
            ChangeOverlay(PlayerPedId(), selected, 1, ActiveTexture[selected], 0, 0, tx_color_type, 1.0, 0, 1,
                ActiveColor1[selected],
                ActiveColor2[selected], ActiveColor3[selected], ActiveVariant[selected], ActiveOpacity[selected],
                SelectedAttributeElements['Albedo'].hash)
        else
            ChangeOverlay(PlayerPedId(), selected, 0, ActiveTexture[selected], 0, 0, tx_color_type, 1.0, 0, 1,
                ActiveColor1[selected],
                ActiveColor2[selected], ActiveColor3[selected], ActiveVariant[selected], ActiveOpacity[selected],
                SelectedAttributeElements['Albedo'].hash)
        end
        SelectedOverlayElements[selected]["opacity"] = ActiveOpacity[selected]
    end)
    ActivePage:RegisterElement("toggle", {
        label = selected,
        start = false,
    }, function(data)
        if data.value then
            ActiveTexture[selected] = 1
            ChangeOverlay(PlayerPedId(), selected, 1, ActiveTexture[selected], 0, 0, tx_color_type, 1.0, 0, 1,
                ActiveColor1[selected],
                ActiveColor2[selected], ActiveColor3[selected], ActiveVariant[selected], ActiveOpacity[selected],
                (SelectedAttributeElements['Albedo'].hash))
            SelectedOverlayElements[selected]["textureId"] = ActiveTexture[selected]
        else
            ChangeOverlay(PlayerPedId(), selected, 0, ActiveTexture[selected], 0, 0, tx_color_type, 1.0, 0, 1,
                ActiveColor1[selected],
                ActiveColor2[selected], ActiveColor3[selected], ActiveVariant[selected], ActiveOpacity[selected],
                SelectedAttributeElements['Albedo'].hash)
            ActiveTexture[selected] = 0
            SelectedOverlayElements[selected]["textureId"] = nil
        end
    end)
    if selected == 'eyeliners' then
        VarMax = 15
    elseif selected == 'shadows' then
        VarMax = 5
    elseif selected == 'lipsticks' then
        VarMax = 7
    end
    if selected == 'eyeliners' or selected == 'shadows' or selected == 'lipsticks' then
        ActivePage:RegisterElement('slider', {
            label = selected .. ' Variant',
            start = 0,
            min = 0,
            max = VarMax,
            steps = 1,

        }, function(data)
            ActiveVariant[selected] = data.value
            if data.value > 0 then
                ChangeOverlay(PlayerPedId(), selected, 1, ActiveTexture[selected], 0, 0, tx_color_type, 1.0, 0, 1,
                    ActiveColor1[selected],
                    ActiveColor2[selected], ActiveColor3[selected], ActiveVariant[selected], ActiveOpacity[selected],
                    SelectedAttributeElements['Albedo'].hash)
            else
                ChangeOverlay(PlayerPedId(), selected, 0, ActiveTexture[selected], 0, 0, tx_color_type, 1.0, 0, 1,
                    ActiveColor1[selected],
                    ActiveColor2[selected], ActiveColor3[selected], ActiveVariant[selected], ActiveOpacity[selected],
                    SelectedAttributeElements['Albedo'].hash)
            end
            SelectedOverlayElements[selected]["variant"] = ActiveVariant[selected]

            -- This gets triggered whenever the sliders selected value changes
        end)
    end
    ActivePage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    ActivePage:RegisterElement('slider', {
        label = selected .. ' Color 1',
        start = 1,
        min = 1,
        max = 254,
        steps = 1,
    }, function(data)
        ActiveColor1[selected] = data.value
        -- This gets triggered whenever the sliders selected value changes
        if ActiveColor1[selected] > 0 then
            ChangeOverlay(PlayerPedId(), selected, 1, ActiveTexture[selected], 0, 0, tx_color_type, 1.0, 0, 1,
                ActiveColor1[selected],
                ActiveColor2[selected], ActiveColor3[selected], ActiveVariant[selected], ActiveOpacity[selected],
                SelectedAttributeElements['Albedo'].hash)
        else
            ChangeOverlay(PlayerPedId(), selected, 0, ActiveTexture[selected], 0, 0, tx_color_type, 1.0, 0, 1,
                ActiveColor1[selected],
                ActiveColor2[selected], ActiveColor3[selected], ActiveVariant[selected], ActiveOpacity[selected],
                SelectedAttributeElements['Albedo'].hash)
        end
        SelectedOverlayElements[selected]["color1"] = ActiveColor1[selected]
        print(TableToString(data.value))
    end)
    if selected ~= { 'lipsticks', 'foundation' } then
        ActivePage:RegisterElement('slider', {
            label = selected .. ' Color 2',
            start = 1,
            min = 1,
            max = 254,
            steps = 1,

        }, function(data)
            ActiveColor2[selected] = data.value
            -- This gets triggered whenever the sliders selected value changes
            if ActiveColor2[selected] > 0 then
                ChangeOverlay(PlayerPedId(), selected, 1, ActiveTexture[selected], 0, 0, tx_color_type, 1.0, 0, 1,
                    ActiveColor1[selected],
                    ActiveColor2[selected], ActiveColor3[selected], ActiveVariant[selected], ActiveOpacity[selected],
                    SelectedAttributeElements['Albedo'].hash)
            else
                ChangeOverlay(PlayerPedId(), selected, 0, ActiveTexture[selected], 0, 0, tx_color_type, 1.0, 0, 1,
                    ActiveColor1[selected],
                    ActiveColor2[selected], ActiveColor3[selected], ActiveVariant[selected], ActiveOpacity[selected],
                    SelectedAttributeElements['Albedo'].hash)
            end
            SelectedOverlayElements[selected]["color2"] = ActiveColor2[selected]

            print(TableToString(data.value))
        end)
    end
    if selected ~= { 'lipsticks', 'foundation' } then
        ActivePage:RegisterElement('slider', {
            label = selected .. ' Color 3',
            start = 1,
            min = 1,
            max = 254,
            steps = 1,

        }, function(data)
            ActiveColor3[selected] = data.value
            -- This gets triggered whenever the sliders selected value changes
            if ActiveColor3[selected] > 0 then
                ChangeOverlay(PlayerPedId(), selected, 1, ActiveTexture[selected], 0, 0, tx_color_type, 1.0, 0, 1,
                    ActiveColor1[selected],
                    ActiveColor2[selected], ActiveColor3[selected], ActiveVariant[selected], ActiveOpacity[selected],
                    SelectedAttributeElements['Albedo'].hash)
            else
                ChangeOverlay(PlayerPedId(), selected, 0, ActiveTexture[selected], 0, 0, tx_color_type, 1.0, 0, 1,
                    ActiveColor1[selected],
                    ActiveColor2[selected], ActiveColor3[selected], ActiveVariant[selected], ActiveOpacity[selected],
                    SelectedAttributeElements['Albedo'].hash)
            end
            SelectedOverlayElements[selected]["color3"] = ActiveColor3[selected]

        end)
    end

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
        MainMakeupMenu:RouteTo()
    end)
end

function ChangeOverlay(ped, name, visibility, tx_id, tx_normal, tx_material, tx_color_type, tx_opacity, tx_unk,
                       palette_id,
                       palette_color_primary, palette_color_secondary, palette_color_tertiary, var, opacity, albedo)
    print(ped)
    for k, v in pairs(overlay_all_layers) do
        if v.name == name then
            print('got to here')
            v.visibility = visibility
            if visibility ~= 0 then
                print('got to here2')

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
                    print('got to here3')

                end
                if name == "shadows" or name == "eyeliners" or name == "lipsticks" then
                    v.var = var
                    v.tx_id = overlays_info[name][1].id
                    print('got to here4')

                else
                    v.var = 0
                    v.tx_id = overlays_info[name][tx_id].id
                    print('got to here5')

                end
                v.opacity = opacity
            end
        end
    end
    print(textureId)
    if textureId ~= -1 then
        print('got to here6')

        Citizen.InvokeNative(0xB63B9178D0F58D82, textureId)
        Citizen.InvokeNative(0x6BEFAA907B076859, textureId)
    end

    local current_texture_settings = texture_types[Gender]

    if visibility > 0 then
        textureId = Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, current_texture_settings.normal,
            current_texture_settings.material)
            print('got to here7')

    end
    for k, v in pairs(overlay_all_layers) do
        if v.visibility and v.visibility ~= 0 then
            local overlay_id = Citizen.InvokeNative(0x86BB5FF45F193A02, textureId, v.tx_id, v.tx_normal,
                v.tx_material, v.tx_color_type, v.tx_opacity, v.tx_unk)
            if v.tx_color_type == 0 then
                Citizen.InvokeNative(0x1ED8588524AC9BE1, textureId, overlay_id, v.palette)
                Citizen.InvokeNative(0x2DF59FFE6FFD6044, textureId, overlay_id, v.palette_color_primary,
                    v.palette_color_secondary, v.palette_color_tertiary)
            end

            Citizen.InvokeNative(0x3329AAE2882FC8E4, textureId, overlay_id, v.var);
            Citizen.InvokeNative(0x6C76BC24F8BB709A, textureId, overlay_id, v.opacity);
            print('got to here8')

        end
    end

    while not Citizen.InvokeNative(0x31DC8D3F216D8509, textureId) do
        Wait(5)
    end

    Citizen.InvokeNative(0x92DAABA2C1C10B0E, textureId)
    Citizen.InvokeNative(0x0B46E25761519058, ped, joaat("heads"), textureId)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    print('got to here9')

end

function SetDefaultValues(selected)
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

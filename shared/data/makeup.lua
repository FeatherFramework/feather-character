overlayLookup = {
    eyeliners = {
        label = 'Eyeliners',
        txt_id = 'eyeliner_tx_id',
        variant = 'eyeliner_palette_id',
        varvalue = 15,
        color = 'eyeliner_color_primary',
        opacity = 'eyeliner_opacity',
        visibility = 'eyeliner_visibility'
    },
    lipsticks = {
        label = 'Lipsticks',
        txt_id = 'lipsticks_tx_id',
        color = 'lipsticks_palette_color_primary',
        color2 = 'lipsticks_palette_color_secondary',
        color3 = 'lipsticks_palette_color_tertiary',
        variant = 'lipsticks_palette_id',
        varvalue = 7,
        opacity = 'lipsticks_opacity',
        visibility = 'lipsticks_visibility'
    },
    shadows = {
        label = 'Shadows',
        txt_id = 'shadows_tx_id',
        color = 'shadows_palette_color_primary',
        color2 = 'shadows_palette_color_secondary',
        color3 = 'shadows_palette_color_tertiary',
        variant = 'shadows_palette_id',
        varvalue = 5,
        opacity = 'shadows_opacity',
        visibility = 'shadows_visibility'
    },
    blush = {
        label = 'Blush',
        txt_id = 'blush_tx_id',
        color = 'blush_palette_color_primary',
        opacity = 'blush_opacity',
        visibility = 'blush_visibility'
    },
}

Makeup = {
    eyeliners    = {
        { id = 0x29A2E58F, albedo = 0xA952BF75, ma = 0xDD55AF2A, },
    },
    lipsticks    = {
        { id = 0x887E11E0, albedo = 0x96A5E4FB, normal = 0x1C77591C, ma = 0x4255A5F4, },
    },
    shadows      = {
        { id = 0x47BD7289, albedo = 0x5C5C98FC, ma = 0xE20345CC, },
    },
    blush        = {
        { id = 0x6DB440FA, albedo = 0x43B1AACA, },
        { id = 0x47617455, albedo = 0x9CAD2EF0, },
        { id = 0x114D082D, albedo = 0xA52E3B98, },
        { id = 0xEC6F3E72, albedo = 0xB5CED4CB, },
    },
}

texture_types = {
    ['Male'] = {
        albedo = joaat('head_fr1_sc08_soft_c0_001_ab'),
        normal = joaat('mp_head_mr1_000_nm'),
        material = 0x50A4BBA9,
        color_type = 1,
        texture_opacity = 1.0,
        unk_arg = 0,
    },
    ['Female'] = {
        albedo = joaat('mp_head_fr1_sc08_c0_000_ab'),
        normal = joaat('head_fr1_mp_002_nm'),
        material = 0x7FC5B1E1,
        color_type = 1,
        texture_opacity = 1.0,
        unk_arg = 0,
    }
}

overlay_all_layers = {
    eyeliners ={
        name = 'eyeliners',
        visibility = 0,
        tx_id = 1,
        tx_normal = 0,
        tx_material = 0,
        tx_color_type = 0,
        tx_opacity = 1.0,
        tx_unk = 0,
        palette = 0,
        palette_color_primary = 0,
        palette_color_secondary = 0,
        palette_color_tertiary = 0,
        var = 0,
        opacity = 1.0,
    },
   lipsticks=  {
        name = 'lipsticks',
        visibility = 0,
        tx_id = 1,
        tx_normal = 0,
        tx_material = 0,
        tx_color_type = 0,
        tx_opacity = 1.0,
        tx_unk = 0,
        palette = 0,
        palette_color_primary = 0,
        palette_color_secondary = 0,
        palette_color_tertiary = 0,
        var = 0,
        opacity = 1.0,
    },
 shadows =   {
        name = 'shadows',
        visibility = 0,
        tx_id = 1,
        tx_normal = 0,
        tx_material = 0,
        tx_color_type = 0,
        tx_opacity = 1.0,
        tx_unk = 0,
        palette = 0,
        palette_color_primary = 0,
        palette_color_secondary = 0,
        palette_color_tertiary = 0,
        var = 0,
        opacity = 1.0,
    },
  blush =   {
        name = "blush",
        visibility = 0,
        tx_id = 1,
        tx_normal = 0,
        tx_material = 0,
        tx_color_type = 0,
        tx_opacity = 1.0,
        tx_unk = 0,
        palette = 0,
        palette_color_primary = 0,
        palette_color_secondary = 0,
        palette_color_tertiary = 0,
        var = 0,
        opacity = 1.0,
    },
}

color_palettes = {
    shadows = {
        0x3F6E70FF,
        0x0105607B,
        0x17CBCC83,
        0x29F81B2A,
        0x3385C5DB,
        0x37CD36D4,
        0x4101ED87,
        0x63838A81,
        0x6765BC15,
        0x8BA18876,
        0x9AC34F34,
        0x9E4803A0,
        0xA4CFABD0,
        0xAA65D8A3,
        0xB562025C,
        0xB9E7F722,
        0xBBF43EF8,
        0xD1476963,
        0xD799E1C2,
        0xDC6BC93B,
        0xDFB1F64C,
        0xF509C745,
        0xF93DB0C8,
        0xFB71527B,
        0xA4041CEF,
    },
    lipsticks = {
        0x3F6E70FF,
        0x0105607B,
        0x17CBCC83,
        0x29F81B2A,
        0x3385C5DB,
        0x37CD36D4,
        0x4101ED87,
        0x63838A81,
        0x6765BC15,
        0x8BA18876,
        0x9AC34F34,
        0x9E4803A0,
        0xA4CFABD0,
        0xAA65D8A3,
        0xB562025C,
        0xB9E7F722,
        0xBBF43EF8,
        0xD1476963,
        0xD799E1C2,
        0xDC6BC93B,
        0xDFB1F64C,
        0xF509C745,
        0xF93DB0C8,
        0xFB71527B,
        0xA4041CEF,
    },
    eyeliners = {
        0x3F6E70FF,
        0x0105607B,
        0x17CBCC83,
        0x29F81B2A,
        0x3385C5DB,
        0x37CD36D4,
        0x4101ED87,
        0x63838A81,
        0x6765BC15,
        0x8BA18876,
        0x9AC34F34,
        0x9E4803A0,
        0xA4CFABD0,
        0xAA65D8A3,
        0xB562025C,
        0xB9E7F722,
        0xBBF43EF8,
        0xD1476963,
        0xD799E1C2,
        0xDC6BC93B,
        0xDFB1F64C,
        0xF509C745,
        0xF93DB0C8,
        0xFB71527B,
        0xA4041CEF,
    },
    blush = {
        0x3F6E70FF,
        0x0105607B,
        0x17CBCC83,
        0x29F81B2A,
        0x3385C5DB,
        0x37CD36D4,
        0x4101ED87,
        0x63838A81,
        0x6765BC15,
        0x8BA18876,
        0x9AC34F34,
        0x9E4803A0,
        0xA4CFABD0,
        0xAA65D8A3,
        0xB562025C,
        0xB9E7F722,
        0xBBF43EF8,
        0xD1476963,
        0xD799E1C2,
        0xDC6BC93B,
        0xDFB1F64C,
        0xF509C745,
        0xF93DB0C8,
        0xFB71527B,
        0xA4041CEF,
    }
}

local textureId = -1
local is_overlay_change_active = false
local current_texture_settings = texture_types["Male"]


function ChangeOverlay(name,visibility,tx_id,tx_normal,tx_material,tx_color_type,tx_opacity,tx_unk,palette_id,palette_color_primary,palette_color_secondary,palette_color_tertiary,var,opacity)
    for k,v in pairs(overlay_all_layers) do
        if v.name==name then
            v.visibility = visibility
            if visibility ~= 0 then
                v.tx_normal = tx_normal
                v.tx_material = tx_material
                v.tx_color_type = tx_color_type
                v.tx_opacity =  tx_opacity
                v.tx_unk =  tx_unk
                if tx_color_type == 0 then
                    v.palette = color_palettes[palette_id]
                    v.palette_color_primary = palette_color_primary
                    v.palette_color_secondary = palette_color_secondary
                    v.palette_color_tertiary = palette_color_tertiary
                end
                if name == "shadows" or name == "eyeliners" or name == "lipsticks" then
                    v.var = var
                    v.tx_id = ConfigChar.overlays_info[name][1].id
                else
                    v.var = 0
                    v.tx_id = ConfigChar.overlays_info[name].id
                end
                v.opacity = opacity
            end
        end
    end
    is_overlay_change_active = true
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if is_overlay_change_active then
            local ped = PlayerPedId()
            if IsPedMale(ped) then
                current_texture_settings = texture_types["Male"]
            else
                current_texture_settings = texture_types["Female"]
            end
            if textureId ~= -1 then
                Citizen.InvokeNative(0xB63B9178D0F58D82,textureId)  -- reset texture
                Citizen.InvokeNative(0x6BEFAA907B076859,textureId)  -- remove texture
            end
            textureId = Citizen.InvokeNative(0xC5E7204F322E49EB,current_texture_settings.albedo, current_texture_settings.normal, current_texture_settings.material);  -- create texture
            for k,v in pairs(overlay_all_layers) do
                if v.visibility ~= 0 then
                    local overlay_id = Citizen.InvokeNative(0x86BB5FF45F193A02,textureId, v.tx_id , v.tx_normal, v.tx_material, v.tx_color_type, v.tx_opacity,v.tx_unk); -- create overlay
                    if v.tx_color_type == 0 then
                        Citizen.InvokeNative(0x1ED8588524AC9BE1,textureId,overlay_id,v.palette);    -- apply palette
                        Citizen.InvokeNative(0x2DF59FFE6FFD6044,textureId,overlay_id,v.palette_color_primary,v.palette_color_secondary,v.palette_color_tertiary)  -- apply palette colours
                    end
                    Citizen.InvokeNative(0x3329AAE2882FC8E4,textureId,overlay_id, v.var);  -- apply overlay variant
                    Citizen.InvokeNative(0x6C76BC24F8BB709A,textureId,overlay_id, v.opacity); -- apply overlay opacity
                end
            end
            while not Citizen.InvokeNative(0x31DC8D3F216D8509,textureId) do  -- wait till texture fully loaded
                Citizen.Wait(0)
            end
            Citizen.InvokeNative(0x0B46E25761519058,ped,`heads`,textureId)  -- apply texture to current component in category "heads"
            Citizen.InvokeNative(0x92DAABA2C1C10B0E,textureId)      -- update texture
            Citizen.InvokeNative(0xCC8CA3E88256E58F,ped, 0, 1, 1, 1, false);  -- refresh ped components
            is_overlay_change_active = false
        end
    end
end)
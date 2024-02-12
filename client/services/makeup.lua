local textureId = -1
local is_overlay_change_active = false
Gender = GetGender()

function ChangeOverlay(name, visibility, tx_id, tx_normal, tx_material, tx_color_type, tx_opacity, tx_unk, palette_id,
                       palette_color_primary, palette_color_secondary, palette_color_tertiary, var, opacity, albedo)
    for k, v in pairs(CharacterConfig.Attributes.OverlayLayers) do
        if v.name == name then
            v.visibility = visibility
            if visibility ~= 0 then
                v.tx_normal = tx_normal
                v.tx_material = tx_material
                v.tx_color_type = tx_color_type
                v.tx_opacity = tx_opacity
                v.tx_unk = tx_unk
                if tx_color_type == 0 then
                    v.palette = CharacterConfig.Attributes.ColorPalettes[palette_id][1]
                    v.palette_color_primary = palette_color_primary
                    v.palette_color_secondary = palette_color_secondary
                    v.palette_color_tertiary = palette_color_tertiary
                end
                if name == "shadows" or name == "eyeliners" or name == "lipsticks" then
                    v.var = var
                    v.tx_id = CharacterConfig.Attributes.Facial[name][1].id
                else
                    v.var = 0
                    v.tx_id = CharacterConfig.Attributes.Facial[name][tx_id].id
                end
                v.opacity = opacity
            end
        end
    end
    if textureId ~= -1 then
        Citizen.InvokeNative(0xB63B9178D0F58D82, textureId)
        Citizen.InvokeNative(0x6BEFAA907B076859, textureId)
    end

    local current_texture_settings = CharacterConfig.Attributes.Textures[Gender]

    textureId = Citizen.InvokeNative(0xC5E7204F322E49EB, albedo, current_texture_settings.normal,
        current_texture_settings.material)
        print(textureId,albedo, current_texture_settings.normal,current_texture_settings.material)

    for k, v in pairs(CharacterConfig.Attributes.OverlayLayers) do
        if v.visibility ~= 0 then
            local overlay_id = Citizen.InvokeNative(0x86BB5FF45F193A02, textureId, v.tx_id, v.tx_normal,
                v.tx_material, v.tx_color_type, v.tx_opacity, v.tx_unk)
                print(overlay_id)
            if v.tx_color_type == 0 then
                Citizen.InvokeNative(0x1ED8588524AC9BE1, textureId, overlay_id, v.palette)
                Citizen.InvokeNative(0x2DF59FFE6FFD6044, textureId, overlay_id, v.palette_color_primary,
                    v.palette_color_secondary, v.palette_color_tertiary)
            end

            Citizen.InvokeNative(0x3329AAE2882FC8E4, textureId, overlay_id, v.var);
            Citizen.InvokeNative(0x6C76BC24F8BB709A, textureId, overlay_id, v.opacity);
        end
    end

    while not Citizen.InvokeNative(0x31DC8D3F216D8509, textureId) do
        Citizen.Wait(0)
    end

    Citizen.InvokeNative(0x92DAABA2C1C10B0E, textureId)
    Citizen.InvokeNative(0x0B46E25761519058, PlayerPedId(), joaat("heads"), textureId)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), false, true, true, true, false)
end

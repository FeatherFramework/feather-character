local textureId = -1
local is_overlay_change_active = false
local current_texture_settings = CharacterConfig.General.TextureTypes["Male"]

function ChangeOverlay(name, visibility, tx_id, tx_normal, tx_material, tx_color_type, tx_opacity, tx_unk, palette_id,
                       palette_color_primary, palette_color_secondary, palette_color_tertiary, var, opacity)
    for k, v in pairs(CharacterConfig.Attributes.OverlayAllLayers) do
        if v.name == name then
            v.visibility = visibility
            if visibility ~= 0 then
                v.tx_normal = tx_normal
                v.tx_material = tx_material
                v.tx_color_type = tx_color_type
                v.tx_opacity = tx_opacity
                v.tx_unk = tx_unk
                if tx_color_type == 0 then
                    v.palette = CharacterConfig.Attributes.ColorPalettes[palette_id]
                    v.palette_color_primary = palette_color_primary
                    v.palette_color_secondary = palette_color_secondary
                    v.palette_color_tertiary = palette_color_tertiary
                end
                if name == "shadows" or name == "eyeliners" or name == "lipsticks" then
                    v.var = var
                    v.tx_id = CharacterConfig.Attributes.OverlaysInfo[name][1].id
                else
                    v.var = 0
                    v.tx_id = CharacterConfig.Attributes.OverlaysInfo[name].id
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
                current_texture_settings = CharacterConfig.General.TextureTypes["Male"]
            else
                current_texture_settings = CharacterConfig.General.TextureTypes["Female"]
            end
            if textureId ~= -1 then
                Citizen.InvokeNative(0xB63B9178D0F58D82, textureId)                                                                                                   -- reset texture
                Citizen.InvokeNative(0x6BEFAA907B076859, textureId)                                                                                                   -- remove texture
            end
            textureId = Citizen.InvokeNative(0xC5E7204F322E49EB, current_texture_settings.albedo,
                current_texture_settings.normal, current_texture_settings.material);                                                                                  -- create texture
            for k, v in pairs(CharacterConfig.Attributes.OverlayAllLayers) do
                if v.visibility ~= 0 then
                    local overlay_id = Citizen.InvokeNative(0x86BB5FF45F193A02, textureId, v.tx_id, v.tx_normal,
                        v.tx_material, v.tx_color_type, v.tx_opacity, v.tx_unk);                                                                                         -- create overlay
                    if v.tx_color_type == 0 then
                        Citizen.InvokeNative(0x1ED8588524AC9BE1, textureId, overlay_id, v.palette);                                                                      -- apply palette
                        Citizen.InvokeNative(0x2DF59FFE6FFD6044, textureId, overlay_id, v.palette_color_primary,
                            v.palette_color_secondary, v.palette_color_tertiary)                                                                                         -- apply palette colours
                    end
                    Citizen.InvokeNative(0x3329AAE2882FC8E4, textureId, overlay_id, v.var);                                                                              -- apply overlay variant
                    Citizen.InvokeNative(0x6C76BC24F8BB709A, textureId, overlay_id, v.opacity);                                                                          -- apply overlay opacity
                end
            end
            while not Citizen.InvokeNative(0x31DC8D3F216D8509, textureId) do -- wait till texture fully loaded
                Citizen.Wait(0)
            end
            Citizen.InvokeNative(0x0B46E25761519058, ped, 'heads', textureId) -- apply texture to current component in category "heads"
            Citizen.InvokeNative(0x92DAABA2C1C10B0E, textureId)              -- update texture
            Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, 0, 1, 1, 1, false); -- refresh ped components
            is_overlay_change_active = false
        end
    end
end)

local name, money, birthday, desc, ID, img = {}, {}, {}, {}, {}, {}

RegisterNetEvent('feather-character:CharacterSelectMenu',
    function(info, cameraSpot, charAmount, clothing, attributes, overlays)
        for k, v in ipairs(info) do
            name[k] = v.first_name .. " " .. v.last_name
            money[k] = v.dollars
            birthday[k] = v.dob
            desc[k] = v.description
            ID[k] = v.id
            img[k] = json.decode(v.img)
        end

        local characterSelectPage = CharacterMenu:RegisterPage('characterSelect:page')

        characterSelectPage:RegisterElement('header', {
            value = FeatherCore.Locale.translate(0, "charMenu"),
            slot = "header",
            style = {}
        })
        characterSelectPage:RegisterElement('line', {
            slot = "content",
            style = {}
        })
        characterSelectPage:RegisterElement('textdisplay', {
            value = FeatherCore.Locale.translate(0, "name") .. name[cameraSpot],
            style = {}
        })
        characterSelectPage:RegisterElement('line', {
            slot = "content",
            style = {}
        })
        characterSelectPage:RegisterElement('html', {
            value = {
                [[
        <div style="display:flex;justify-content:center;gap:20px;margin:10px auto;">
            <div style="text-align:center;">
                <img src="nui://feather-character/html/img/money.png" width="32" height="32" />
                <div style="font-size:14px;color:#0f0;">$]] .. money[cameraSpot] .. [[</div>
            </div>
            <div style="text-align:center;">
                <img src="nui://feather-character/html/img/gold.png" width="32" height="32" />
                <div style="font-size:14px;color:#FFD700;">]] .. (info[cameraSpot].gold or 0) .. [[</div>
            </div>
            <div style="text-align:center;position:relative;display:inline-block;">
                <img src="nui://feather-character/html/img/shield.png" width="48" height="48" />
                <span style="position:absolute;bottom:0;right:0;font-size:12px;color:#0ff;font-weight:bold;">
                    ]] .. (info[cameraSpot].exp or 0) .. [[
                </span>
            </div>
            <div style="text-align:center;">
                <img src="nui://feather-character/html/img/token.png" width="32" height="32" />
                <div style="font-size:14px;color:#ff0;">]] .. (info[cameraSpot].tokens or 0) .. [[</div>
            </div>
        </div>
        ]]
            }
        })



        characterSelectPage:RegisterElement('line', {
            slot = "content",
            style = {}
        })
        characterSelectPage:RegisterElement('textdisplay', {
            value = FeatherCore.Locale.translate(0, "dob") .. ": " .. '\n' .. ' ' .. birthday[cameraSpot],
            style = {}
        })
        characterSelectPage:RegisterElement('line', {
            slot = "content",
            style = {}
        })
        characterSelectPage:RegisterElement('textdisplay', {
            value = FeatherCore.Locale.translate(0, "charDesc") .. ": ",
            style = {}
        })
        if img[cameraSpot] ~= 'None' then
            characterSelectPage:RegisterElement("html", {
                value = {
                    [[
                <img width="200px" height="100px" style="display: block; margin:10px auto;" src="]] ..
                    img[cameraSpot] .. [[ " />
            ]]
                }
            })
        end
        characterSelectPage:RegisterElement('line', {
            slot = "footer",
            style = {}
        })
        characterSelectPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "select"),
            slot = "footer",
            style = {}
        }, function()
            if cameraSpot ~= nil then
                Spawned = false
                CleanupScript()
                LoadPlayer(CharModel)
                TriggerServerEvent('feather-character:InitiateCharacter', ID[cameraSpot])
                Characterid = ID[cameraSpot]
                for category, hash in pairs(clothing[cameraSpot]) do
                    AddComponent(PlayerPedId(), hash, category)
                end
                for category, attribute in pairs(attributes[cameraSpot]) do
                    if category == 'Albedo' then
                        AlbedoHash = attribute.hash
                    end
                    if attribute.value then
                        SetCharExpression(PlayerPedId(), attribute.hash, attribute.value)
                    else
                        AddComponent(PlayerPedId(), attribute.hash, category)
                    end
                end
                for category, overlays in pairs(overlays[cameraSpot]) do
                    ChangeOverlay(PlayerPedId(), category, 1, overlays['textureId'], 0, 0, 0, 1.0, 0, 1,
                        overlays['color1'], overlays['color2'], overlays['color3'], overlays['variant'],
                        overlays['opacity'], SelectedAttributeElements['Albedo'].hash)
                end
            end
        end)
        characterSelectPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "createNewChar"),
            slot = "footer",
            style = {}
        }, function()
            TriggerEvent('feather-character:CreateNewCharacter')
        end)
        characterSelectPage:RegisterElement('textdisplay', {
            value = desc[cameraSpot],
            style = {}
        })
        characterSelectPage:RegisterElement('bottomline', {
            slot = "footer",
        })
        characterSelectPage:RegisterElement('pagearrows', {
            slot = "footer",
            style = {}
        }, function(data)
            if data.value == 'forward' then
                if cameraSpot <= charAmount then
                    cameraSpot = cameraSpot + 1
                end
                if cameraSpot > charAmount then
                    cameraSpot = 1
                end
                SwitchCam(Config.CameraCoords.charcamera[cameraSpot].x, Config.CameraCoords.charcamera[cameraSpot].y,
                    Config.CameraCoords.charcamera[cameraSpot].z, Config.CameraCoords.charcamera[cameraSpot].h,
                    Config.CameraCoords.charcamera[cameraSpot].zoom)
                TriggerEvent('feather-character:CharacterSelectMenu', info, cameraSpot, charAmount, clothing, attributes,overlays)
            else
                if cameraSpot < charAmount then
                    cameraSpot = cameraSpot - 1
                end
                if cameraSpot >= charAmount then
                    cameraSpot = 1
                end
                if cameraSpot < 1 then
                    cameraSpot = charAmount
                end
                SwitchCam(Config.CameraCoords.charcamera[cameraSpot].x, Config.CameraCoords.charcamera[cameraSpot].y,
                    Config.CameraCoords.charcamera[cameraSpot].z, Config.CameraCoords.charcamera[cameraSpot].h,
                    Config.CameraCoords.charcamera[cameraSpot].zoom)
                TriggerEvent('feather-character:CharacterSelectMenu', info, cameraSpot, charAmount, clothing, attributes,overlays)
            end
        end)
        CharacterMenu:Open({
            cursorFocus = true,
            menuFocus = true,
            startupPage = characterSelectPage
        })
    end)

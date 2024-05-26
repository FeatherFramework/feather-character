local Name, Money, Birthday, Description, ID, Img = {}, {}, {}, {}, {}, {}
RegisterNetEvent('feather-character:CharacterSelectMenu',
    function(Info, CameraSpot, CharAmount, Clothing, Attributes, Overlays)
        for k, v in ipairs(Info) do
            Name[k] = v.first_name .. " " .. v.last_name
            Money[k] = v.dollars
            Birthday[k] = v.dob
            Description[k] = v.description
            ID[k] = v.id
            Img[k] = json.decode(v.img)
        end
        local CharacterSelectPage = MyMenu:RegisterPage('first:page')

        CharacterSelectPage:RegisterElement('header', {
            value = 'Character Menu',
            slot = "header",
            style = {}
        })
        CharacterSelectPage:RegisterElement('line', {
            slot = "content",
            style = {}
        })
        CharacterSelectPage:RegisterElement('textdisplay', {
            value = "Name: " .. Name[CameraSpot],
            style = {}
        })
        CharacterSelectPage:RegisterElement('line', {
            slot = "content",
            style = {}
        })
        CharacterSelectPage:RegisterElement('textdisplay', {
            value = "Money: " .. Money[CameraSpot],
            style = {}
        })
        CharacterSelectPage:RegisterElement('line', {
            slot = "content",
            style = {}
        })
        CharacterSelectPage:RegisterElement('line', {
            slot = "content",
            style = {}
        })
        CharacterSelectPage:RegisterElement('textdisplay', {
            value = "Date of Birth: "
                .. '\n' .. ' ' .. Birthday[CameraSpot],
            style = {}
        })
        CharacterSelectPage:RegisterElement('line', {
            slot = "content",
            style = {}
        })
        CharacterSelectPage:RegisterElement('textdisplay', {
            value = "Character Description: ",
            style = {}
        })
        CharacterSelectPage:RegisterElement('textdisplay', {
            value = Description[CameraSpot],
            style = {}
        })
        CharacterSelectPage:RegisterElement('bottomline', {
            slot = "footer",
        })
        CharacterSelectPage:RegisterElement('pagearrows', {
            slot = "footer",
            style = {},
        }, function(data)
            if data.value == 'forward' then
                if CameraSpot <= CharAmount then
                    CameraSpot = CameraSpot + 1
                end
                if CameraSpot > CharAmount then
                    CameraSpot = 1
                end
                SwitchCam(Config.CameraCoords.charcamera[CameraSpot].x, Config.CameraCoords.charcamera[CameraSpot].y, Config.CameraCoords.charcamera[CameraSpot].z, Config.CameraCoords.charcamera[CameraSpot].h, Config.CameraCoords.charcamera[CameraSpot].zoom)
                TriggerEvent('feather-character:CharacterSelectMenu', Info, CameraSpot, CharAmount, Clothing, Attributes, Overlays)
            else
                if CameraSpot < CharAmount then
                    CameraSpot = CameraSpot - 1
                end
                if CameraSpot >= CharAmount then
                    CameraSpot = 1
                end
                if CameraSpot < 1 then
                    CameraSpot = CharAmount
                end
                SwitchCam(Config.CameraCoords.charcamera[CameraSpot].x, Config.CameraCoords.charcamera[CameraSpot].y, Config.CameraCoords.charcamera[CameraSpot].z, Config.CameraCoords.charcamera[CameraSpot].h, Config.CameraCoords.charcamera[CameraSpot].zoom)
                TriggerEvent('feather-character:CharacterSelectMenu', Info, CameraSpot, CharAmount, Clothing, Attributes, Overlays)
            end
        end)
        CharacterSelectPage:RegisterElement('button', {
            label = "Select",
            style = {}
        }, function()
            if CameraSpot ~= nil then
                Spawned = false
                CleanupScript()
                LoadPlayer(CharModel)
                TriggerServerEvent('feather-character:InitiateCharacter', ID[CameraSpot])
                Characterid = ID[CameraSpot]
                for category, hash in pairs(Clothing[CameraSpot]) do
                    AddComponent(PlayerPedId(), hash, category)
                end
                for category, attribute in pairs(Attributes[CameraSpot]) do
                    if category == 'Albedo' then
                        AlbedoHash = attribute.hash
                    end
                    if attribute.value then
                        SetCharExpression(PlayerPedId(), attribute.hash, attribute.value)
                    else
                        AddComponent(PlayerPedId(), attribute.hash, category)
                    end
                end
                for category, overlays in pairs(Overlays[CameraSpot]) do
                    ChangeOverlay(PlayerPedId(), category, 1, overlays['textureId'], 0, 0, 0, 1.0, 0, 1, overlays['color1'], overlays['color2'], overlays['color3'], overlays['variant'], overlays['opacity'], SelectedAttributeElements['Albedo'].hash)
                end
            end
        end)
        CharacterSelectPage:RegisterElement('button', {
            label = "Create New Character",
            style = {
            }
        }, function()
            TriggerEvent('feather-character:CreateNewCharacter')
        end)
        if Img[CameraSpot] ~= 'None' then
            CharacterSelectPage:RegisterElement("html", {
                value = {
                    [[
                    <img width="200px" height="100px" style="display: block; margin:10px auto;" src="]] ..
                    Img[CameraSpot] .. [[ " />
                ]]
                }
            })
        end

        MyMenu:Open({
            cursorFocus = true,
            menuFocus = true,
            startupPage = CharacterSelectPage,
        })
    end)

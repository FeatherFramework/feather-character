local name, money, birthday, desc, ID, img = {}, {}, {}, {}, {}, {}
RegisterNetEvent('feather-character:CharacterSelectMenu', function(info, cameraSpot, charAmount, clothing, attributes, overlays)
    for k, v in ipairs(info) do
        name[k] = v.first_name .. " " .. v.last_name
        money[k] = v.dollars
        birthday[k] = v.dob
        desc[k] = v.description
        ID[k] = v.id
        img[k] = json.decode(v.img)
    end
    local characterSelectPage = MyMenu:RegisterPage('first:page')

    characterSelectPage:RegisterElement('header', {
        value = 'Character Menu',
        slot = "header",
        style = {}
    })
    characterSelectPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    characterSelectPage:RegisterElement('textdisplay', {
        value = "Name: " .. name[cameraSpot],
        style = {}
    })
    characterSelectPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    characterSelectPage:RegisterElement('textdisplay', {
        value = "Money: " .. money[cameraSpot],
        style = {}
    })
    characterSelectPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    characterSelectPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    characterSelectPage:RegisterElement('textdisplay', {
        value = "Date of Birth: "
            .. '\n' .. ' ' .. birthday[cameraSpot],
        style = {}
    })
    characterSelectPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    characterSelectPage:RegisterElement('textdisplay', {
        value = "Character Description: ",
        style = {}
    })
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
            SwitchCam(Config.CameraCoords.charcamera[cameraSpot].x, Config.CameraCoords.charcamera[cameraSpot].y, Config.CameraCoords.charcamera[cameraSpot].z, Config.CameraCoords.charcamera[cameraSpot].h, Config.CameraCoords.charcamera[cameraSpot].zoom)
            TriggerEvent('feather-character:CharacterSelectMenu', info, cameraSpot, charAmount, clothing, attributes, overlays)
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
            SwitchCam(Config.CameraCoords.charcamera[cameraSpot].x, Config.CameraCoords.charcamera[cameraSpot].y, Config.CameraCoords.charcamera[cameraSpot].z, Config.CameraCoords.charcamera[cameraSpot].h, Config.CameraCoords.charcamera[cameraSpot].zoom)
            TriggerEvent('feather-character:CharacterSelectMenu', info, cameraSpot, charAmount, clothing, attributes, overlays)
        end
    end)
    characterSelectPage:RegisterElement('button', {
        label = "Select",
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
                ChangeOverlay(PlayerPedId(), category, 1, overlays['textureId'], 0, 0, 0, 1.0, 0, 1, overlays['color1'], overlays['color2'], overlays['color3'], overlays['variant'], overlays['opacity'], SelectedAttributeElements['Albedo'].hash)
            end
        end
    end)
    characterSelectPage:RegisterElement('button', {
        label = "Create New Character",
        style = {}
    }, function()
        TriggerEvent('feather-character:CreateNewCharacter')
    end)
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

    MyMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = characterSelectPage
    })
end)
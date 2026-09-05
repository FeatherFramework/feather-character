local name, money, birthday, desc, ID, img = {}, {}, {}, {}, {}, {}

-- (CHAR-10) `img` is a client-controlled character field (see CHAR-09 --
-- unvalidated at creation) concatenated directly into an <img src="..."> in
-- the html element below. A value containing `"` closes the attribute
-- early, letting anything after it become real markup in the NUI page.
-- Escapes it before it goes anywhere near a raw HTML string.
local function EscapeHtmlAttribute(value)
    if type(value) ~= 'string' then return '' end
    return (value:gsub('[&<>"\']', {
        ['&'] = '&amp;',
        ['<'] = '&lt;',
        ['>'] = '&gt;',
        ['"'] = '&quot;',
        ["'"] = '&#39;',
    }))
end

-- Builds the actual character-select UI page (name/money/gold/xp/tokens
-- display, portrait, and next/prev paging) for whichever character is
-- currently "on camera" (cameraSpot, an index into the arrays built here
-- from `info`). Re-invoked every time the player pages to a different
-- character (see the pagearrows element near the bottom).
RegisterNetEvent('feather-character:CharacterSelectMenu',
    function(info, cameraSpot, charAmount, clothing, attributes, overlays, tints)
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
                    EscapeHtmlAttribute(img[cameraSpot]) .. [[ " />
            ]]
                }
            })
        end
        characterSelectPage:RegisterElement('line', {
            slot = "footer",
            style = {}
        })
        -- The activation route independently verifies that this UUID profile
        -- belongs to the connected account; the menu selection is never the
        -- authority boundary.
        characterSelectPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "select"),
            slot = "footer",
            style = {}
        }, function()
            if cameraSpot ~= nil then
                CharacterContract1.Activate(info[cameraSpot])
                return
            end
        end)
        characterSelectPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, "createNewChar"),
            slot = "footer",
            style = {}
        }, function()
            TriggerEvent('feather-character:CreateNewCharacter')
        end)
        characterSelectPage:RegisterElement('button', {
            label = FeatherCore.Locale.translate(0, 'deleteCharacter'),
            slot = 'footer',
            style = {}
        }, function()
            local selectedProfile = info[cameraSpot]
            local selectedName = name[cameraSpot]
            local confirmationPage = CharacterMenu:RegisterPage('characterSelect:deleteConfirmation')
            confirmationPage:RegisterElement('header', {
                value = FeatherCore.Locale.translate(0, 'deleteCharacterConfirmTitle'),
                slot = 'header',
                style = {}
            })
            confirmationPage:RegisterElement('textdisplay', {
                value = FeatherCore.Locale.translate(0, 'deleteCharacterConfirmMessage') .. '\n' .. selectedName,
                style = {}
            })
            confirmationPage:RegisterElement('button', {
                label = FeatherCore.Locale.translate(0, 'deleteCharacterConfirm'),
                slot = 'footer',
                style = {}
            }, function()
                CharacterContract1.Delete(selectedProfile, true)
            end)
            confirmationPage:RegisterElement('button', {
                label = FeatherCore.Locale.translate(0, 'deleteCharacterCancel'),
                slot = 'footer',
                style = {}
            }, function()
                characterSelectPage:RouteTo()
            end)
            confirmationPage:RegisterElement('bottomline', { slot = 'footer' })
            confirmationPage:RouteTo()
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
            current = cameraSpot,
            total = charAmount,
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
                TriggerEvent('feather-character:CharacterSelectMenu', info, cameraSpot, charAmount,
                    clothing, attributes, overlays, tints)
            else
                -- (CHAR-14) Was three separate conditionals
                -- (`if cameraSpot < charAmount then -1 end`,
                -- `if cameraSpot >= charAmount then =1 end`, ...) -- paging
                -- backward from the *last* character hit the second branch
                -- before ever decrementing (cameraSpot == charAmount makes
                -- the first check false), jumping straight to character 1
                -- and skipping character (charAmount - 1) entirely. Mirrors
                -- the forward branch above: decrement unconditionally, then
                -- wrap.
                cameraSpot = cameraSpot - 1
                if cameraSpot < 1 then
                    cameraSpot = charAmount
                end
                SwitchCam(Config.CameraCoords.charcamera[cameraSpot].x, Config.CameraCoords.charcamera[cameraSpot].y,
                    Config.CameraCoords.charcamera[cameraSpot].z, Config.CameraCoords.charcamera[cameraSpot].h,
                    Config.CameraCoords.charcamera[cameraSpot].zoom)
                TriggerEvent('feather-character:CharacterSelectMenu', info, cameraSpot, charAmount,
                    clothing, attributes, overlays, tints)
            end
        end)
        CharacterMenu:Open({
            cursorFocus = true,
            menuFocus = true,
            startupPage = characterSelectPage
        })
        CharacterRuntime.ReleaseLoadscreen()
    end)

-- TODO: REMOVE ALL THIS STUFF AS MENUAPI/REDEMTP_MENU_BASE WILL NOT BE NEEDED.
local FirstName = ''
local LastName = ''

MainCharacterPage, ClothingCategoriesPage, UpperClothingPage, LowerClothingPage, AccClothingPage, CategoriesPage, ColorPage =
    MyMenu:RegisterPage('first:page'), MyMenu:RegisterPage('second:page'), MyMenu:RegisterPage('third:page'),
    MyMenu:RegisterPage('fourth:page'), MyMenu:RegisterPage('fifth:page'), MyMenu:RegisterPage('sixth:page'),
    MyMenu:RegisterPage('seventh:page')

Model = 'mp_male'


local SelectedClothing = {}         -- This can keep track of what was selected data wise
local SelectedClothingElements = {} --This table keeps track of your clothing elements
local SelectedColoring

RegisterNetEvent('feather-character:CreateCharacterMenu', function()
    PageOpened = true
    local fov = 20.0
    if Header1 then
        Header1:unRegister()
    end
    Header1 = MainCharacterPage:RegisterElement('header', {
        value = 'Character Creation',
        slot = "header",
        style = {}
    })

    MainCharacterPage:RegisterElement('button', {
        label = "Customize Character",
        style = {
        },
    }, function()
        CategoriesPage:RouteTo()
    end)
    MainCharacterPage:RegisterElement('input', {
        label = "First Name",
        placeholder = "Enter First Name",
        style = {
        }
    }, function(data)
        -- This gets triggered whenever the input value changes
        FirstName = data.value
    end)
    MainCharacterPage:RegisterElement('input', {
        label = "Last Name",
        placeholder = "Enter Last Name",
        style = {
        }
    }, function(data)
        -- This gets triggered whenever the input value changes
        LastName = data.value
    end)
    MainCharacterPage:RegisterElement('input', {
        label = "Birthday",
        placeholder = "Birthday",
        style = {
        }
    }, function(data)
        -- This gets triggered whenever the input value changes
        DOB = data.value
    end)

    local CharDesc = ''
    MainCharacterPage:RegisterElement('textarea', {
        label = "Character Description",
        placeholder = "Enter text",
        rows = "5",
        resize = false,
        style = {
        }
    }, function(data)
        CharDesc = data.value
    end)

    MainCharacterPage:RegisterElement('input', {
        label = "Image Link",
        placeholder = "Link",
        style = {
        }
    }, function(data)
        print(data.value)
        -- This gets triggered whenever the input value changes
        ImgLink = data.value
    end)
    if ImgLink == nil then
        ImgLink = 'None'
    end
    MainCharacterPage:RegisterElement('arrows', {
        label = "Gender",
        start = 1,
        options = {
            "Male",
            "Female"
        },
    }, function(data)
        if data.value == "Male" then
            Model = 'mp_male'
        else
            Model = 'mp_female'
        end
        -- This gets triggered whenever the arrow selected value changes
        LoadPlayer(Model)
    end)
    MainCharacterPage:RegisterElement('button', {
        label = "Save Character",
        style = {
        }
    }, function()
        local data = {
            firstname = FirstName,
            lastname = LastName,
            dob = DOB,
            model = Model,
            desc = CharDesc,
            img = ImgLink,
            Clothing = SelectedClothingElements,
            Attributes = SelectedAttributeElements
        }
        FeatherCore.RPC.Call("SaveCharacterData", { data }, function(result)
            TriggerEvent('feather-character:SpawnSelect', result)
        end)
    end)

    ClothingCategoriesPage:RegisterElement('header', {
        value = 'Clothing Selection',
        slot = "header",
        style = {}
    })
    ClothingCategoriesPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        MainCharacterPage:RouteTo()
    end)
    CategoriesPage:RegisterElement('button', {
        label = 'Appearance',
        style = {
        }
    }, function()
        MainAppearanceMenu:RouteTo()
    end)
    CategoriesPage:RegisterElement('button', {
        label = 'Body',
        style = {
        }
    }, function()
        MakeBodySliders()
        MainBodyMenu:RouteTo()
    end)
    CategoriesPage:RegisterElement('button', {
        label = 'Clothing',
        style = {
        }
    }, function()
        ClothingCategoriesPage:RouteTo()
    end)

    --second page
    CategoriesPage:RegisterElement('header', {
        value = 'Clothing Selection',
        slot = "header",
        style = {}
    })
    CategoriesPage:RegisterElement('button', {
        label = "Go Back",
        style = {
        },
    }, function()
        
        MainCharacterPage:RouteTo()
    end)

    for k, v in pairs(CharacterConfig.Clothing.Clothes[Gender]) do
        ClothingCategoriesPage:RegisterElement('button', {
            label = k,
            style = {
            },
        }, function()
            if k == "Upper" then
                ActivePage = UpperClothingPage
                ActivePage:RouteTo()
                SwitchCam(Config.CameraCoords.creation.x - 0.4, Config.CameraCoords.creation.y,
                    Config.CameraCoords.creation.z + 0.4,
                    Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom - 30.0)
                CamZ = Config.CameraCoords.creation.z + 0.5
            elseif k == "Lower" then
                ActivePage = LowerClothingPage
                ActivePage:RouteTo()
                SwitchCam(Config.CameraCoords.creation.x - 0.4, Config.CameraCoords.creation.y,
                    Config.CameraCoords.creation.z - 0.2,
                    Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom - 30.0)
                CamZ = Config.CameraCoords.creation.z - 0.2
            elseif k == "Accessories" then
                ActivePage = AccClothingPage
                ActivePage:RouteTo()
                SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
                    Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
            end
            for index, key in pairs(CharacterConfig.Clothing.Clothes[Gender][k]) do
                table.insert(SelectedClothing, index)
                if SelectedClothing[index .. 'Category'] == nil then
                    CategoryElement = ActivePage:RegisterElement('slider', {
                        label = index,
                        start = 1,
                        min = 0,
                        max = #key.CategoryData,
                        steps = 1
                    }, function(data)
                        MainComponent = data.value

                        if MainComponent > 0 then
                            SelectedClothing[index .. 'Variant'] = SelectedClothing[index .. 'Variant']:update({
                                label = index .. ' variant',
                                value = 1,
                                max = #key.CategoryData[MainComponent], --#v.CategoryData[inputvalue],
                            })
                            AddComponent(PlayerPedId(), key.CategoryData[MainComponent][1].hash, index)
                            local type = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                            ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8,
                                key.CategoryData[MainComponent][1].hash, type, true)
                            SelectedClothingElements[index] = key.CategoryData[MainComponent][1].hash
                        else
                            Citizen.InvokeNative(0x0D7FFA1B2F69ED82, PlayerPedId(), SelectedClothingElements[index], 0, 0)
                            SelectedClothingElements[index] = nil
                            Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
                        end
                    end)
                    VariantElement = ActivePage:RegisterElement('slider', {
                        label = index .. ' variant',
                        start = 1,
                        min = 1,
                        max = 5, --#v.CategoryData[inputvalue],
                        steps = 1
                    }, function(data)
                        VariantComponent = data.value
                        if VariantComponent > 0 then
                            SelectedClothing[index .. 'Variant'] = SelectedClothing[index .. 'Variant']:update({
                                label = index .. ' variant',
                                max = #key.CategoryData[MainComponent], --#v.CategoryData[inputvalue],
                            })

                            AddComponent(PlayerPedId(), key.CategoryData[MainComponent][VariantComponent].hash, index)
                            local type = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
                            ActiveCatagory = Citizen.InvokeNative(0x5FF9A878C3D115B8,
                                key.CategoryData[MainComponent][VariantComponent].hash, type, true)
                            SelectedClothingElements[index] = key.CategoryData[MainComponent][VariantComponent].hash
                        end
                    end)
                    if Config.DyeClothes then
                        local Button = ActivePage:RegisterElement('button', {
                            label = "Dye your " .. index,
                            style = {
                            },
                        }, function()
                            ColorPage:RouteTo()
                            ColorClothing(ActiveCatagory, index)
                        end)
                        local Line = ActivePage:RegisterElement('line', {
                            slot = "content",
                            style = {}
                        })
                        Line = Line:update({})

                        Button = Button:update({})
                    end
                    -- Store your elements with unique keys so that we can easily retrieve these later when data needs to be updated. We are appenting strings so that it stays unique.
                    SelectedClothing[index .. 'Category'] = CategoryElement
                    SelectedClothing[index .. 'Variant'] = VariantElement
                    CategoryElement = CategoryElement:update({
                        label = index,
                        max = #key.CategoryData, --#v.CategoryData[inputvalue],
                    })
                    VariantElement = VariantElement:update({
                        label = index .. ' variant',
                        max = #key.CategoryData, --#v.CategoryData[inputvalue],
                    })
                    Line = ActivePage:RegisterElement('line', {
                        slot = "content",
                        style = {}
                    })
                    Line = Line:update({})
                end
            end
        end)
    end

    --third page
    UpperClothingPage:RegisterElement('header', {
        value = 'Clothing Selection',
        slot = "header",
        style = {}
    })
    UpperClothingPage:RegisterElement('subheader', {
        value = "These are the items and the variants",
        slot = "header",
        style = {}
    })
    UpperClothingPage:RegisterElement('button', {
        label = "Go Back",
        style = {},
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
        Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        ClothingCategoriesPage:RouteTo()
    end)
    UpperClothingPage:RegisterElement('pagearrows', {
        slot = 'content',
        total = ' Zoom Cam In',
        current = 'Zoom Cam Out ',
        style = {},
    }, function(data)
        if data.value == 'forward' then
            fov = fov - 1.0
            SetCamFov(CharacterCamera, fov)
        else
            fov = fov + 1.0
            SetCamFov(CharacterCamera, fov)
        end
    end)
    UpperClothingPage:RegisterElement('pagearrows', {
        slot = 'content',
        total = ' Move Cam Up',
        current = 'Move Cam Down ',
        style = {},
    }, function(data)
        if data.value == 'forward' then
            CamZ = CamZ + 0.1
            SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
        else
            print(CamZ)
            CamZ = CamZ - 0.1
            SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
        end
    end)
    UpperClothingPage:RegisterElement('pagearrows', {
        slot = 'content',
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

    --fourth page
    LowerClothingPage:RegisterElement('header', {
        value = 'Clothing Selection',
        slot = "header",
        style = {}
    })
    LowerClothingPage:RegisterElement('subheader', {
        value = "These are the items and the variants",
        slot = "header",
        style = {}
    })
    LowerClothingPage:RegisterElement('button', {
        label = "Go Back",
        style = {},
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
        Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        ClothingCategoriesPage:RouteTo()
    end)
    LowerClothingPage:RegisterElement('pagearrows', {
        slot = 'content',
        total = ' Zoom Cam In',
        current = 'Zoom Cam Out ',
        style = {},
    }, function(data)
        if data.value == 'forward' then
            fov = fov - 1.0
            SetCamFov(CharacterCamera, fov)
        else
            fov = fov + 1.0
            SetCamFov(CharacterCamera, fov)
        end
    end)
    LowerClothingPage:RegisterElement('pagearrows', {
        slot = 'content',
        total = ' Move Cam Up',
        current = 'Move Cam Down ',
        style = {},
    }, function(data)
        if data.value == 'forward' then
            CamZ = CamZ + 0.1
            SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
        else
            print(CamZ)
            CamZ = CamZ - 0.1
            SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
        end
    end)
    LowerClothingPage:RegisterElement('pagearrows', {
        slot = 'content',
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
    --fifth page
    AccClothingPage:RegisterElement('header', {
        value = 'Clothing Selection',
        slot = "header",
        style = {}
    })
    AccClothingPage:RegisterElement('subheader', {
        value = "These are the items and the variants",
        slot = "header",
        style = {}
    })
    AccClothingPage:RegisterElement('button', {
        label = "Go Back",
        style = {},
    }, function()
        SwitchCam(Config.CameraCoords.creation.x, Config.CameraCoords.creation.y, Config.CameraCoords.creation.z,
        Config.CameraCoords.creation.h, Config.CameraCoords.creation.zoom)
        ClothingCategoriesPage:RouteTo()
    end)
    AccClothingPage:RegisterElement('pagearrows', {
        slot = 'content',
        total = ' Zoom Cam In',
        current = 'Zoom Cam Out ',
        style = {},
    }, function(data)
        if data.value == 'forward' then
            fov = fov - 1.0
            SetCamFov(CharacterCamera, fov)
        else
            fov = fov + 1.0
            SetCamFov(CharacterCamera, fov)
        end
    end)
    AccClothingPage:RegisterElement('pagearrows', {
        slot = 'content',
        total = ' Move Cam Up',
        current = 'Move Cam Down ',
        style = {},
    }, function(data)
        if data.value == 'forward' then
            CamZ = CamZ + 0.1
            SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
        else
            print(CamZ)
            CamZ = CamZ - 0.1
            SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x - 0.2, Config.CameraCoords.creation.y, CamZ)
        end
    end)
    AccClothingPage:RegisterElement('pagearrows', {
        slot = 'content',
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

    ColorPage:RegisterElement('header', {
        value = 'My First Menu',
        slot = "header",
        style = {}
    })
    ColorPage:RegisterElement('subheader', {
        value = "First Page",
        slot = "header",
        style = {}
    })
    ColorPage:RegisterElement('button', {
        label = "Go Back",
        style = {},
    }, function()
        ColorElement1:unRegister()
        ColorElement2:unRegister()
        ColorElement3:unRegister()
        SelectedColoring = nil
        ClothingCategoriesPage:RouteTo()
    end)
    ColorPage:RegisterElement('bottomline', {
        slot = "header",
        style = {

        }
    })


    MyMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = MainCharacterPage,
    })
end)


CharInfoMenu = FeatherMenu:RegisterMenu('feather:characterinfo:menu', {
    top = '5%',
    left = '5%',
    ['720width'] = '500px',
    ['1080width'] = '600px',
    ['2kwidth'] = '700px',
    ['4kwidth'] = '900px',
    style = {
    },
    contentslot = {
        style = { --This style is what is currently making the content slot scoped and scrollable. If you delete this, it will make the content height dynamic to its inner content.
            ['height'] = '700px',
            ['width'] = '300px',
            ['min-height'] = '300px'
        }
    },
    draggable = false,
    canclose = false
})
local Name, Money, Job, Birthday, Description, ID, Img = {}, {}, {}, {}, {}, {}, {}
RegisterNetEvent('feather-character:CharacterSelectMenu', function(Info, CameraSpot, CharAmount, Clothing, Attributes)
    for k, v in ipairs(Info) do
        Name[k] = v.first_name .. " " .. v.last_name
        Money[k] = v.dollars
        Job[k] = v.job
        Birthday[k] = v.dob
        Description[k] = v.description
        ID[k] = v.id
        Img[k] = json.decode(v.img)
    end
    local CharacterSelectPage = CharInfoMenu:RegisterPage('first:page')

    local header = CharacterSelectPage:RegisterElement('header', {
        value = 'Character Menu',
        slot = "header",
        style = {}
    })
    CharacterSelectPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    local nametext = CharacterSelectPage:RegisterElement('textdisplay', {
        value = "Name: " .. Name[CameraSpot],
        style = {}
    })
    CharacterSelectPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    local moneytext = CharacterSelectPage:RegisterElement('textdisplay', {
        value = "Money: " .. Money[CameraSpot],
        style = {}
    })
    CharacterSelectPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    local jobtext = CharacterSelectPage:RegisterElement('textdisplay', {
        value = "Job: " .. Job[CameraSpot],
        style = {}
    })
    CharacterSelectPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    local dobtext = CharacterSelectPage:RegisterElement('textdisplay', {
        value = "Date of Birth: "
            .. '\n' .. ' ' .. Birthday[CameraSpot],
        style = {}
    })
    CharacterSelectPage:RegisterElement('line', {
        slot = "content",
        style = {}
    })
    local descriptext1 = CharacterSelectPage:RegisterElement('textdisplay', {
        value = "Character Description: ",
        style = {}
    })
    local descriptext2 = CharacterSelectPage:RegisterElement('textdisplay', {
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
            SwitchCam(Config.CameraCoords.charcamera[CameraSpot].x, Config.CameraCoords.charcamera[CameraSpot].y,
                Config.CameraCoords.charcamera[CameraSpot].z, Config.CameraCoords.charcamera[CameraSpot].h,
                Config.CameraCoords.charcamera[CameraSpot].zoom)
            TriggerEvent('feather-character:CharacterSelectMenu', Info, CameraSpot, CharAmount, Clothing, Attributes)
        else
            if CameraSpot == 1 then
                CameraSpot = CharAmount
            end
            if CameraSpot <= CharAmount then
                CameraSpot = CameraSpot - 1
            end
            SwitchCam(Config.CameraCoords.charcamera[CameraSpot].x, Config.CameraCoords.charcamera[CameraSpot].y,
                Config.CameraCoords.charcamera[CameraSpot].z, Config.CameraCoords.charcamera[CameraSpot].h,
                Config.CameraCoords.charcamera[CameraSpot].zoom)
            TriggerEvent('feather-character:CharacterSelectMenu', Info, CameraSpot, CharAmount, Clothing, Attributes)
        end
    end)
    CharacterSelectPage:RegisterElement('button', {
        label = "Select",
        style = {
        },
    }, function()
        if CameraSpot ~= nil then
            Spawned = false
            CleanupScript()
            LoadPlayer(CharModel)
            TriggerServerEvent('feather-character:InitiateCharacter', ID[CameraSpot])
            for category, hash in pairs(Clothing[CameraSpot]) do
                AddComponent(PlayerPedId(), hash, category)
            end
            for category, hash in pairs(Attributes[CameraSpot]) do
                AddComponent(PlayerPedId(), hash, category)
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
            },
        })
    end

    CharInfoMenu:Open({
        cursorFocus = true,
        menuFocus = true,
        startupPage = CharacterSelectPage,
    })
end)




function ColorClothing(ActiveCatagory, index)
    local componentIndex = GetComponentIndexByCategory(PlayerPedId(), ActiveCatagory)
    local drawable, albedo, normal, material = GetMetaPedAssetGuids(PlayerPedId(), componentIndex)
    local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(PlayerPedId(), componentIndex)

    Wait(250)
    if SelectedColoring == nil then
        ColorElement1 = ColorPage:RegisterElement('slider', {
            label = 'Color 1',
            start = 1,
            min = 1,
            max = 254, --#v.CategoryData[inputvalue],
            steps = 1
        }, function(data)
            Color1 = data.value
            if MainComponent > 0 then
                RemoveTagFromMetaPed(index)
                AddComponent(PlayerPedId(), SelectedClothingElements[index], nil)
                SetMetaPedTag(PlayerPedId(), drawable, albedo, normal, material, palette, Color1, tint1, tint2)
                UpdatePedVariation(PlayerPedId())
            end
        end)
        ColorElement2 = ColorPage:RegisterElement('slider', {
            label = 'Color 2',
            start = 1,
            min = 1,
            max = 254, --#v.CategoryData[inputvalue],
            steps = 1
        }, function(data)
            Color2 = data.value
            if MainComponent > 0 then
                RemoveTagFromMetaPed(index)
                AddComponent(PlayerPedId(), SelectedClothingElements[index], nil)
                SetMetaPedTag(PlayerPedId(), drawable, albedo, normal, material, palette, Color1, Color2, tint2)
                UpdatePedVariation(PlayerPedId())
            end
        end)
        ColorElement3 = ColorPage:RegisterElement('slider', {
            label = 'Color 3',
            start = 1,
            min = 1,
            max = 254, --#v.CategoryData[inputvalue],
            steps = 1
        }, function(data)
            Color3 = data.value
            if MainComponent > 0 then
                RemoveTagFromMetaPed(index)
                AddComponent(PlayerPedId(), SelectedClothingElements[index], nil)
                SetMetaPedTag(PlayerPedId(), drawable, albedo, normal, material, palette, Color1, Color2, Color3)
                UpdatePedVariation(PlayerPedId())
            end
        end)


        ColorElement1 = ColorElement1:update({
            label = "Color 1",
        })
        ColorElement2 = ColorElement2:update({
            label = "Color 2",
        })
        ColorElement3 = ColorElement3:update({
            label = "Color 3",
        })
    end
    SelectedColoring = true
end



--[[MenuData = {}
TriggerEvent("redemrp_menu_base:getData", function(call)
    MenuData = call
end)

RegisterNetEvent('redemrp_menu_base:updateSelectedItem')
AddEventHandler('redemrp_menu_base:updateSelectedItem', function(selectedItem)
    MenuData.ItemSelected = selectedItem
end)


function MakeupMenu()
    MenuData.CloseAll()
    local elements = {}
    for k, v in pairs(CharacterConfig.Attributes.OverlayAllLayers) do
        elements[#elements + 1] = {
            label = v.name,
        }
    end


    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',

        {
            title = 'Makeup Categories',
            align = Config.MenuAlign,
            elements = elements,
        },
        function(data, menu)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current then
                OpenMakeupMenu(data.current.label)
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

function OpenMakeupMenu(table)
    local selection = table
    MenuData.CloseAll()
    local elements = {}
    print(selection)

    -- *texture
    elements[#elements + 1] = {
        label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Texture',
        value = 1,
        min = 0,
        max = #CharacterConfig.Attributes.Makeup[selection],
        type = "slider",
        texture = value,

        desc = 'Texture',
        tag = "texture"
    }
    elements[#elements + 1] = {
        label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Opacity',
        value = 1.0,
        min = 0,
        max = 0.9,
        hop = 0.1,
        type = "slider",
        opacity = value,

        desc = 'Opacity',
        tag = "opacity"
    }
    --*Color
    local ColorValue = 0
    for x, color in pairs(CharacterConfig.Attributes.ColorPalettes[selection]) do
        if joaat(color) == CharacterConfig.Attributes.OverlayAllLayers[selection] then
            ColorValue = x
        end
    end

    elements[#elements + 1] = {
        label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Color',
        value = ColorValue,
        min = 0,
        max = 25,
        comp = CharacterConfig.Attributes.ColorPalettes[selection],
        type = "slider",
        palette = value,

        desc = 'Color',
        tag = "color"
    }

    elements[#elements + 1] = {
        label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Tint 1',
        value = 0,
        min = 0,
        max = 254,
        comp = CharacterConfig.Attributes.ColorPalettes[selection],
        type = "slider",
        primarytint = value,
        desc = 'Color',
        tag = "color"
    }
    elements[#elements + 1] = {
        label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Tint 2',
        value = 0,
        min = 0,
        max = 254,
        comp = CharacterConfig.Attributes.ColorPalettes[selection],
        type = "slider",
        secondarytint = value,
        desc = 'Color',
        tag = "color"
    }
    elements[#elements + 1] = {
        label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Tint 3',
        value = 0,
        min = 0,
        max = 254,
        comp = CharacterConfig.Attributes.ColorPalettes[selection],
        type = "slider",
        tertiarytint = value,

        desc = 'Color',
        tag = "color"
    }
    if selection == "lipsticks" then
        variationvalue = 15
    elseif selection == "shadows" then
        variationvalue = 5
    elseif selection == "eyeliners" then
        variationvalue = 7
    end

    if selection == "lipsticks" or selection == "shadows" or selection == "eyeliners" then
        --*Variant
        elements[#elements + 1] = {
            label = CharacterConfig.Attributes.OverlayAllLayers[selection].name .. ' ' .. 'Variation',
            value = 1,
            min = 0,
            max = variationvalue,
            type = "slider",
            comp = CharacterConfig.Attributes.ColorPalettes[selection],
            variant = value,
            desc = 'variant',
            tag = "variant"
        }
    end

    --* opacity

    elements[#elements + 1] = {
        label = "Add",
    }


    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = "makeup title",
            align = Config.Align,
            elements = elements,
            lastmenu = 'OpenMakeupMenu',

        },

        function(data, menu)
            --* Go back
            if (data.current == "backup") then
                _G[data.trigger](table)
            end
            if data.current.label == "Add" then
                if selection == "blush" then
                    print(elements.texture, data.current.palette, data.current.primarytint, data.current.secondarytint)
                    ChangeOverlay(CharacterConfig.Attributes.OverlayAllLayers[selection].name, 1, data.current.texture, 0, 0, 0, 1.0, 0,
                        data.current.palette, data.current.primarytint, data.current.secondarytint,
                        data.current.tertiarytint, 0, data.current.opacity)
                end
            end
        end, function(data, menu)
            menu.close()
            MakeupMenu()
        end)
end

function ClothingCategories()
    MenuData.CloseAll()
    local Elements = {}

    if IsPedMale(PlayerPedId()) then
        for i, v in pairs(CharacterConfig.Clothing.Clothes.Male) do
            Elements[#Elements + 1] = {
                label = v.CategoryName,
                Clothes = v,
                Category = i,
            }
        end
    else
        for i, v in pairs(CharacterConfig.Clothing.Clothes.Female) do
            Elements[#Elements + 1] = {
                label = v.CategoryName,
                Clothes = v,
                Category = i,
            }
        end
    end

    if IsPedMale then
        ClothingTable = CharacterConfig.Clothing.Clothes.Male
    else
        ClothingTable = CharacterConfig.Clothing.Clothes.Female
    end

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',

        {
            title = 'Male Clothing Categories',
            align = Config.MenuAlign,
            elements = Elements,
        },
        function(data, menu)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.label then
                ClothMenu(data.current, #ClothingTable[data.current.Category])
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

function ClothMenu(sentdata, maxamount)
    MenuData.CloseAll()
    local Elements = {
        {
            label = sentdata.label,
            type = 'slider',
            value = 0,
            min = 0,
            max = maxamount,
            -- desc = '',
        },

    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = 'Male Clothing Menu',
            align = Config.MenuAlign,
            elements = Elements,
            lastmenu = 'ClothingCategories',
        },

        function(data, menu)
            if data.current.value == 0 then
                ExecuteCommand('rc')
                menu.setElements(Elements)
                menu.refresh()
            else
                Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(),
                    sentdata.Clothes[tostring(data.current.value)][1].hash, true, true, true)
                Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0)
            end
            if #sentdata.Clothes[tostring(data.current.value)] > 1 then
                local Elements1 = {
                    {
                        label = sentdata.label,
                        type = 'slider',
                        value = data.current.value,
                        min = 0,
                        max = maxamount,
                        -- desc = '',
                    },
                    {
                        label = 'test',
                        type = 'slider',
                        value = 0,
                        min = 0,
                        max = maxamount,
                        -- desc = '',
                    },
                }
                menu.setElements(Elements1)
                menu.refresh()
            end
        end, function(data, menu)
            menu.close()
            ClothingCategories()
        end
    )
end

-- Devmode Area
if Config.DevMode == true then
    -- Open Command
    RegisterCommand('length', function()
        print(json.encode(CharacterConfig.Clothing.Clothes.Male.RingLh))
    end)

    RegisterCommand('clothes', function()
        ClothingCategories()
    end)

    RegisterCommand('makeup', function()
        MakeupMenu()
    end)
end


]]

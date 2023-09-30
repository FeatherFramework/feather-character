MenuData = {}
TriggerEvent("redemrp_menu_base:getData", function(call)
    MenuData = call
end)

-- Open Command
RegisterCommand('length', function()
    print(json.encode(Clothes.Male.RingLh))
end)

RegisterCommand('clothes', function()
    ClothingCategories()
end)

RegisterCommand('makeup', function()
    MakeupMenu()
end)

RegisterNetEvent('redemrp_menu_base:updateSelectedItem')
AddEventHandler('redemrp_menu_base:updateSelectedItem', function(selectedItem)
    MenuData.ItemSelected = selectedItem
end)


function MakeupMenu()
    MenuData.CloseAll()
    local elements = {}
    for k, v in pairs(overlay_all_layers) do
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
                label = overlay_all_layers[selection].name .. ' ' .. 'Texture',
                value = 1,
                min = 0,
                max = #Makeup[selection],
                type = "slider",
                texture = value,

                desc = 'Texture',
                tag = "texture"
            }
            elements[#elements + 1] = {
                label = overlay_all_layers[selection].name .. ' ' .. 'Opacity',
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
            for x, color in pairs(ConfigChar.color_palettes[selection]) do
                if joaat(color) == overlay_all_layers[selection] then
                    ColorValue = x
                end
            end

             elements[#elements + 1] = {
                label = overlay_all_layers[selection].name .. ' ' .. 'Color',
                value = ColorValue,
                min = 0,
                max = 25,
                comp = ConfigChar.color_palettes[selection],
                type = "slider",
                palette = value,

                desc = 'Color',
                tag = "color"
            }

            elements[#elements + 1] = {
                label = overlay_all_layers[selection].name .. ' ' .. 'Tint 1',
                value = 0,
                min = 0,
                max = 254,
                comp = ConfigChar.color_palettes[selection],
                type = "slider",
                primarytint = value,
                desc = 'Color',
                tag = "color"
            }
            elements[#elements + 1] = {
                label = overlay_all_layers[selection].name .. ' ' .. 'Tint 2',
                value = 0,
                min = 0,
                max = 254,
                comp = ConfigChar.color_palettes[selection],
                type = "slider",
                secondarytint = value,
                desc = 'Color',
                tag = "color"
            }
            elements[#elements + 1] = {
                label = overlay_all_layers[selection].name .. ' ' .. 'Tint 3',
                value = 0,
                min = 0,
                max = 254,
                comp = ConfigChar.color_palettes[selection],
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
                    label = overlay_all_layers[selection].name .. ' ' .. 'Variation',
                    value = 1,
                    min = 0,
                    max = variationvalue,
                    type = "slider",
                    comp = ConfigChar.color_palettes[selection],
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
                    print(elements.texture,data.current.palette,data.current.primarytint,data.current.secondarytint)
                ChangeOverlay(overlay_all_layers[selection].name,1,data.current.texture,0,0,0,1.0,0,
                data.current.palette,data.current.primarytint,data.current.secondarytint,
                data.current.tertiarytint, 0,data.current.opacity)

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
        for i, v in pairs(Clothes.Male) do
            Elements[#Elements + 1] = {
                label = v.CategoryName,
                Clothes = v,
                Category = i,
            }
        end
    else
        for i, v in pairs(Clothes.Female) do
            Elements[#Elements + 1] = {
                label = v.CategoryName,
                Clothes = v,
                Category = i,
            }
        end
    end

    if IsPedMale then
        ClothingTable = Clothes.Male
    else
        ClothingTable = Clothes.Female
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




--TODO: Remove this file once ui is done. This will be replaced.

MenuData = {}
TriggerEvent("redemrp_menu_base:getData", function(call)
    MenuData = call
end)

-- Open Command
RegisterCommand('length', function()
    print(json.encode(Clothes.Male.RingLh))
end)

RegisterCommand('openMenu', function()
    ClothingCategories()
end)

RegisterNetEvent('redemrp_menu_base:updateSelectedItem')
AddEventHandler('redemrp_menu_base:updateSelectedItem', function(selectedItem)
    MenuData.ItemSelected = selectedItem
    print(MenuData.ItemSelected)
end)


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

    Elements[#Elements + 1] = {
        label = 'Buy',
        value = 'Buy',
    }

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

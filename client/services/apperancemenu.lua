-- TODO: REMOVE ALL THIS STUFF AS MENUAPI/REDEMTP_MENU_BASE WILL NOT BE NEEDED.
FeatherMenu = exports['feather-menu'].initiate()

MyMenu = FeatherMenu:RegisterMenu('feather:character:menu', {
    top = '40%',
    left = '20%',
    ['720width'] = '500px',
    ['1080width'] = '600px',
    ['2kwidth'] = '700px',
    ['4kwidth'] = '900px',
    style = {
        -- ['height'] = '500px'
        -- ['border'] = '5px solid white',
        -- ['background-image'] = 'none',
        -- ['background-color'] = '#515A5A'
    },
    contentslot = {
        style = { --This style is what is currently making the content slot scoped and scrollable. If you delete this, it will make the content height dynamic to its inner content.
            ['height'] = '500px',
            ['width'] = '400px',
            ['min-height'] = '500px'
        }
    },
    draggable = true,
    canclose = true
})



MainAppearanceMenu = MyMenu:RegisterPage('appearance:page')

local EyesPage, HairandBeardPage, HairCategoryPage = MyMenu:RegisterPage('eyes:page'),
    MyMenu:RegisterPage('hair:page'),
    MyMenu:RegisterPage('haircat:page')

local Gender = GetGender()

if IsPedMale(PlayerPedId()) then
    HairSelection = HairandBeards[Gender]
else
    HairSelection = HairandBeards[Gender]
end

SelectedAttributes = {}   -- This can keep track of what was selected data wise
SelectedAttributeElements = {} --This table keeps track of your clothing elements


MainAppearanceMenu:RegisterElement('header', {
    value = 'My First Menu',
    slot = "header",
    style = {}
})
MainAppearanceMenu:RegisterElement('subheader', {
    value = "First Page",
    slot = "header",
    style = {}
})

MainAppearanceMenu:RegisterElement('button', {
    label = 'Hair',
    style = {
    }
}, function()
    HairCategoryPage:RouteTo()
end)

for key, v in pairs(FeatureNames) do
    MainAppearanceMenu:RegisterElement('button', {
        label = key,
        style = {
        }
    }, function()
        if key == 'Eyes' then
            ActivePage = EyesPage
            ActivePage:RouteTo()
        end
    end)
end
MainAppearanceMenu:RegisterElement('button', {
    label = "Save Appearance",
    style = {
    }
}, function()
    print(json.encode(SelectedAttributeElements))
    TriggerServerEvent('feather-character:UpdateAttributeDB', SelectedAttributeElements)
end)

MainAppearanceMenu:RegisterElement('button', {
    label = "Go Back",
    style = {
    },
}, function()
    MainCharacterPage:RouteTo()
end)

--second page
EyesPage:RegisterElement('header', {
    value = 'My First Menu',
    slot = "header",
    style = {}
})
EyesPage:RegisterElement('subheader', {
    value = "First Page",
    slot = "header",
    style = {}
})
for key, v in pairs(FeatureNames.Eyes) do
    EyesPage:RegisterElement('button', {
        label = v,
        style = {
        }
    }, function()

    end)
end

--Hair page
HairCategoryPage:RegisterElement('header', {
    value = 'My First Menu',
    slot = "header",
    style = {}
})
HairCategoryPage:RegisterElement('subheader', {
    value = "First Page",
    slot = "header",
    style = {}
})
HairCategoryPage:RegisterElement('button', {
    label = "Go Back",
    style = {
    },
}, function()
    MainAppearanceMenu:RouteTo()
end)
for key, v in pairs(HairSelection) do
    HairCategoryPage:RegisterElement('button', {
        label = key,
        style = {
        }
    }, function()
        if key == "hair" then
            ActivePage = HairandBeardPage
            ActivePage:RouteTo()
        elseif key == "beard" then
            ActivePage = HairandBeardPage
            ActivePage:RouteTo()
        end
        table.insert(SelectedAttributes, key)
        if SelectedAttributes[key .. 'Category'] == nil then
            CategoryElement = ActivePage:RegisterElement('slider', {
                label = value,
                start = 0,
                min = 0,
                max = #HairSelection[key],
                steps = 1
            }, function(data)
                MainComponent = data.value
                if VariantComponent == nil then
                    VariantComponent = 1
                end
                if MainComponent > 0 then
                    SelectedAttributes[key .. 'Variant'] = SelectedAttributes[key .. 'Variant']:update({
                        label = key .. ' variant',
                        max = #HairSelection[key][MainComponent], --#v.CategoryData[inputvalue],
                    })
                    AddComponent(PlayerPedId(), HairSelection[key][MainComponent][VariantComponent].hash, key)
                    SelectedAttributeElements[key] = HairSelection[key][MainComponent][1].hash

                    TextElement = TextElement:update({
                        value = HairSelection[key][MainComponent][VariantComponent].color
                    })
                else
                    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, PlayerPedId(), ActiveCatagory, 0, 0)
                    Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
                end
            end)

            VariantElement = ActivePage:RegisterElement('slider', {
                label = key .. ' variant',
                start = 1,
                min = 0,
                max = 5, --#v.CategoryData[inputvalue],
                steps = 1
            }, function(data)
                VariantComponent = data.value
                if VariantComponent > 0 then
                    SelectedAttributes[key .. 'Variant'] = SelectedAttributes[key .. 'Variant']:update({
                        label = key .. ' variant',
                        max = #HairSelection[key][MainComponent], --#v.CategoryData[inputvalue],
                    })

                    AddComponent(PlayerPedId(), HairSelection[key][MainComponent][VariantComponent].hash, key)
                    TextElement = TextElement:update({
                        value = HairSelection[key][MainComponent][VariantComponent].color
                    })
                else
                    Citizen.InvokeNative(0xDF631E4BCE1B1FC4, PlayerPedId(), ActiveCatagory, 0, 0)
                    Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- Refresh PedVariation
                end
            end)

            -- Store your elements with unique keys so that we can easily retrieve these later when data needs to be updated. We are appenting strings so that it stays unique.
            SelectedAttributes[key .. 'Category'] = CategoryElement
            SelectedAttributes[key .. 'Variant'] = VariantElement
            CategoryElement = CategoryElement:update({
                label = key,
                max = #HairSelection[key], --#v.CategoryData[inputvalue],
            })

            VariantElement = VariantElement:update({
                label = key .. ' variant',
                max = #HairSelection[key], --#v.CategoryData[inputvalue],
            })
        end
        TextElement = HairandBeardPage:RegisterElement('textdisplay', {
            value = 'test',
            style = {}
        })
    end)
end


HairandBeardPage:RegisterElement('header', {
    value = 'My First Menu',
    slot = "header",
    style = {}
})
HairandBeardPage:RegisterElement('subheader', {
    value = "First Page",
    slot = "header",
    style = {}
})
HairandBeardPage:RegisterElement('bottomline', {
    slot = "header",
    style = {

    }
})
HairandBeardPage:RegisterElement('button', {
    label = "Go Back",
    style = {
    },
}, function()
    HairCategoryPage:RouteTo()
    CategoryElement:unRegister()
    VariantElement:unRegister()
    TextElement:unRegister()
    for k, v in pairs(HairSelection) do
        SelectedAttributes[k .. 'Category'] = nil
    end
end)



RegisterNetEvent('FeatherMenu:closed', function(data)
    MenuOpened = false
    Header1:unRegister()
    SubHeader1:unRegister()
end)


function TableToString(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. TableToString(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end




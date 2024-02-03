MainBodyMenu = MyMenu:RegisterPage('mainbody:page')

local HeightPage, BodyPage = MyMenu:RegisterPage('height:page'),MyMenu:RegisterPage('body:page')


MainBodyMenu:RegisterElement('header', {
    value = 'My First Menu',
    slot = "header",
    style = {}
})
MainBodyMenu:RegisterElement('subheader', {
    value = "First Page",
    slot = "header",
    style = {}
})
MainBodyMenu:RegisterElement('bottomline', {
    slot = "header",
    style = {

    }
})

MainBodyMenu:RegisterElement('button', {
    label = "Go Back",
    style = {
    },
}, function()
    BodySlider:unRegister()
    ChestSlider:unRegister()
    WaistSlider:unRegister()
    HeightSlider:unRegister()
    CategoriesPage:RouteTo()
 
end)

function MakeBodySliders ()
    if SelectedBody ~= nil then

        HeightSlider = MainBodyMenu:RegisterElement('arrows', {
            label = "Height",
            start = 1,
            options = Config.Heights
        }, function(data)
            if data.value == 1 then
                data.value = 1.0
            end

            SetPedScale(PlayerPedId(),data.value)

            -- This gets triggered whenever the arrow selected value changes
            print(TableToString(data.value))
        end)

        BodySlider= MainBodyMenu:RegisterElement('arrows', {
            label = "Body Size",
            start = 1,
            options = {
               1,2,3,4,5
            },

        }, function(data)
            -- This gets triggered whenever the arrow selected value changes
            local Size = data.value
            EquipMetaPedOutfit(PlayerPedId(),BODYTYPES[Size])
        end)

        ChestSlider= MainBodyMenu:RegisterElement('arrows', {
            label = "Chest Size",
            start = 1,
            options = {
               1,2,3,4,5,6,7,8,9,10
            },

        }, function(data)
            -- This gets triggered whenever the arrow selected value changes
            local Size = data.value
            EquipMetaPedOutfit(PlayerPedId(),CHESTTYPE[Size])
        end)

        WaistSlider= MainBodyMenu:RegisterElement('arrows', {
            label = "Waist Size",
            start = 1,
            options = {
               1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
            },

        }, function(data)
            -- This gets triggered whenever the arrow selected value changes
            local Size = data.value
            EquipMetaPedOutfit(PlayerPedId(),WAISTTYPES[Size])
        end)



    end
end

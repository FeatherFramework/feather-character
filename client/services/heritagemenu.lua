MainHeritageMenu = MyMenu:RegisterPage('heritage:page')

MainHeritageMenu:RegisterElement('header', {
    value = 'My First Menu',
    slot = "header",
    style = {}
})
MainHeritageMenu:RegisterElement('subheader', {
    value = "First Page",
    slot = "header",
    style = {}
})

MainHeritageMenu:RegisterElement('bottomline', {
    slot = "footer",
    style = {

    }
})
MainHeritageMenu:RegisterElement('button', {
    label = "Go Back",
    slot = 'footer',

    style = {
    },
}, function()
    MainAppearanceMenu:RouteTo()
    HeritageSlider:unRegister()
    HeritageDisplay:unRegister()
    HeadVariantSlider:unRegister()
    BodyVariantSlider:unRegister()
    LegVariantSlider:unRegister()
end)

function MakeHeritageSliders ()
    if SelectedHeritage ~= nil then
        HeritageSlider = MainHeritageMenu:RegisterElement('slider', {
            label = "Heritage",
            start = 1,
            min = 1,
            max = #CharacterConfig.General.DefaultChar[Gender],
            steps = 1,
        }, function(data)
            Race = data.value
            local Head = tonumber("0x" ..CharacterConfig.General.DefaultChar[Gender][Race].Heads[1])
            local Body = tonumber("0x" ..CharacterConfig.General.DefaultChar[Gender][Race].Body[1])
            local Legs = tonumber("0x" ..CharacterConfig.General.DefaultChar[Gender][Race].Legs[1])
            local Albedo = tonumber(CharacterConfig.General.DefaultChar[Gender][Race].HeadTexture[1])
            SelectedAttributeElements['Albedo'] = Albedo

            -- This gets triggered whenever the sliders selected value changes
            AddComponent(PlayerPedId(),Head,nil)
            AddComponent(PlayerPedId(),Body,nil)
            AddComponent(PlayerPedId(),Legs,nil)
            HeritageDisplay:update({
                value = CharacterConfig.General.DefaultChar[Gender][Race].label,
            })
            HeadVariantSlider = HeadVariantSlider:update({
                value = 1,
                max = #CharacterConfig.General.DefaultChar[Gender][Race].Heads,
            })
            BodyVariantSlider = BodyVariantSlider:update({
                value = 1,
                max = #CharacterConfig.General.DefaultChar[Gender][Race].Body,
            })
            LegVariantSlider = LegVariantSlider:update({
                value = 1,
                max = #CharacterConfig.General.DefaultChar[Gender][Race].Legs,
            })
        end)
        HeritageDisplay = MainHeritageMenu:RegisterElement('textdisplay', {
            value = "European",
            style = {}
        })
        HeadVariantSlider = MainHeritageMenu:RegisterElement('slider', {
            label = "Head Variations",
            start = 1,
            min = 1,
            max = #CharacterConfig.General.DefaultChar[Gender][1],
            steps = 1,
        }, function(data)
            local value = data.value
            local Head
            if Race == nil then
                 Head = tonumber("0x" ..CharacterConfig.General.DefaultChar[Gender][1].Heads[value])
            else
                 Head = tonumber("0x" ..CharacterConfig.General.DefaultChar[Gender][Race].Heads[value])
            end
            AddComponent(PlayerPedId(),Head,nil)
            SelectedAttributeElements['Head'] = Head
            -- This gets triggered whenever the sliders selected value changes
        end)
        BodyVariantSlider = MainHeritageMenu:RegisterElement('slider', {
            label = "Body Variations",
            start = 1,
            min = 1,
            max = #CharacterConfig.General.DefaultChar[Gender][1],
            steps = 1,
        }, function(data)
            local value = data.value
            local Body
            if Race == nil then
                Body = tonumber("0x" ..CharacterConfig.General.DefaultChar[Gender][1].Body[value])
            else
                Body = tonumber("0x" ..CharacterConfig.General.DefaultChar[Gender][Race].Body[value])
            end
            AddComponent(PlayerPedId(),Body,nil)
            SelectedAttributeElements['Body'] = Body

            -- This gets triggered whenever the sliders selected value changes
        end)
        LegVariantSlider = MainHeritageMenu:RegisterElement('slider', {
            label = "Leg Variations",
            start = 1,
            min = 1,
            max = #CharacterConfig.General.DefaultChar[Gender][1],
            steps = 1,
        }, function(data)
            local value = data.value
            local Legs
            if Race == nil then
                Legs = tonumber("0x" ..CharacterConfig.General.DefaultChar[Gender][1].Legs[value])
            else
                Legs = tonumber("0x" ..CharacterConfig.General.DefaultChar[Gender][Race].Legs[value])
            end
            AddComponent(PlayerPedId(),Legs,nil)
            SelectedAttributeElements['Legs'] = Legs

            -- This gets triggered whenever the sliders selected value changes
        end)
    
        HeritageSlider = HeritageSlider:update({
            label = 'Heritage',
        })

        
    end
end


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
    slot = "header",
    style = {

    }
})
MainHeritageMenu:RegisterElement('button', {
    label = "Go Back",
    style = {
    },
}, function()
    MainAppearanceMenu:RouteTo()
    HeritageSlider:unRegister()
    HeadVariantSlider:unRegister()
    BodyVariantSlider:unRegister()
    LegVariantSlider:unRegister()
    print(json.encode(SelectedAttributes))
end)
SelectedHeritage = nil



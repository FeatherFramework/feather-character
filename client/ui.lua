UIState = false

local function getCharacterClothingCategories()
    local Elements = {}

    if IsPedMale(PlayerPedId()) then
        return Clothes.Male
    end

    -- Default to female cause woman rule!
    return Clothes.Female
end

local function setNuiData()
    SendNUIMessage({
        type = 'toggle',
        visible = UIState,
        config = {},
        clothing = getCharacterClothingCategories()
    })
end

function SetUIState(state)
    UIState = state
    setNuiData()
end

function ToggleUIState()
    UIState = not UIState
    setNuiData()
end

RegisterCommand('ToggleCMenu', function ()
    ToggleUIState()
end)

RegisterNUICallback('UpdateState', function(args, nuicb)
    UIState = args.state
    SetNuiFocus(UIState, UIState)
    nuicb('ok')
end)

RegisterNUICallback('SelectedClothes', function(args, nuicb)
    -- DO SOMETHING HERE! xD
    print("Clothing has changed!")
    feather.Print(args.data)
    nuicb('ok')
end)

RegisterNUICallback('SelectedDetails', function(args, nuicb)
    -- DO SOMETHING HERE! xD
    print("Character Details has changed!")
    feather.Print(args.data)
    nuicb('ok')
end)
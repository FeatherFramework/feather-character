UIState = false

local ActiveCharacterData = {}

local function setNuiData()
    SendNUIMessage({
        type = 'toggle',
        visible = UIState,
        config = {
            defaults = Config.defaults
        }
    })
end

local function sendUIClothingData(sex)
    local clothing = {}

    if sex == "male" then
        clothing = Clothes.Male
    else
        clothing = Clothes.Female
    end

    SendNUIMessage({
        type = 'updateclothing',
        clothing = clothing
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
    print(args.data.variant.hash)

    nuicb('ok')
end)

RegisterNUICallback('SelectedDetails', function(args, nuicb)
    -- DO SOMETHING HERE! xD
    print("Character Details has changed!")
    feather.Print(args.data)

    -- args.data contains the following
    -- {
    --     firstname,
    --     lastname,
    --     dob,
    --     sex
    -- }

    ActiveCharacterData.firstname = args.data.firstname
    ActiveCharacterData.lastname = args.data.lastname
    ActiveCharacterData.dob = args.data.dob
    ActiveCharacterData.sex = args.data.sex

    -- The character details have been set, lets now send the proper Sex based clothing options to the UI for selection by player.
    sendUIClothingData(args.data.sex)
    
    nuicb('ok')
end)
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

function SetUIState(state)
    UIState = state
    setNuiData()
end

function ToggleUIState()
    UIState = not UIState
    setNuiData()
end

RegisterCommand('ToggleCMenu', function()
    ToggleUIState()
end)

RegisterNUICallback('UpdateState', function(args, nuicb)
    UIState = args.state
    SetNuiFocus(UIState, UIState)
    nuicb('ok')
end)

RegisterNUICallback('SelectedClothes', function(args, nuicb)
    UpdateCharacterClothing(args)
    nuicb('ok')
end)

RegisterNUICallback('SetSex', function(args, nuicb)
    SetSex(args.data.sex)
end)


RegisterNUICallback('SelectedDetails', function(args, cb)
    
    SaveCharacterDetails(args)
    -- The character details have been set, lets now send the proper Sex based clothing options to the UI for selection by player.
    local clothing = {}

    if args.data.sex == "male" then
        clothing = CharacterConfig.Clothing.Clothes.Male
    else
        clothing = CharacterConfig.Clothing.Clothes.Female
    end

    cb(json.encode({
        clothing = clothing
    }))
end)

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

--TODO: Migrate this to the nuicallback callback/response
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

local function sendUIAttributeData(sex)
 
end

local function sendUIMakeupData(sex)

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
        clothing = Clothes.Male
    else
        clothing = Clothes.Female
    end

    cb(json.encode({
        clothing = clothing
    }))
end)

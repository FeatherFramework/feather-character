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


RegisterNUICallback('SelectedDetails', function(args, nuicb)
    SaveCharacterDetails(args)

    -- The character details have been set, lets now send the proper Sex based clothing options to the UI for selection by player.
    sendUIClothingData(args.data.sex)


    -- TODO: Save the current state of character and that its still  in creation. Then have the UI pick back up where it left off.
    if Config.DevMode == false then
        TriggerServerEvent('feather-character:SendDetailsToDB', ActiveCharacterData, json.encode(ClothesTable))        
    end

    nuicb('ok')
end)

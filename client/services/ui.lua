UIState = false

local ActiveCharacterData = {}
local ClothesTable = {}

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
    -- DO SOMETHING HERE! xD
    print("Clothing has changed!")
    FeatherCore.Print(args.data)
    print(args.data.variant.hash)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), args.data.variant.hash, true, true, true)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0)
    nuicb('ok')
    print(args.data.primary.id)
    if args.data.primary.id == 0 then
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 4, 0) -- outfits

        Citizen.InvokeNative(0x0D7FFA1B2F69ED82, PlayerPedId(), args.data.variant.hash, 0, 0)
        DefaultPedSetup(PlayerPedId(), ActiveCharacterData.sex)
    end
    if not ClothesTable[args.data.variant.hash] then
        ClothesTable[args.data.variant.hash] = 1
    elseif ClothesTable[args.data.variant.hash] then
        ClothesTable[args.data.variant.hash] = nil
    end

    --table.insert(ClothesTable, args.data.variant.hash)
    print(json.encode(ClothesTable))
end)

RegisterNUICallback('SetSex', function(args, nuicb)
    SetSex(args.data.sex)
end)


RegisterNUICallback('SelectedDetails', function(args, nuicb)
    ActiveCharacterData.firstname = args.data.firstname
    ActiveCharacterData.lastname = args.data.lastname
    ActiveCharacterData.dob = args.data.dob
    ActiveCharacterData.sex = args.data.sex
    SetSex(ActiveCharacterData.sex)
    TriggerServerEvent('feather-character:SendDetailsToDB', ActiveCharacterData, json.encode(ClothesTable))

    -- The character details have been set, lets now send the proper Sex based clothing options to the UI for selection by player.
    sendUIClothingData(args.data.sex)

    nuicb('ok')
end)

function LoadModel(sex)
    RequestModel(sex)
    while not HasModelLoaded(sex) do
        Wait(10)
    end
end

function UpdatePedVariation(ped)
    Citizen.InvokeNative(0xAAB86462966168CE, ped, true)                           -- UNKNOWN "Fixes outfit"- always paired with _UPDATE_PED_VARIATION
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false) -- _UPDATE_PED_VARIATION
end

function AddComponent(ped, comp, category)
    if category ~= nil then
        RemoveTagFromMetaPed(category)
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, comp, false, true, true)
    Citizen.InvokeNative(0x66b957aac2eaaeab, ped, comp, 0, 0, 1, 1) -- _UPDATE_SHOP_ITEM_WEARABLE_STATE
    Citizen.InvokeNative(0xAAB86462966168CE, ped, 1)
    UpdatePedVariation(ped)
end

function RemoveTagFromMetaPed(category)
    if category == "Coat" then
        Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), ClothingCategories.CoatClosed, 0)
    end
    if category == "CoatClosed" then
        Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), ClothingCategories.Coat, 0)
    end
    if category == "Pant" then
        if not IsPedMale(PlayerPedId()) then
            Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), ClothingCategories.Skirt, 0)
        end
        Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), ClothingCategories.Boots, 0)
    end
    if category == "Skirt" and not IsPedMale(PlayerPedId()) then
        Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), ClothingCategories.Pant, 0)
    end

    Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), ClothingCategories[category], 0)
    UpdatePedVariation(PlayerPedId())
end

function DefaultPedSetup(ped, male)
    local compEyes
    local compBody
    local compHead
    local compLegs

    if male then
        --Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, 0, true)
        compEyes = 612262189
        compBody = tonumber("0x" .. ConfigChar.DefaultChar.Male[1].Body[1])
        compHead = tonumber("0x" .. ConfigChar.DefaultChar.Male[1].Heads[1])
        compLegs = tonumber("0x" .. ConfigChar.DefaultChar.Male[1].Legs[1])
    else
        EquipMetaPedOutfitPreset(ped, 7, true)
        compEyes = 928002221
        compBody = tonumber("0x" .. ConfigChar.DefaultChar.Female[1].Body[1])
        compHead = tonumber("0x" .. ConfigChar.DefaultChar.Female[1].Heads[1])
        compLegs = tonumber("0x" .. ConfigChar.DefaultChar.Female[1].Legs[1])
        --ApplyShopItemToPed(ped, `CLOTHING_ITEM_F_BODIES_LOWER_001_V_001`, true, true)
        --ApplyShopItemToPed(ped, `CLOTHING_ITEM_F_BODIES_UPPER_001_V_001`, true, true)
    end
    ReadyToRender(ped)
    AddComponent(ped, compBody)
    AddComponent(ped, compLegs)
    AddComponent(ped, compHead)
    AddComponent(ped, compEyes)
    UpdatePedVariation(ped)
end

function ReadyToRender(ped)
    Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
    while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped) do
        Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
        Wait(0)
    end
end

function EquipMetaPedOutfitPreset(ped, outfitPresetIndex, toggle)
    Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, outfitPresetIndex, toggle)
end

function IsPedReadyToRender(ped)
    return Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
end

function ResetPedComponents(ped)
    Citizen.InvokeNative(0x0BFA1BD465CDFEFD, ped)
end

function ApplyShopItemToPed(ped, shopItemHash, immediately, isMultiplayer)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, shopItemHash, immediately, isMultiplayer, false)
end

function SetSex(sex)
    if sex == 'male' then
        LoadModel('mp_male')
        SetPlayerModel(PlayerId(), joaat('mp_male'), false)
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 4, 0) -- outfits
        DefaultPedSetup(PlayerPedId(), true)
    else
        LoadModel('mp_female')
        SetPlayerModel(PlayerId(), joaat('mp_female'), false)
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 2, 0) -- outfits
        DefaultPedSetup(PlayerPedId(), false)
    end
end
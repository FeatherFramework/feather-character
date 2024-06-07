function GetGender()
    if not IsPedMale(PlayerPedId()) then
        return "Female"
    end
    return "Male"
end

function UpdatePedVariation(ped)
    Citizen.InvokeNative(0xAAB86462966168CE, ped, true)                           -- UNKNOWN "Fixes outfit"- always paired with _UPDATE_PED_VARIATION
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false) -- _UPDATE_PED_VARIATION
end

function AddComponent(ped, comp, category)
    if category ~= nil then
        RemoveTagFromMetaPed(category)
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, comp, true, true, false)
    Citizen.InvokeNative(0x66b957aac2eaaeab, ped, comp, 0, 0, 1, 1) -- _UPDATE_SHOP_ITEM_WEARABLE_STATE
    UpdatePedVariation(ped)
end

function RemoveTagFromMetaPed(category)
    if category == "Coat" then
        Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), CharacterConfig.Clothing.ClothingCategories.CoatClosed, 0)
    end
    if category == "CoatClosed" then
        Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), CharacterConfig.Clothing.ClothingCategories.Coat, 0)
    end
    if category == "Pant" then
        if not IsPedMale(PlayerPedId()) then
            Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), CharacterConfig.Clothing.ClothingCategories.Skirt, 0)
        end
    end
    if category == "Skirt" and not IsPedMale(PlayerPedId()) then
        Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), CharacterConfig.Clothing.ClothingCategories.Pant, 0)
    end

    Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), CharacterConfig.Clothing.ClothingCategories[category], 0)
    UpdatePedVariation(PlayerPedId())
end

function EquipMetaPedOutfit(ped, hash)
    Citizen.InvokeNative(0x1902C4CFCC5BE57C, ped, hash)
    UpdatePedVariation(ped)
end

function SetCharExpression(ped, expressionId, value)
    Citizen.InvokeNative(0x5653AB26C82938CF, ped, expressionId, value)
    UpdatePedVariation(ped)
end

function DefaultPedSetup(ped, male)
    local compEyes, compLegs, compBody, compHead

    if male then
        compEyes = 612262189
        compBody = tonumber("0x" .. CharacterConfig.General.DefaultChar.Male[1].Body[1])
        compHead = tonumber("0x" .. CharacterConfig.General.DefaultChar.Male[1].Heads[1])
        compLegs = tonumber("0x" .. CharacterConfig.General.DefaultChar.Male[1].Legs[1])
    else
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, 7, true) -- EquipMetaPedOutfitPreset
        compEyes = 928002221
        compBody = tonumber("0x" .. CharacterConfig.General.DefaultChar.Female[1].Body[1])
        compHead = tonumber("0x" .. CharacterConfig.General.DefaultChar.Female[1].Heads[1])
        compLegs = tonumber("0x" .. CharacterConfig.General.DefaultChar.Female[1].Legs[1])
    end
    Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, PlayerPedId()) -- IsPedReadyToRender
    while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, PlayerPedId()) do
        Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, PlayerPedId())
        Wait(5)
    end
    UpdatePedVariation(PlayerPedId())
    AddComponent(ped, compBody)
    AddComponent(ped, compLegs)
    AddComponent(ped, compHead)
    AddComponent(ped, compEyes)
end
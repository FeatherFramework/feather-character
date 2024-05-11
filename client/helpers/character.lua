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

function EyesAnim(anim)
    while not HasAnimDictLoaded("FACE_HUMAN@GEN_MALE@BASE") do
        RequestAnimDict("FACE_HUMAN@GEN_MALE@BASE")
        Wait(50)
    end

    if not IsEntityPlayingAnim(PlayerPedId(), "FACE_HUMAN@GEN_MALE@BASE", anim, 3) then
        TaskPlayAnim(PlayerPedId(), "FACE_HUMAN@GEN_MALE@BASE", anim, 1090519040, -4, -1, 17, 0, 0, 0, 0, 0, 0)
    end
    RemoveAnimDict("FACE_HUMAN@GEN_MALE@BASE")
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
    local compEyes
    local compBody
    local compHead
    local compLegs

    if male then
        --Citizen.InvokeNative(0x77FF8D35EEC6BBC4, ped, 0, true)
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
        --ApplyShopItemToPed(ped, `CLOTHING_ITEM_F_BODIES_LOWER_001_V_001`, true, true)
        --ApplyShopItemToPed(ped, `CLOTHING_ITEM_F_BODIES_UPPER_001_V_001`, true, true)
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

function GetComponentIndexByCategory(ped, category)
    local numComponents = Citizen.InvokeNative(0x90403E8107B60E81, ped, Citizen.ResultAsInteger()) -- GetNumComponentsInPed
    for i = 0, numComponents - 1, 1 do
        local componentCategory = Citizen.InvokeNative(0x9b90842304c938a7, ped, i, 0, Citizen.ResultAsInteger()) -- GetCategoryOfComponentAtIndex
        if componentCategory == category then
            return i
        end
    end
end

function GetMetaPedAssetGuids(ped, index)
    return Citizen.InvokeNative(0xA9C28516A6DC9D56, ped, index, Citizen.PointerValueInt(), Citizen.PointerValueInt(),
        Citizen.PointerValueInt(), Citizen.PointerValueInt())
end

function GetMetaPedAssetTint(ped, index)
    return Citizen.InvokeNative(0xE7998FEC53A33BBE, ped, index, Citizen.PointerValueInt(), Citizen.PointerValueInt(),
        Citizen.PointerValueInt(), Citizen.PointerValueInt())
end

function SetMetaPedTag(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    Citizen.InvokeNative(0xBC6DF00D7A4A6819, ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
end

function SetSex(sex)
    ChangeOverlay(PlayerPedId(),'eyebrows', 1, 1, 0, 0, 0, 1.0, 0, 1, 254, 254, 254, 0, 1.0, Albedo)

    local function loadModel(model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(10)
        end
    end
    if sex == 'male' then
        loadModel('mp_male')
        SetPlayerModel(PlayerId(), joaat('mp_male'), false)
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 4, 0) -- outfits
        DefaultPedSetup(PlayerPedId(), true)
    else
        loadModel('mp_female')
        SetPlayerModel(PlayerId(), joaat('mp_female'), false)
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 2, 0) -- outfits
        DefaultPedSetup(PlayerPedId(), false)
    end
end
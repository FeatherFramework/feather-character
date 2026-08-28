-- Low-level ped appearance helpers shared by both character creation
-- (creationmenu/*) and the "rc" refresh command. AddComponent/
-- RemoveTagFromMetaPed handle a RedM quirk where certain clothing
-- categories conflict (e.g. open vs. closed coat, pants vs. skirt) and must
-- be explicitly cleared before applying the new one, or the old piece
-- lingers visually.
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

-- (CHAR-20) `tint`, when passed, re-applies a saved dye. Tints ({c1,c2,c3})
-- used to only ever be applied live from clothing_pages.lua's own dye
-- picker and were never carried into the saved clothing blob, so a dyed
-- item reset to its base color on the next relog. Re-derives the drawable/
-- albedo/normal/material/palette needed by _SET_META_PED_TAG the same way
-- clothing_pages.lua's own live preview does (there's no native that just
-- takes "this component, this tint" directly).
function AddComponent(ped, comp, category, tint)
    if category ~= nil then
        RemoveTagFromMetaPed(category, ped, comp)
    end
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, comp, true, true, false)
    Citizen.InvokeNative(0x66b957aac2eaaeab, ped, comp, 0, 0, 1, 1) -- _UPDATE_SHOP_ITEM_WEARABLE_STATE
    UpdatePedVariation(ped)

    if tint then
        local pedType = Citizen.InvokeNative(0xEC9A1261BF0CE510, ped)
        local activeCategory = Citizen.InvokeNative(0x5FF9A878C3D115B8, comp, pedType, true)
        local componentIndex
        local numComponents = Citizen.InvokeNative(0x90403E8107B60E81, ped, Citizen.ResultAsInteger())
        for i = 0, numComponents - 1 do
            local compCategory = Citizen.InvokeNative(0x9B90842304C938A7, ped, i, 0, Citizen.ResultAsInteger())
            if compCategory == activeCategory then
                componentIndex = i
                break
            end
        end
        if componentIndex ~= nil then
            local drawable, albedo, normal, material = Citizen.InvokeNative(
                0xA9C28516A6DC9D56, ped, componentIndex,
                Citizen.PointerValueInt(), Citizen.PointerValueInt(),
                Citizen.PointerValueInt(), Citizen.PointerValueInt()
            )
            local palette = Citizen.InvokeNative(
                0xE7998FEC53A33BBE, ped, componentIndex,
                Citizen.PointerValueInt(), Citizen.PointerValueInt(),
                Citizen.PointerValueInt(), Citizen.PointerValueInt()
            )
            Citizen.InvokeNative(0xBC6DF00D7A4A6819, ped, drawable, albedo, normal, material, palette, tint[1], tint[2], tint[3])
            UpdatePedVariation(ped)
        end
    end
end

function RemoveTagFromMetaPed(category, ped, component)
    ped = ped or PlayerPedId()
    if category == "Coat" then
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, CharacterConfig.Clothing.ClothingCategories.CoatClosed, 0)
    end
    if category == "CoatClosed" then
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, CharacterConfig.Clothing.ClothingCategories.Coat, 0)
    end
    if category == "Pant" then
        if not IsPedMale(ped) then
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, CharacterConfig.Clothing.ClothingCategories.Skirt, 0)
        end
    end
    if category == "Skirt" and not IsPedMale(ped) then
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, CharacterConfig.Clothing.ClothingCategories.Pant, 0)
    end

    local categoryHash = CharacterConfig.Clothing.ClothingCategories[category]
    if not categoryHash and component and (category == 'hair' or category == 'beard') then
        local pedType = Citizen.InvokeNative(0xEC9A1261BF0CE510, ped)
        categoryHash = Citizen.InvokeNative(0x5FF9A878C3D115B8, component, pedType, true)
    end
    if categoryHash then
        Citizen.InvokeNative(0xD710A5007C2AC539, ped, categoryHash, 0)
        UpdatePedVariation(ped)
    end
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
    -- A freshly streamed metaped can report ready for one frame before its
    -- base components are available. Give the renderer a short guaranteed
    -- initialization window; the bounded readiness loop below handles the
    -- remaining slow-load case without hanging character selection.
    Wait(100)
    Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped) -- IsPedReadyToRender
    local renderDeadline = GetGameTimer() + 5000
    while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped) and GetGameTimer() < renderDeadline do
        Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
        Wait(5)
    end
    UpdatePedVariation(ped)
    AddComponent(ped, compBody)
    AddComponent(ped, compLegs)
    AddComponent(ped, compHead)
    AddComponent(ped, compEyes)
    UpdatePedVariation(ped)
    SetEntityVisible(ped, true)
    SetEntityAlpha(ped, 255, false)
end

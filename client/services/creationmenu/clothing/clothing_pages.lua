local VariantArrows

function GetClothingCamPreset(categoryKey)
    if categoryKey == "Upper" then
        return { xOff = -0.4, yOff = 0.0, zOff =  0.4, zoomDelta = -30.0, camZDelta =  0.5 }
    elseif categoryKey == "Lower" then
        return { xOff = -0.4, yOff = 0.0, zOff = -0.2, zoomDelta = -30.0, camZDelta = -0.2 }
    elseif categoryKey == "Accessories" then
        return { xOff =  0.0, yOff = 0.0, zOff =  0.0, zoomDelta =  0.0, camZDelta =  0.0 }
    else
        return { xOff =  0.0, yOff = 0.0, zOff =  0.0, zoomDelta =  0.0, camZDelta =  0.0 }
    end
end

function OpenClothingCategoryPage(clothingCategoriesPage, gender, categoryKey)
    selectedColoring = nil
    selectedClothing = selectedClothing or {}
    selectedClothingElements = selectedClothingElements or {}

    local list = (CharacterConfig and CharacterConfig.Clothing and CharacterConfig.Clothing.Clothes and CharacterConfig.Clothing.Clothes[gender] and CharacterConfig.Clothing.Clothes[gender][categoryKey]) or {}

    for idx, _ in pairs(list) do
        selectedClothing[idx .. 'Category'] = nil
        selectedClothing[idx .. 'Variant']  = nil
    end

    local pageName
    if     categoryKey == "Upper"       then pageName = 'feather-character:UpperClothingPage'
    elseif categoryKey == "Lower"       then pageName = 'feather-character:LowerClothingPage'
    elseif categoryKey == "Accessories" then pageName = 'feather-character:AccessoriesClothingPage'
    else   pageName = 'feather-character:GenericClothingPage' end

    local page = CharacterMenu:RegisterPage(pageName)

    page:RegisterElement('header', { value = FeatherCore.Locale.translate(0, "clothingSelection"), slot="header", style={} })
    page:RegisterElement('subheader', { value = FeatherCore.Locale.translate(0, "clothingSelectionVarDesc"), slot="header", style={} })
    page:RegisterElement('line', { slot="header", style={} })

    for index, item in pairs(list) do
        if type(item) == "table" and item.CategoryData and #item.CategoryData > 0 then
            local displayName = item.CategoryName or tostring(index)
            page:RegisterElement('button', { label = displayName, style = {} }, function()
                OpenClothingItemPage(page, gender, categoryKey, index, item)
            end)
        end
    end

    page:RegisterElement('line', { slot="footer", style={} })
    page:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "goBack"),
        slot  = 'footer', style={}
    }, function()
        SwitchCam(
            Config.CameraCoords.creation.x,
            Config.CameraCoords.creation.y,
            Config.CameraCoords.creation.z,
            Config.CameraCoords.creation.h,
            Config.CameraCoords.creation.zoom
        )
        OpenClothingMenu(page, gender)
    end)
    page:RegisterElement('bottomline', { slot="footer", style={} })

    page:RouteTo()
end

function OpenClothingItemPage(clothingCategoriesPage, gender, categoryKey, index, key)
    local pageName   = ('feather-character:%s:%s:ArrowsPage'):format(categoryKey, tostring(index))
    local activePage = CharacterMenu:RegisterPage(pageName)

    -- inline camera preset
    local camSwitchX, camSwitchY, camSwitchZ, camSwitchZoom, CamZ
    if categoryKey == "Upper" then
        camSwitchX, camSwitchY, camSwitchZ, camSwitchZoom = -0.4, 0.0,  0.4, -30.0
        CamZ = Config.CameraCoords.creation.z + 0.5
    elseif categoryKey == "Lower" then
        camSwitchX, camSwitchY, camSwitchZ, camSwitchZoom = -0.4, 0.0, -0.2, -30.0
        CamZ = Config.CameraCoords.creation.z - 0.2
    elseif categoryKey == "Accessories" then
        camSwitchX, camSwitchY, camSwitchZ, camSwitchZoom =  0.0, 0.0,  0.0,   0.0
        CamZ = Config.CameraCoords.creation.z
    else
        camSwitchX, camSwitchY, camSwitchZ, camSwitchZoom =  0.0, 0.0,  0.0,   0.0
        CamZ = Config.CameraCoords.creation.z
    end

    -- resolve data
    local list  = CharacterConfig and CharacterConfig.Clothing and CharacterConfig.Clothing.Clothes
                  and CharacterConfig.Clothing.Clothes[gender]
                  and CharacterConfig.Clothing.Clothes[gender][categoryKey]
    local entry = key or (list and list[index])
    if type(entry) ~= "table" or not entry.CategoryData or #entry.CategoryData == 0 then
        OpenClothingCategoryPage(clothingCategoriesPage, gender, categoryKey)
        return
    end

    local displayName      = entry.CategoryName or tostring(index)
    local ActiveCategory   = nil
    local MainComponent    = 0
    local VariantComponent = 1

    selectedClothing         = selectedClothing or {}
    selectedClothingElements = selectedClothingElements or {}

    local Color1El, Color2El, Color3El
    local colorState = { c1 = 1, c2 = 1, c3 = 1 }
    local drawable, albedo, normal, material, palette, tint0, tint1, tint2
    local materialReady = false

    local mainOptions = {}
    mainOptions[#mainOptions+1] = { 
        display = FeatherCore.Locale.translate(0,"none") or "None", 
        idx = 0 
    }
    for i = 1, (entry.CategoryData and #entry.CategoryData or 0) do
        mainOptions[#mainOptions+1] = { display = tostring(i), idx = i }
    end

    local varOpts = { { display = "-", idx = 0 } }
    local varStart = 1

    local colorOptions = {}
    for i = 1, 254 do colorOptions[i] = { display = tostring(i), idx = i } end

    -- header
    activePage:RegisterElement('header',    { value = displayName, slot="header", style={} })
    activePage:RegisterElement('subheader', { value = FeatherCore.Locale.translate(0,"clothingSelectionVarDesc"), slot="header", style={} })

    -- declare VariantArrows BEFORE using it
    local VariantArrows = activePage:RegisterElement('arrows', {
        label   = FeatherCore.Locale.translate(0, "variant"),
        start   = varStart,
        options = varOpts,
        slot    = "content",
    }, function(data)
        if MainComponent <= 0 then return end
        local sel = data.value
        local idx = (type(sel)=="table" and sel.idx) or tonumber(sel) or 1
        local max = #entry.CategoryData[MainComponent]
        if idx < 1 then idx = 1 elseif idx > max then idx = max end
        VariantComponent = idx

        local variantHash = entry.CategoryData[MainComponent][VariantComponent].hash
        AddComponent(PlayerPedId(), variantHash, index)
        local pedType = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
        ActiveCategory = Citizen.InvokeNative(0x5FF9A878C3D115B8, variantHash, pedType, true)
        selectedClothingElements[index] = variantHash

        -- read material for this variant (inline)
        materialReady = false
        local componentIndex
        local numComponents = Citizen.InvokeNative(0x90403E8107B60E81, PlayerPedId(), Citizen.ResultAsInteger())
        for i = 0, numComponents - 1 do
            local compCategory = Citizen.InvokeNative(0x9B90842304C938A7, PlayerPedId(), i, 0, Citizen.ResultAsInteger())
            if compCategory == ActiveCategory then componentIndex = i break end
        end
        if componentIndex ~= nil then
            drawable, albedo, normal, material = Citizen.InvokeNative(
                0xA9C28516A6DC9D56, PlayerPedId(), componentIndex,
                Citizen.PointerValueInt(), Citizen.PointerValueInt(),
                Citizen.PointerValueInt(), Citizen.PointerValueInt()
            )
            palette, tint0, tint1, tint2 = Citizen.InvokeNative(
                0xE7998FEC53A33BBE, PlayerPedId(), componentIndex,
                Citizen.PointerValueInt(), Citizen.PointerValueInt(),
                Citizen.PointerValueInt(), Citizen.PointerValueInt()
            )
            materialReady = true
            -- keep user colors; to reset to base, set colorState from tints here

            if Color1El then
                local s1 = (colorState.c1 < 1 and 1) or (colorState.c1 > 254 and 254) or colorState.c1
                local s2 = (colorState.c2 < 1 and 1) or (colorState.c2 > 254 and 254) or colorState.c2
                local s3 = (colorState.c3 < 1 and 1) or (colorState.c3 > 254 and 254) or colorState.c3
                Color1El = Color1El:update({ start = s1 })
                Color2El = Color2El:update({ start = s2 })
                Color3El = Color3El:update({ start = s3 })
            end

            RemoveTagFromMetaPed(index)
            if selectedClothingElements[index] then AddComponent(PlayerPedId(), selectedClothingElements[index], nil) end
            Citizen.InvokeNative(0xBC6DF00D7A4A6819, PlayerPedId(), drawable, albedo, normal, material, palette, colorState.c1, colorState.c2, colorState.c3)
            UpdatePedVariation(PlayerPedId())
        end
    end)

    -- MAIN arrows (safe to update VariantArrows now)
    local MainArrows = activePage:RegisterElement('arrows', {
        label   = displayName,
        start   = 1,
        options = mainOptions,
        slot    = "content",
    }, function(data)
        local sel = data.value
        local idx = (type(sel)=="table" and sel.idx) or tonumber(sel) or 0
        if idx < 0 then idx = 0 end
        if idx > #entry.CategoryData then idx = #entry.CategoryData end

        MainComponent    = idx
        VariantComponent = 1

        if MainComponent > 0 then
            local firstHash = entry.CategoryData[MainComponent][1].hash
            AddComponent(PlayerPedId(), firstHash, index)
            local pedType = Citizen.InvokeNative(0xEC9A1261BF0CE510, PlayerPedId())
            ActiveCategory = Citizen.InvokeNative(0x5FF9A878C3D115B8, firstHash, pedType, true)
            selectedClothingElements[index] = firstHash

            -- rebuild variant options
            varOpts = {}
            local max = #entry.CategoryData[MainComponent]
            for i = 1, max do varOpts[#varOpts+1] = { display = tostring(i), idx = i } end
            varStart = 1
            if VariantArrows then VariantArrows = VariantArrows:update({ options = varOpts, start = varStart }) end

            -- read material (inline)
            materialReady = false
            local componentIndex
            local numComponents = Citizen.InvokeNative(0x90403E8107B60E81, PlayerPedId(), Citizen.ResultAsInteger())
            for i = 0, numComponents - 1 do
                local compCategory = Citizen.InvokeNative(0x9B90842304C938A7, PlayerPedId(), i, 0, Citizen.ResultAsInteger())
                if compCategory == ActiveCategory then componentIndex = i break end
            end
            if componentIndex ~= nil then
                drawable, albedo, normal, material = Citizen.InvokeNative(
                    0xA9C28516A6DC9D56, PlayerPedId(), componentIndex,
                    Citizen.PointerValueInt(), Citizen.PointerValueInt(),
                    Citizen.PointerValueInt(), Citizen.PointerValueInt()
                )
                palette, tint0, tint1, tint2 = Citizen.InvokeNative(
                    0xE7998FEC53A33BBE, PlayerPedId(), componentIndex,
                    Citizen.PointerValueInt(), Citizen.PointerValueInt(),
                    Citizen.PointerValueInt(), Citizen.PointerValueInt()
                )
                materialReady = true
                colorState.c1 = tint0 or colorState.c1
                colorState.c2 = tint1 or colorState.c2
                colorState.c3 = tint2 or colorState.c3
            end

            -- dye UI create/update inline
            if Config.DyeClothes then
                if not Color1El or not Color2El or not Color3El then
                    activePage:RegisterElement('line', { slot="content", style={} })
                    activePage:RegisterElement('subheader', { value=FeatherCore.Locale.translate(0,"colorPage"), slot="content", style={} })

                    Color1El = activePage:RegisterElement('arrows', {
                        label = FeatherCore.Locale.translate(0, "color1"),
                        start = (colorState.c1 < 1 and 1) or (colorState.c1 > 254 and 254) or colorState.c1,
                        options = colorOptions, slot = "content",
                    }, function(d)
                        local sv = d.value; local v = (type(sv)=="table" and sv.idx) or tonumber(sv) or colorState.c1
                        if v < 1 then v = 1 elseif v > 254 then v = 254 end
                        colorState.c1 = v
                        if materialReady then
                            RemoveTagFromMetaPed(index)
                            if selectedClothingElements[index] then AddComponent(PlayerPedId(), selectedClothingElements[index], nil) end
                            Citizen.InvokeNative(0xBC6DF00D7A4A6819, PlayerPedId(), drawable, albedo, normal, material, palette, colorState.c1, colorState.c2, colorState.c3)
                            UpdatePedVariation(PlayerPedId())
                        end
                    end)

                    Color2El = activePage:RegisterElement('arrows', {
                        label = FeatherCore.Locale.translate(0, "color2"),
                        start = (colorState.c2 < 1 and 1) or (colorState.c2 > 254 and 254) or colorState.c2,
                        options = colorOptions, slot = "content",
                    }, function(d)
                        local sv = d.value; local v = (type(sv)=="table" and sv.idx) or tonumber(sv) or colorState.c2
                        if v < 1 then v = 1 elseif v > 254 then v = 254 end
                        colorState.c2 = v
                        if materialReady then
                            RemoveTagFromMetaPed(index)
                            if selectedClothingElements[index] then AddComponent(PlayerPedId(), selectedClothingElements[index], nil) end
                            Citizen.InvokeNative(0xBC6DF00D7A4A6819, PlayerPedId(), drawable, albedo, normal, material, palette, colorState.c1, colorState.c2, colorState.c3)
                            UpdatePedVariation(PlayerPedId())
                        end
                    end)

                    Color3El = activePage:RegisterElement('arrows', {
                        label = FeatherCore.Locale.translate(0, "color3"),
                        start = (colorState.c3 < 1 and 1) or (colorState.c3 > 254 and 254) or colorState.c3,
                        options = colorOptions, slot = "content",
                    }, function(d)
                        local sv = d.value; local v = (type(sv)=="table" and sv.idx) or tonumber(sv) or colorState.c3
                        if v < 1 then v = 1 elseif v > 254 then v = 254 end
                        colorState.c3 = v
                        if materialReady then
                            RemoveTagFromMetaPed(index)
                            if selectedClothingElements[index] then AddComponent(PlayerPedId(), selectedClothingElements[index], nil) end
                            Citizen.InvokeNative(0xBC6DF00D7A4A6819, PlayerPedId(), drawable, albedo, normal, material, palette, colorState.c1, colorState.c2, colorState.c3)
                            UpdatePedVariation(PlayerPedId())
                        end
                    end)
                else
                    local s1 = (colorState.c1 < 1 and 1) or (colorState.c1 > 254 and 254) or colorState.c1
                    local s2 = (colorState.c2 < 1 and 1) or (colorState.c2 > 254 and 254) or colorState.c2
                    local s3 = (colorState.c3 < 1 and 1) or (colorState.c3 > 254 and 254) or colorState.c3
                    Color1El = Color1El:update({ start = s1 })
                    Color2El = Color2El:update({ start = s2 })
                    Color3El = Color3El:update({ start = s3 })
                end
            end
        else
            -- remove component
            Citizen.InvokeNative(0x0D7FFA1B2F69ED82, PlayerPedId(), selectedClothingElements[index], 0, 0)
            selectedClothingElements[index] = nil
            Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0)
            varOpts = { { display = "-", idx = 0 } }
            if VariantArrows then VariantArrows = VariantArrows:update({ options = varOpts, start = 1 }) end
        end
    end)

    -- keep refs
    selectedClothing[index .. 'Category'] = MainArrows
    selectedClothing[index .. 'Variant']  = VariantArrows

    -- footer
    activePage:RegisterElement('line', { slot = "footer", style = {} })
    activePage:RegisterElement('button', {
        label = FeatherCore.Locale.translate(0, "goBack"), slot = 'footer', style = {}
    }, function()
        OpenClothingCategoryPage(clothingCategoriesPage, gender, categoryKey)
    end)
    activePage:RegisterElement('bottomline', { slot = "footer", style = {} })

    -- camera controls
    activePage:RegisterElement('pagearrows', { slot='footer', total=FeatherCore.Locale.translate(0,"zoomCamIn"), current=FeatherCore.Locale.translate(0,"zoomCamOut"), style={} },
    function(d) Fov = (d.value=='forward') and (Fov-1.0) or (Fov+1.0); SetCamFov(CharacterCamera, Fov) end)

    activePage:RegisterElement('pagearrows', { slot='footer', total=FeatherCore.Locale.translate(0,"moveCamUp"), current=FeatherCore.Locale.translate(0,"moveCamDown"), style={} },
    function(d) CamZ = (d.value=='forward') and (CamZ+0.1) or (CamZ-0.1); SetCamCoord(CharacterCamera, Config.CameraCoords.creation.x-0.2, Config.CameraCoords.creation.y, CamZ) end)

    activePage:RegisterElement('pagearrows', { slot='footer', total=FeatherCore.Locale.translate(0,"rotateRight"), current=FeatherCore.Locale.translate(0,"rotateLeft"), style={} },
    function(d) local h=GetEntityHeading(PlayerPedId()); SetEntityHeading(PlayerPedId(), (d.value=='forward') and (h+10.0) or (h-10.0)) end)

    -- route & camera
    activePage:RouteTo()
    SwitchCam(
        Config.CameraCoords.creation.x + camSwitchX,
        Config.CameraCoords.creation.y + camSwitchY,
        Config.CameraCoords.creation.z + camSwitchZ,
        Config.CameraCoords.creation.h,
        Config.CameraCoords.creation.zoom + camSwitchZoom
    )
end

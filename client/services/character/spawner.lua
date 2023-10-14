local current, coords, active

RegisterNetEvent("feather-character:SpawnSelect", function(current)
    -- DoScreenFadeOut(500)
    Wait(500)
    local spawncoords = Config.SpawnCoords.spawns[current].coords
    local PromptGroup2 = FeatherCore.Prompt:SetupPromptGroup()                                --Setup Prompt Group

    local leftprompt = PromptGroup2:RegisterPrompt("Left", 0xE6F612E4, 1, 1, true, 'click')   --Register your first prompt
    local rightprompt = PromptGroup2:RegisterPrompt("Right", 0x1CE6D9EB, 1, 1, true, 'click') --Register your first prompt
    local enterprompt = PromptGroup2:RegisterPrompt("Enter", 0x4F49CC4C, 1, 1, true, 'click') --Register your first prompt
    while true do
        Wait(0)
        PromptGroup2:ShowGroup("Spawn Select") --Show your prompt group
    end

    StartCam(Config.SpawnCoords.spawns[current].cameracoords.x, Config.SpawnCoords.spawns[current].cameracoords.y,
        Config.SpawnCoords.spawns[current].cameracoords.z,
        Config.SpawnCoords.spawns[current].cameracoords.h, Config.SpawnCoords.spawns[current].cameracoords.zoom)
    StartPlayerTeleport(PlayerId(), spawncoords.x, spawncoords.y, spawncoords.z, 0.0, false, true, true)

    while IsPlayerTeleportActive() do
        Wait(100)
    end
    SetEntityVisible(PlayerPedId(), false, 0)

    DoScreenFadeIn(500)
    active = true
    while active do
        DisableAllControlActions(0)
        Wait(0)
        PromptGroup2:ShowGroup("Spawn Select") --Show your prompt group

        if leftprompt:HasCompleted() then
            if current > 1 then
                current = current - 1
            else
                current = #Config.SpawnCoords.spawns
            end
            local coords = Config.SpawnCoords.spawns[current].coords
            DoScreenFadeOut(100)
            Wait(100)
            StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, 0.0, false, true, true)
            while IsPlayerTeleportActive() do
                Wait(100)
            end
            SetEntityVisible(PlayerPedId(), false, 0)
            SwitchCam(Config.SpawnCoords.spawns[current].cameracoords.x,
                Config.SpawnCoords.spawns[current].cameracoords.y, Config.SpawnCoords.spawns[current].cameracoords.z,
                Config.SpawnCoords.spawns[current].cameracoords.h, Config.SpawnCoords.spawns[current].cameracoords.zoom)
            Wait(250)
            DoScreenFadeIn(100)
        end

        if rightprompt:HasCompleted() then
            if current > 1 then
                current = current + 1
            else
                current = #Config.SpawnCoords.spawns
            end
            local coords = Config.SpawnCoords.spawns[current].coords
            DoScreenFadeOut(100)
            Wait(100)
            StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, 0.0, false, true, true)
            while IsPlayerTeleportActive() do
                Wait(100)
            end
            SetEntityVisible(PlayerPedId(), false, 0)
            SwitchCam(Config.SpawnCoords.spawns[current].cameracoords.x,
                Config.SpawnCoords.spawns[current].cameracoords.y, Config.SpawnCoords.spawns[current].cameracoords.z,
                Config.SpawnCoords.spawns[current].cameracoords.h, Config.SpawnCoords.spawns[current].cameracoords.zoom)
            Wait(250)
            DoScreenFadeIn(100)
        end

        if enterprompt:HasCompleted() then

        end


        local playerCoords = GetEntityCoords(PlayerPedId())
        --[[FeatherCore.Render:DrawText(vector2(0.7, 0.5),Config.SpawnCoords.spawns[current].name --'.\n' ..Config.Locales.arrive .. Config.SpawnCoords.spawns[current].arrival,
                { r = 255, g = 0, b = 0, a = 255 }, 1.0, false)
            if Config.SpawnCoords.spawns[current].tip ~= nil then
                FeatherCore.Render:DrawText(vector2(0.7, 0.7), Config.SpawnCoords.spawns[current].tip,
                    { r = 255, g = 0, b = 0, a = 255 }, 1.0, false)
            end
            FeatherCore.Render:DrawText(vector2(0.7, 0.9), Config.Locales.press, { r = 255, g = 0, b = 0, a = 255 }, 1.0, false)]]
        --DrawText(Config.Locales.where..'.\n'..Config.SpawnLocations[current].info..'.\n'..Config.SpawnLocations[current].name..' '..Config.Locales.by..' '..Config.SpawnLocations[current].arrive..'.\n'..Config.Locales.press, 0.5, 0.75, 0.7, 0.7, 255, 255, 255, 255, true, true)
        --[[ if IsDisabledControlJustReleased(0, 0x7065027D) then -- A
                if current > 1 then
                    current = current - 1
                    print(current)
                    print(Config.SpawnCoords.spawns[current].cameracoords.x,Config.SpawnCoords.spawns[current].cameracoords.y,Config.SpawnCoords.spawns[current].cameracoords.z,
                    Config.SpawnCoords.spawns[current].cameracoords.h,Config.SpawnCoords.spawns[current].cameracoords.zoom)

                else
                    current = #Config.SpawnCoords.spawns
                    print(current)
                    print(Config.SpawnCoords.spawns[current].cameracoords.x,Config.SpawnCoords.spawns[current].cameracoords.y,Config.SpawnCoords.spawns[current].cameracoords.z,
                    Config.SpawnCoords.spawns[current].cameracoords.h,Config.SpawnCoords.spawns[current].cameracoords.zoom)

                end
              --[[  coords = Config.SpawnCoords.spawns[current].coords
                DoScreenFadeOut(100)
                Wait(100)
                StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, 0.0, false, true, true)
                while IsPlayerTeleportActive() do
                    Wait(100)
                end
                SetEntityVisible(PlayerPedId(), false, 0)
                SwitchCam(cameracoords)
                Wait(250)
                DoScreenFadeIn(500)
            elseif IsDisabledControlJustReleased(0, 0xB4E465B4) then -- D
                if current < #Config.SpawnCoords.spawns then
                    current = current + 1
                    print(current)
                    print(Config.SpawnCoords.spawns[current].cameracoords.x,Config.SpawnCoords.spawns[current].cameracoords.y,Config.SpawnCoords.spawns[current].cameracoords.z,
                    Config.SpawnCoords.spawns[current].cameracoords.h,Config.SpawnCoords.spawns[current].cameracoords.zoom)
                else
                    current = 1
                    print(current)
                    print(Config.SpawnCoords.spawns[current].cameracoords.x,Config.SpawnCoords.spawns[current].cameracoords.y,Config.SpawnCoords.spawns[current].cameracoords.z,
                    Config.SpawnCoords.spawns[current].cameracoords.h,Config.SpawnCoords.spawns[current].cameracoords.zoom)

                end
                coords = Config.SpawnCoords.spawns[current].coords
                DoScreenFadeOut(100)
                Wait(100)
                StartPlayerTeleport(PlayerId(), coords.x, coords.y, coords.z, 0.0, false, true, true)
                while IsPlayerTeleportActive() do
                    Wait(100)
                end
                SetEntityVisible(PlayerPedId(), false, 0)
                SwitchCam(cameracoords)
                Wait(250)
                DoScreenFadeIn(500)]]
        if IsDisabledControlJustReleased(0, 0xC7B5340A) then -- ENTER
            DoScreenFadeOut(100)
            Wait(2000)
            EndCam()
            ClearFocus()
            DoScreenFadeIn(1000)
            SetEntityVisible(PlayerPedId(), true, 0)
            active = false
            current = 1
            break
        end
    end
end)
--========================================================--
-- Core Character Actions
--========================================================--

--- Cleans up character creation/selection state.
function CleanupScript()
    DisplayRadar(true)
    EndCam()
    CleanupCharacterSelect()

    -- Reset character state
    Citizen.InvokeNative(0xD0AFAFF5A51D72F7, PlayerPedId()) -- NetworkEndTutorialSession
    FeatherCore.RPC.CallAsync("LeaveInstance", { id = 123 })
    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityVisible(PlayerPedId(), true)
end

--- Loads the specified player model and applies defaults.
function LoadPlayer(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    SetPlayerModel(PlayerId(), joaat(model), false)

    if model == 'mp_male' then
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 4, 0) -- male outfits
        DefaultPedSetup(PlayerPedId(), true)
    else
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 3, 0) -- female outfits
        DefaultPedSetup(PlayerPedId(), false)
    end
end

--========================================================--
-- Event Handlers
--========================================================--

--- When the player spawns, check for available characters.
AddEventHandler('playerSpawned', function()
    TriggerServerEvent('feather-character:CheckForUsers')
end)

--- On resource stop, clean up spawned entities and reset state.
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CreatingCharacter = false
        if DoesEntityExist(Mount) then
            DeleteEntity(Mount)
        end
        CleanupScript()
    end
end)

--========================================================--
-- Commands
--========================================================--

--========================================================--
-- Dev Mode Commands
--========================================================--
-- (CHAR audit: leftover dev/test commands) Gated on Config.DevMode (default
-- false) AND registered as ACE-restricted ("true" below), so a server that
-- flips DevMode back on for testing doesn't hand these to every player --
-- only principals granted `command.<name>` can actually run them. `rc` was
-- previously always registered regardless of DevMode; moved in here since
-- it's a testing aid (re-applies cached appearance), not player-facing.
if Config.DevMode then
    RegisterCommand('rc', function(source, args, raw)
        if not CharModel or not Characterid then
            print("[feather-character] No character loaded to refresh.")
            return
        end

        LoadPlayer(CharModel)

        -- Clothing
        local charTints = FetchedTints[Characterid] or {}
        for category, hash in pairs(FetchedClothing[Characterid] or {}) do
            AddComponent(PlayerPedId(), hash, category, charTints[category])
        end

        -- Attributes
        for category, attribute in pairs(FetchedAttributes[Characterid] or {}) do
            if category == 'Albedo' then
                AlbedoHash = attribute.hash
            end

            if attribute.value then
                SetCharExpression(PlayerPedId(), attribute.hash, attribute.value)
            else
                AddComponent(PlayerPedId(), attribute.hash, category)
            end
        end

        -- Overlays
        for category, overlays in pairs(FetchedOverlays[Characterid] or {}) do
            ChangeOverlay(
                PlayerPedId(),
                category,
                1,
                overlays.textureId,
                0, 0, 0,
                1.0,
                0,
                1,
                overlays.color1,
                overlays.color2,
                overlays.color3,
                overlays.variant,
                overlays.opacity,
                SelectedAttributeElements['Albedo'] and SelectedAttributeElements['Albedo'].hash or 0
            )
        end
    end, true)

    RegisterCommand('new', function(source, args, raw)
        TriggerEvent('feather-character:CreateNewCharacter')
    end, true)

    RegisterCommand('teeth', function(source, args, raw)
        local dict = "FACE_HUMAN@GEN_MALE@BASE"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(5) end
        TaskPlayAnim(PlayerPedId(), dict, "Face_Dentistry_Loop",
            1090519040, -4, -1, 17, 0, 0, 0, 0)
    end, true)

    RegisterCommand('check', function(source, args, raw)
        TriggerServerEvent('feather-character:CheckForUsers')
    end, true)

    RegisterCommand('spawn', function(source, args, raw)
        TriggerEvent('feather-character:SpawnSelect', 1)
    end, true)

    RegisterCommand('endcam', function(source, args, raw)
        EndCam()
    end, true)

    RegisterCommand('endscript', function(source, args, raw)
        CleanupScript()
    end, true)
end
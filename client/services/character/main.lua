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

RegisterCommand('rc', function(source, args, raw)
    if not CharModel or not Characterid then
        print("[feather-character] No character loaded to refresh.")
        return
    end

    LoadPlayer(CharModel)

    -- Clothing
    for category, hash in pairs(SentClothing[Characterid] or {}) do
        AddComponent(PlayerPedId(), hash, category)
    end

    -- Attributes
    for category, attribute in pairs(SentAttributes[Characterid] or {}) do
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
    for category, overlays in pairs(SentOverlays[Characterid] or {}) do
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
end, false)

--========================================================--
-- Dev Mode Commands
--========================================================--
if Config.DevMode then
    RegisterCommand('new', function(source, args, raw)
        TriggerEvent('feather-character:CreateNewCharacter')
    end, false)

    RegisterCommand('teeth', function(source, args, raw)
        local dict = "FACE_HUMAN@GEN_MALE@BASE"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(5) end
        TaskPlayAnim(PlayerPedId(), dict, "Face_Dentistry_Loop",
            1090519040, -4, -1, 17, 0, 0, 0, 0)
    end, false)

    RegisterCommand('check', function(source, args, raw)
        TriggerServerEvent('feather-character:CheckForUsers')
    end, false)

    RegisterCommand('spawn', function(source, args, raw)
        TriggerEvent('feather-character:SpawnSelect', 1)
    end, false)

    RegisterCommand('endcam', function(source, args, raw)
        EndCam()
    end, false)

    RegisterCommand('endscript', function(source, args, raw)
        CleanupScript()
    end, false)
end
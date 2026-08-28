-- Character-owned death, revive and doctor-respawn lifecycle.
local deathConfig = Config.Contract1.death or {}
local characterActive = false
local deathActive = false
local respawning = false
local deathStartedAt = 0
local deathPosition
local deathCamera
local promptGroup
local respawnPrompt

local function IsPedDeadState(ped)
    if ped == 0 or not DoesEntityExist(ped) then return false end
    if GetEntityHealth(ped) <= 0 or IsEntityDead(ped) == true then return true end
    if type(IsPedDeadOrDying) == 'function' and IsPedDeadOrDying(ped, true) == true then return true end
    if type(IsPedFatallyInjured) == 'function' and IsPedFatallyInjured(ped) == true then return true end
    return ped == PlayerPedId() and IsPlayerDead(PlayerId()) == true
end

local function SetAutomaticRespawn(enabled)
    local succeeded, reason = pcall(function()
        exports.spawnmanager.setAutoSpawn(enabled == true)
    end)
    if not succeeded then
        print(('[feather-character] unable to set automatic respawn: %s'):format(tostring(reason)))
    end
    return succeeded
end

local function DeleteDeathCamera()
    if not deathCamera then return end
    RenderScriptCams(false, true, 500, true, false)
    DestroyCam(deathCamera, false)
    deathCamera = nil
end

local function CreateDeathCamera()
    if deathConfig.cameraEnabled ~= true or deathCamera then return end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    deathCamera = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA',
        coords.x + 3.0, coords.y + 3.0, coords.z + 2.0,
        0.0, 0.0, 0.0, GetGameplayCamFov(), true, 0)
    PointCamAtEntity(deathCamera, ped, 0.0, 0.0, 0.5, true)
    SetCamActive(deathCamera, true)
    RenderScriptCams(true, true, 750, true, false)
end

local function UpdateDeathCamera()
    if not deathCamera then return end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local speed = tonumber(deathConfig.cameraOrbitSpeed) or 4.0
    local angle = (GetGameTimer() / 1000.0) * math.rad(speed)
    SetCamCoord(deathCamera,
        coords.x + math.cos(angle) * 3.5,
        coords.y + math.sin(angle) * 3.5,
        coords.z + 2.0)
    PointCamAtEntity(deathCamera, ped, 0.0, 0.0, 0.5, true)
end

local function EnsurePrompt()
    if promptGroup and respawnPrompt then return true end
    promptGroup = CharacterRuntime.Prompt:SetupPromptGroup()
    respawnPrompt = promptGroup:RegisterPrompt(
        FeatherCore.Locale.translate(0, 'deathRespawnPrompt'),
        tonumber(deathConfig.promptKey) or 0x760A9C6F,
        false,
        true,
        true,
        'hold',
        { timedeventhash = 'MEDIUM_TIMED_EVENT' }
    )
    return true
end

local function EnableRespawnPrompt(enabled)
    if respawnPrompt then respawnPrompt:EnabledPrompt(enabled == true) end
end

local function ShowDeathPrompt(text)
    if not promptGroup then return end
    promptGroup:ShowGroup(text)
end

local function RespawnPromptCompleted()
    if not respawnPrompt then return false end
    local completed = respawnPrompt:HasCompleted()
    return completed == true or completed == 1
end

local function NearestDoctor(origin)
    local nearest
    local nearestDistance
    for _, doctor in ipairs(deathConfig.doctors or {}) do
        local dx = (tonumber(doctor.x) or 0.0) - origin.x
        local dy = (tonumber(doctor.y) or 0.0) - origin.y
        local dz = (tonumber(doctor.z) or 0.0) - origin.z
        local distance = dx * dx + dy * dy + dz * dz
        if not nearestDistance or distance < nearestDistance then
            nearest = doctor
            nearestDistance = distance
        end
    end
    return nearest
end

local function RestoreVitals(ped)
    ResurrectPed(ped)
    SetAttributeCoreValue(ped, 0, 100)
    SetEntityHealth(ped, tonumber(deathConfig.respawnHealth) or 600, 1)
    SetAttributeCoreValue(ped, 1, 100)
    RestorePedStamina(ped, 100.0)
end

local function FinishDeath()
    deathActive = false
    respawning = false
    deathPosition = nil
    EnableRespawnPrompt(false)
    DeleteDeathCamera()
    DisplayHud(true)
    DisplayRadar(true)
end

local function PersistCurrentPosition()
    if not Characterid then return end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local result = FeatherCore.RPC.CallAsync('character.position.update.v1', {
        position = {
            x = coords.x, y = coords.y, z = coords.z,
            heading = GetEntityHeading(ped)
        }
    })
    if type(result) ~= 'table' or result.ok ~= true then
        print(('[feather-character] doctor respawn position persistence failed code=%s')
            :format(tostring(type(result) == 'table' and result.code or 'invalid_response')))
    end
end

local function RespawnAtDoctor()
    if respawning or not deathActive then return end
    respawning = true
    EnableRespawnPrompt(false)
    local doctor = NearestDoctor(deathPosition or GetEntityCoords(PlayerPedId()))
    if not doctor then
        respawning = false
        Notify(FeatherCore.Locale.translate(0, 'deathNoDoctor'), 'error', 5000)
        return
    end

    DoScreenFadeOut(500)
    Wait(550)
    local ped = PlayerPedId()
    RestoreVitals(ped)
    local placed = FeatherCore.Teleport.ToCoords({
        x = doctor.x, y = doctor.y, z = doctor.z, h = doctor.heading
    }, {
        entity = ped,
        mode = 'exact',
        requireNearbySurface = false,
        streamTimeout = 10000,
        settleTimeout = 10000,
        fade = false
    })
    if not placed.success then
        print(('[feather-character] doctor respawn placement failed doctor=%s reason=%s')
            :format(tostring(doctor.id), tostring(placed.reason)))
        Notify(FeatherCore.Locale.translate(0, 'deathRespawnFailed'), 'error', 5000)
    else
        PersistCurrentPosition()
    end
    FinishDeath()
    -- Restore the original death presentation: keep the screen dark while
    -- the title card plays, then reveal the revived player at the doctor.
    AnimpostfxPlay('Title_Gen_FewHoursLater')
    Wait(3000)
    AnimpostfxPlay('PlayerWakeUpInterrogation')
    DoScreenFadeIn(2000)
end

local function BeginDeath()
    if deathActive or not characterActive then return end
    deathActive = true
    respawning = false
    deathStartedAt = GetGameTimer()
    deathPosition = GetEntityCoords(PlayerPedId())
    SetAutomaticRespawn(false)
    -- RedM prompts are part of the HUD. Hiding the complete HUD here also
    -- hides the respawn prompt that this lifecycle renders every frame.
    DisplayHud(true)
    DisplayRadar(false)
    EnsurePrompt()
    EnableRespawnPrompt(false)
    CreateDeathCamera()
end

AddEventHandler('Feather:Character:Spawned', function()
    characterActive = true
    SetAutomaticRespawn(false)
end)

AddEventHandler('Feather:Character:Logout', function()
    characterActive = false
    FinishDeath()
end)

CreateThread(function()
    while true do
        if not characterActive then
            Wait(500)
        else
            local ped = PlayerPedId()
            local isDead = IsPedDeadState(ped)
            if isDead then
                BeginDeath()
                UpdateDeathCamera()
                local delay = math.max(0, tonumber(deathConfig.respawnDelaySeconds) or 60)
                local elapsed = (GetGameTimer() - deathStartedAt) / 1000.0
                local remaining = math.max(0, math.ceil(delay - elapsed))
                if EnsurePrompt() then
                    if remaining > 0 then
                        EnableRespawnPrompt(false)
                        ShowDeathPrompt(('%s %d %s'):format(
                            FeatherCore.Locale.translate(0, 'deathRespawnAvailable'),
                            remaining,
                            FeatherCore.Locale.translate(0, 'deathSeconds')))
                    else
                        EnableRespawnPrompt(not respawning)
                        ShowDeathPrompt(FeatherCore.Locale.translate(0, 'deathRespawnReady'))
                        if not respawning and RespawnPromptCompleted() then
                            CreateThread(RespawnAtDoctor)
                        end
                    end
                end
                Wait(0)
            else
                if deathActive then FinishDeath() end
                Wait(250)
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    FinishDeath()
    if respawnPrompt then respawnPrompt:DeletePrompt() end
    SetAutomaticRespawn(true)
end)

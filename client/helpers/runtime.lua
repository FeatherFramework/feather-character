-- Character-owned presentation helpers. These wrappers are private to the
-- selection/creation UI and are not framework-wide Core contracts.

CharacterRuntime = CharacterRuntime or {}
CharacterRuntime.Prompt = {}

function CharacterRuntime.Prompt:SetupPromptGroup(groupId)
    local group = { id = groupId or GetRandomIntInRange(0, 0xffffff) }

    function group:ShowGroup(text)
        PromptSetActiveGroupThisFrame(
            self.id,
            CreateVarString(10, 'LITERAL_STRING', text or 'Prompt Info'),
            1,
            0
        )
    end

    function group:RegisterPrompt(title, button, enabled, visible, pulsing, mode, options)
        local handle = PromptRegisterBegin()
        PromptSetControlAction(handle, button or 0x4CC0E2FE)
        PromptSetText(handle, CreateVarString(10, 'LITERAL_STRING', title or 'Title'))
        PromptSetEnabled(handle, enabled ~= false)
        PromptSetVisible(handle, visible ~= false)
        PromptSetGroup(handle, self.id, 0)

        if mode == 'hold' then
            Citizen.InvokeNative(0x74C7D7B72ED0D3CF, handle,
                options and options.timedeventhash or 'MEDIUM_TIMED_EVENT')
        elseif mode == 'click' then
            PromptSetStandardMode(handle, true)
        end

        Citizen.InvokeNative(0xC5F428EE08FA7F2C, handle, pulsing ~= false)
        PromptRegisterEnd(handle)

        return {
            HasCompleted = function()
                if mode == 'click' then
                    return Citizen.InvokeNative(0xC92AC953F0A982AE, handle)
                end
                local completed = Citizen.InvokeNative(0xE0F65F0640EF0617, handle)
                if completed then Wait(500) end
                return completed
            end,
            TogglePrompt = function(_, state)
                Citizen.InvokeNative(0x71215ACCFDE075EE, handle, state == true)
            end,
            EnabledPrompt = function(_, state)
                PromptSetEnabled(handle, state == true)
            end,
            DeletePrompt = function()
                Citizen.InvokeNative(0x00EDE88D4D13CF59, handle)
            end
        }
    end

    return group
end

CharacterRuntime.Object = {}
function CharacterRuntime.Object:Create(modelName, x, y, z, heading, networked)
    local hash = type(modelName) == 'number' and modelName or GetHashKey(modelName)
    if not IsModelValid(hash) then return nil end
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    local entity = CreateObject(hash, x, y, z, networked == true)
    SetEntityHeading(entity, heading or 0.0)
    PlaceObjectOnGroundProperly(entity, true)
    FreezeEntityPosition(entity, true)
    SetModelAsNoLongerNeeded(hash)
    return {
        GetObj = function() return entity end,
        Remove = function()
            if DoesEntityExist(entity) then DeleteObject(entity) end
        end
    }
end

CharacterRuntime.Ped = {}
function CharacterRuntime.Ped:Create(modelName, x, y, z, heading, _, _, _, _, networked)
    local hash = type(modelName) == 'number' and modelName or joaat(modelName)
    if not IsModelValid(hash) then return nil end
    RequestCollisionAtCoord(x, y, z)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    local entity = CreatePed(hash, x, y, z, heading or 0.0, networked == true, true, false, false)
    Citizen.InvokeNative(0x58A850EAEE20FAA3, entity)
    local collisionDeadline = GetGameTimer() + 5000
    while DoesEntityExist(entity) and not HasCollisionLoadedAroundEntity(entity)
        and GetGameTimer() < collisionDeadline do
        RequestCollisionAtCoord(x, y, z)
        Wait(10)
    end
    Citizen.InvokeNative(0x9587913B9E772D29, entity, true) -- place entity on ground
    Citizen.InvokeNative(0x283978A15512B2FE, entity, true)
    SetEntityVisible(entity, true)
    SetEntityAlpha(entity, 255, false)
    SetModelAsNoLongerNeeded(hash)
    return {
        GetPed = function() return entity end,
        SetHeading = function(_, value)
            if DoesEntityExist(entity) then SetEntityHeading(entity, tonumber(value) or 0.0) end
        end,
        Freeze = function(_, state)
            if DoesEntityExist(entity) then FreezeEntityPosition(entity, state == true) end
        end,
        Remove = function()
            if DoesEntityExist(entity) then
                DeletePed(entity)
                DeleteEntity(entity)
            end
        end
    }
end

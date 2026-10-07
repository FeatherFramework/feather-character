CharacterV2Medical = {}

function CharacterV2Medical.ApplyCondition(snapshot)
    if type(snapshot) ~= 'table' or (snapshot.lifeState ~= 'alive' and snapshot.lifeState ~= 'dead'
        and snapshot.lifeState ~= 'incapacitated') then return {ok = false, code = 'invalid_condition'} end
    if snapshot.lifeState ~= 'alive' then
        -- Native lethal state is proven. Incapacitated is currently a logical
        -- recovery window on this dead ped, not a proven unconscious animation.
        SetEntityHealth(PlayerPedId(), 0)
    end
    return {ok = true}
end

exports('ApplyMedicalCondition', function(snapshot)
    if GetInvokingResource() ~= 'feather-medical' then return {ok = false, code = 'forbidden'} end
    return CharacterV2Medical.ApplyCondition(snapshot)
end)

exports('ApplyMedicalRecovery', function(plan)
    if GetInvokingResource() ~= 'feather-medical' then return {ok = false, code = 'forbidden'} end
    local ped = PlayerPedId()
    local function current()
        local context = CharacterV2Medical.GetContext and CharacterV2Medical.GetContext()
        return type(plan) == 'table' and context and context.sessionId == plan.sessionId
            and context.characterId == plan.characterId and PlayerPedId() == ped
    end
    if not current() then return {ok = false, code = 'stale_session'} end
    if ped == 0 or not DoesEntityExist(ped) then return {ok = false, code = 'ped_unavailable'} end
    if type(plan) == 'table' and plan.kind == 'doctor' then
        local point = plan.destination
        if type(point) ~= 'table' or type(point.x) ~= 'number' or type(point.y) ~= 'number' or type(point.z) ~= 'number' then
            return {ok = false, code = 'destination_unavailable'}
        end
        DoScreenFadeOut(250)
        Wait(300)
        if not current() then DoScreenFadeIn(250); return {ok = false, code = 'stale_session'} end
        RequestCollisionAtCoord(point.x, point.y, point.z)
        SetEntityCoords(ped, point.x, point.y, point.z, false, false, false, false)
        SetEntityHeading(ped, point.heading or 0.0)
        local timeout = GetGameTimer() + 5000
        while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do
            RequestCollisionAtCoord(point.x, point.y, point.z)
            Wait(0)
        end
        if not HasCollisionLoadedAroundEntity(ped) then DoScreenFadeIn(250); return {ok = false, code = 'collision_unavailable'} end
    end
    if not current() then DoScreenFadeIn(250); return {ok = false, code = 'stale_session'} end
    -- Same native sequence already live-tested by Admin; never change the model.
    ResurrectPed(ped)
    SetAttributeCoreValue(ped, 0, 100)
    SetEntityHealth(ped, 600, 1)
    SetAttributeCoreValue(ped, 1, 100)
    RestorePedStamina(ped, 100.0)
    if plan.kind == 'doctor' then
        -- Resurrection can change the ped's placement. Finish on the living ped
        -- using the same ground-placement step as Character's direct spawn.
        local point = plan.destination
        SetEntityCoords(ped, point.x, point.y, point.z, false, false, false, false)
        SetEntityHeading(ped, point.heading or 0.0)
        local grounded = PlaceEntityOnGroundProperly(ped)
        if grounded == false or grounded == 0 then
            DoScreenFadeIn(250)
            return {ok = false, code = 'ground_placement_failed'}
        end
    end
    DisplayHud(true)
    DisplayRadar(true)
    if type(plan) == 'table' and plan.kind == 'doctor' then DoScreenFadeIn(350) end
    return {ok = true}
end)

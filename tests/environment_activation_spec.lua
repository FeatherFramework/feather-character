-- Execute the actual activation entry point with mocked Cfx/domain ports.
local passed=0
local function run(mode, phase)
    dofile('config.lua'); dofile('shared/result.lua'); dofile('client/flow.lua')
    assert(CharacterV2Flow.Transition('selection').ok)
    if phase=='creator' then assert(CharacterV2Flow.Transition('creator').ok) end
    local commands,threads,registered={},{},{}
    local released,arrival,completed,aborted=false,false,false,false
    local timer=0
    function GetGameTimer() timer=timer+10; return timer end
    function Wait(ms) timer=timer+math.max(ms,1) end
    function CreateThread(fn) threads[#threads+1]=fn end
    function AddEventHandler() end
    function RegisterCommand(name,fn) commands[name]=fn end
    function GetCurrentResourceName() return 'feather-character' end
    function PlayerId() return 1 end
    function PlayerPedId() return 2 end
    function DoesEntityExist() return true end
    function joaat() return 123 end
    function RequestModel() end
    function HasModelLoaded() return true end
    function SetPlayerModel() assert(released,'environment must release before world model load') end
    function SetModelAsNoLongerNeeded() end
    function SetEntityCollision() end
    function SetEntityCoords() end
    function SetEntityHeading() end
    function FreezeEntityPosition() end
    function SetEntityVisible() end
    function DisplayRadar() end
    function RequestCollisionAtCoord() end
    function HasCollisionLoadedAroundEntity() return true end
    function PlaceEntityOnGroundProperly() return true end
    function NetworkIsPlayerActive() return true end
    function IsScreenFadedIn() return true end
    function IsScreenFadingIn() return false end
    function IsScreenFadedOut() return true end
    function IsGameplayCamRendering() return true end
    function DoScreenFadeOut() end
    function DoScreenFadeIn() end
    function TriggerEvent() end
    Citizen={InvokeNative=function() return true end}
    CharacterV2Medical={}
    CharacterV2Environment={Leave=function(reason)
        assert(reason=='activation'); released=true
    end}
    CharacterV2Preview={Close=function() return CharacterV2Result.Ok(true) end}
    CharacterV2Appearance={InitializePlayer=function()
        assert(released,'environment must release before network metaped initialization')
        if mode=='appearance_failure' then return CharacterV2Result.Err('test_failure','test') end
        return CharacterV2Result.Ok(true)
    end,Apply=function()
        if mode=='cancel_logout' then commands.logout() end
        return CharacterV2Result.Ok(true)
    end}
    CharacterV2Arrival={Cleanup=function() end,Play=function()
        assert(released,'horse arrival must use shared environment')
        arrival=true; return CharacterV2Result.Ok(true)
    end}
    exports=setmetatable({['feather-menu-v2']={},['feather-core']={CallRPCAsync=function(_,name)
        if name=='character.activate.v1' then
            return CharacterV2Result.Ok({profile={model='mp_male'},appearance={document={}},session={sessionId='s'},
                spawn={mode='first_spawn',spawnPointId='valentine',position={x=1,y=2,z=3}}})
        elseif name=='character.selection.route.leave.v1' then
            assert(released,'release must precede routing back to gameplay')
        elseif name=='character.spawn.complete.v1' then
            assert(released); completed=true
        elseif name=='character.activation.abort.v1' then aborted=true
        else error('Unexpected activation RPC: '..name) end
        return CharacterV2Result.Ok(true)
    end}}, {__call=function(_,name,fn) registered[name]=fn end})
    dofile('client/main.lua')
    local ok,problem=pcall(CharacterV2EnterWorld,'c',{afterCreation=phase=='creator'})
    assert(released,'every entered activation must release scene environment')
    if mode=='appearance_failure' then assert(not ok and not completed)
    elseif mode=='cancel_logout' then assert(ok,problem); assert(aborted and not completed and CharacterV2Flow.State().phase=='idle')
    else
        assert(ok,problem); assert(completed and CharacterV2Flow.State().phase=='world')
        assert(arrival==(phase=='creator'))
    end
end
for _,case in ipairs({{'normal','selection'},{'normal','creator'},{'appearance_failure','creator'},{'cancel_logout','selection'}}) do
    run(case[1],case[2]); passed=passed+1
    print(('PASS activation environment release: %s/%s'):format(case[1],case[2]))
end
print(('Character activation environment: %d actual-main checks passed (mocked ports).'):format(passed))

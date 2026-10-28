-- Actual server activation module, mocked domain and Routing ports; no FXServer proof.
dofile('config.lua'); dofile('shared/result.lua')
local ok = CharacterV2Result.Ok
local routes, membership, positions, timers, handlers = {}, {}, {}, {}, {}
local nextRoute, nextSession = 0, 0
function GetResourceState(name) return name == 'feather-medical' and 'missing' or 'started' end
function GetCurrentResourceName() return 'feather-character' end
function GetPlayerPed(source) return source end
function GetEntityCoords(ped) return positions[ped] or {x=0,y=0,z=0} end
function SetEntityCoords(ped,x,y,z) positions[ped]={x=x,y=y,z=z} end
function GetPlayers() return {'1','2','3'} end
function GetPlayerRoutingBucket(source) return membership[source] and 10 or 0 end
function SetTimeout(_,fn) timers[#timers+1]=fn end
function TriggerClientEvent() end
function AddEventHandler(name,fn) handlers[name]=fn end
local sessions={}
local core={
 GetAccountContext=function(_,source) return ok({accountId='account'}) end,
 ActivateSession=function(_,source,character) nextSession=nextSession+1; sessions[source]={sessionId=tostring(nextSession),characterId=character}; return ok(sessions[source]) end,
 IsSessionCurrent=function(_,source,session,character) return sessions[source] and sessions[source].sessionId==session and sessions[source].characterId==character end,
 PublishEvent=function() return ok(true) end,
 BeginSessionLeaving=function(_,source) return ok(sessions[source]) end,
 CompleteSessionLeaving=function(_,source) sessions[source]=nil; return ok(true) end
}
local routing={
 CreateRoute=function(_,spec) nextRoute=nextRoute+1; local id='route'..nextRoute; routes[id]=spec; return ok({routeId=id}) end,
 JoinRoute=function(_,id,source) assert(routes[id]); membership[source]=id; return ok(true) end,
 GetPlayerRoute=function(_,source) return ok(membership[source] and {routeId=membership[source]}) end,
 LeaveRoute=function(_,source) membership[source]=nil; return ok(true) end,
 DeleteRoute=function(_,id) routes[id]=nil; for source,route in pairs(membership) do if route==id then membership[source]=nil end end; return ok(true) end
}
exports=setmetatable({['feather-core']=core,['feather-routing']=routing,['feather-economy']={AwaitReady=function() return ok(true) end,EnsureCharacterWallets=function() return ok(true) end}}, {__call=function() end})
CharacterV2Profiles={Get=function() return ok({model='mp_male'}) end,GetAppearance=function() return ok({document={}}) end,GetSpawnState=function() return ok({mode='first_spawn',spawnPointId='valentine'}) end}
dofile('server/activation.lua')
local function activate(source)
 assert(CharacterV2Activation.EnterSelection(source).ok)
 local selected=membership[source]
 local activated=CharacterV2Activation.Activate(source,'account','c'..source); assert(activated.ok)
 local context={accountId='account',characterId='c'..source,sessionId=activated.value.session.sessionId}
 assert(CharacterV2Activation.PrepareSpawn(source,context,{}).ok)
 assert(membership[source]~=selected and routes[membership[source]].mode=='relaxed')
 return context,membership[source]
end
local c1,r1=activate(1); local c2,r2=activate(2); assert(r1~=r2)
assert(not CharacterV2Activation.LeaveSelection(1).ok)
assert(not CharacterV2Activation.PrepareReveal(1,{sessionId='stale'},{arrived=true}).ok)
local a=CharacterV2Activation.PrepareReveal(1,c1,{arrived=true}); assert(a.ok)
local b=CharacterV2Activation.PrepareReveal(2,c2,{arrived=true}); assert(b.ok)
assert(a.value.position.x~=b.value.position.x,'concurrent reveal must reserve distinct configured positions')
assert(not CharacterV2Activation.CompleteSpawn(1,c1).ok,'replicated placement must be verified')
positions[1]=a.value.position; assert(CharacterV2Activation.CompleteSpawn(1,c1).ok)
assert(not routes[r1] and not membership[1])
assert(CharacterV2Activation.Abort(2).ok); assert(not routes[r2] and membership[2])
assert(CharacterV2Activation.Abort(2).ok,'expired abort is idempotent')
-- Old timeout cannot touch a newer session or somebody else's route.
local c3,r3=activate(2); timers[2](); assert(membership[2]==r3)
membership[2]='another-owner'; assert(CharacterV2Activation.Abort(2).ok); assert(membership[2]=='another-owner' and not routes[r3])
local c4,r4=activate(2); timers[#timers](); assert(not routes[r4] and sessions[2]==nil and membership[2])
local c5,r5=activate(2); source=2; handlers.playerDropped(); assert(not routes[r5])
local c6,r6=activate(2); handlers.onResourceStop('feather-character'); assert(not routes[r6])
print('PASS arrival routing: distinct routes, reservations/fallback, stale session/timer/owner, placement, abort, timeout, disconnect, owner stop (mocked ports)')

-- Real preview implementation, deterministic mocked natives; no live streaming.
dofile('config.lua'); dofile('shared/result.lua')
CharacterV2Config.preview.collisionTimeoutMs=500
CharacterV2Config.preview.modelTimeoutMs=500
local now,readyAt,mode,clones,deletes,requests,cancelled
local frozen,collision,visible,positions,entities,cameras={},{},{},{},{},{}
GetGameTimer=function() return now end
PlayerPedId=function() return 1 end; PlayerId=function() return 0 end
joaat=function(v) return v end
IsModelValid=function() return true end; RequestModel=function() end; HasModelLoaded=function() return true end
SetModelAsNoLongerNeeded=function() end; GetEntityModel=function() return 'mp_male' end
DoesEntityExist=function(ped) return entities[ped]==true end
SetEntityVisible=function(ped,v) visible[ped]=v end
SetEntityAlpha=function() end; ResetEntityAlpha=function() end
FreezeEntityPosition=function(ped,v)
 if ped==1 then assert(v==true,'source must never be unfrozen before stage collision is ready') end
 frozen[ped]=v
end
SetEntityCollision=function(ped,v) collision[ped]=v end
SetEntityCoords=function(ped,x,y,z) positions[ped]={x=x,y=y,z=z} end
GetEntityCoords=function(ped) return positions[ped] end
RequestCollisionAtCoord=function() requests=requests+1 end
HasCollisionLoadedAroundEntity=function(ped)
 if ped==1 then return now>=readyAt and 1 or 0 end -- BOOL numeric variants
 return mode~='clone_timeout'
end
Wait=function(ms)
 now=now+(ms>0 and ms or 100)
 if clones==0 then assert(frozen[1] and collision[1] and visible[1]==false) end
 if mode=='cancel' and not cancelled then cancelled=true; CharacterV2Preview.Close() end
end
SetEntityHeading=function() end
PlaceEntityOnGroundProperly=function(ped)
 assert(frozen[ped] and collision[ped],'ground the frozen source only after real collision readiness')
 positions[ped].z=102.8; return true
end
ClonePed=function(ped)
 assert(ped==1 and frozen[ped] and now>=readyAt)
 clones=clones+1; entities[2]=true; return 2
end
SetEntityNoCollisionEntity=function() end
SetEntityAsMissionEntity=function() end
DeletePed=function(ped) assert(ped~=1); deletes=deletes+1; entities[ped]=nil end
Citizen={InvokeNative=function() return true end}
CreateCam=function() cameras[7]=true; return 7 end
DoesCamExist=function(camera) return cameras[camera]==true end
DestroyCam=function(camera) cameras[camera]=nil end
RenderScriptCams=function() end; SetCamCoord=function() end; SetCamRot=function() end
SetCamFov=function() end; SetCamActive=function() end
AddEventHandler=function() end
local function reset(testMode,delay)
 now=0; readyAt=delay; mode=testMode; clones=0; deletes=0; requests=0; cancelled=false
 frozen={}; collision={[1]=false}; visible={}; positions={[1]={x=0,y=0,z=0}}; entities={[1]=true}; cameras={}
 dofile('client/preview.lua')
end
reset('delayed',300)
local opened=CharacterV2Preview.Open('selector','mp_male')
assert(opened.ok and clones==1 and requests>=4 and frozen[1] and collision[1]==false,
 'delayed source streaming succeeds, then source becomes nonphysical for carousel')
assert(CharacterV2Preview.Close().ok and deletes==1 and entities[1],'cleanup deletes owned clone only')
reset('timeout',10000)
local failed=CharacterV2Preview.Open('selector','mp_male')
assert(not failed.ok and failed.code=='preview_timeout' and failed.message:find('500ms',1,true))
assert(now==500 and clones==0 and frozen[1] and visible[1]==false and CharacterV2Preview.Current()==nil)
readyAt=now
assert(CharacterV2Preview.Open('selector','mp_male').ok and clones==1,'a cleaned timeout can retry successfully')
reset('cancel',10000)
failed=CharacterV2Preview.Open('selector','mp_male')
assert(not failed.ok and failed.code=='preview_cancelled' and clones==0 and entities[1])
reset('clone_timeout',0)
failed=CharacterV2Preview.Open('selector','mp_male')
assert(not failed.ok and failed.code=='preview_timeout' and deletes==1 and entities[1] and frozen[1])
print('selector collision PASS: frozen source/stale collision restore, delayed stream, numeric BOOL, timeout cleanup/retry, cancellation and owned-clone cleanup; mocked natives')

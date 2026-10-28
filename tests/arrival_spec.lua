-- Exercise actual arrival orchestration with mocked Cfx natives.
dofile('config.lua'); dofile('shared/result.lua')
local function run(mode)
 local time,horse,camera,faded,deleted,rendering=0,false,false,true,false,false
 local cancelled=false
 function GetGameTimer() return time end
 function Wait(ms)
  time=time+math.max(ms,1)
  if mode=='cancel' and horse and not cancelled then cancelled=true; CharacterV2Arrival.Cleanup() end
 end
 function CreateThread() end
 function AddEventHandler() end
 function GetCurrentResourceName() return 'feather-character' end
 function PlayerPedId() return 1 end
 function joaat() return 99 end
 function IsModelValid() return mode~='invalid_model' end
 function RequestModel() end
 function HasModelLoaded() return true end
 function SetModelAsNoLongerNeeded() end
 function DoesEntityExist(ped) return ped==1 or horse end
 function CreatePed() horse=true; return 2 end
 function DeletePed() assert(faded,'temporary horse must be deleted under fade'); horse=false; deleted=true end
 function CreateCam() camera=true; return 3 end
 function DoesCamExist() return camera end
 function DestroyCam() camera=false end
 function RenderScriptCams(value) rendering=value end
 function DoScreenFadeOut() faded=true end
 function DoScreenFadeIn() faded=false end
 function IsScreenFadedOut() return faded end
 function GetEntityCoords() return CharacterV2Config.arrivals.towns.valentine.destination end
 function IsPedOnMount() return false end
 function HasCollisionLoadedAroundEntity() return true end
 function PlaceEntityOnGroundProperly() return true end
 for _,name in ipairs({'SetEntityAsMissionEntity','ClearPedTasksImmediately','DisplayRadar','RequestCollisionAtCoord','SetEntityCoords','SetEntityHeading','SetEntityVisible','SetEntityInvincible','SetBlockingOfNonTemporaryEvents','SetPedCanRagdoll','ResetEntityAlpha','FreezeEntityPosition','AttachCamToEntity','PointCamAtEntity','SetCamFov','SetCamActive','ClearPedTasks','DisableAllControlActions'}) do _G[name]=function() end end
 Citizen={InvokeNative=function(hash)
  if hash==0x01FEE67DB37F59B2 and mode=='dismount_failure' then return false end
  return true
 end}
 dofile('client/arrival.lua')
 local result=CharacterV2Arrival.Play('valentine',1)
 assert(result.ok==(mode=='success'),mode)
 assert(not horse and not camera and not rendering and faded,'all paths clean privately before handoff')
 if mode=='cancel' or mode=='success' or mode=='dismount_failure' then assert(deleted) end
 print('PASS actual arrival: '..mode)
end
for _,mode in ipairs({'success','cancel','invalid_model','dismount_failure'}) do run(mode) end

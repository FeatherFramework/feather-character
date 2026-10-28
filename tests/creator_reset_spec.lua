-- Real appearance + preview adapters, modeled visual state; no live RedM proof.
dofile('config.lua'); dofile('shared/result.lua')
local ped,now,replacements=1,0,0
local state={wet=true,blood=true,dirt=true,decorated=true,face='old aging/eyebrows/scar'}
local textures,nextTexture,applied={},0,0
local events={}
function PlayerPedId() return ped end
function PlayerId() return 0 end
function GetEntityModel() return 'mp_male' end
function joaat(value) return value end
function GetHashKey(value) return value end
function GetGameTimer() return now end
function Wait(ms) now=now+math.max(ms,1) end
function DoesEntityExist() return true end
function IsModelValid() return true end
function RequestModel() end
function HasModelLoaded() return true end
function SetModelAsNoLongerNeeded() end
function SetPlayerModel() replacements=replacements+1; ped=ped+1 end
function ClearPedTasksImmediately() events[#events+1]='tasks' end
function SetEntityVisible(_,visible) if visible then assert(not state.wet) end end
function SetEntityAlpha() end
function FreezeEntityPosition() end
function SetEntityCollision() end
function SetEntityCoords() end
function SetEntityHeading() end
function RequestCollisionAtCoord() end
function HasCollisionLoadedAroundEntity() return true end
function PlaceEntityOnGroundProperly() return true end
function CreateCam() return 7 end
function DoesCamExist() return true end
function DestroyCam() end
function RenderScriptCams() end
function SetCamCoord() end
function SetCamRot() end
function SetCamFov() end
function SetCamActive() end
function SetEntityAsMissionEntity() end
function DeletePed() error('creator must not delete the live player ped') end
function AddEventHandler() end
Citizen={InvokeNative=function(hash,...)
 local args={...}
 if hash==0x9C720776DAA43E7E or hash==0xF9CFF5BB70E8A2CB then state.wet=false
 elseif hash==0x8FE22675A5A45817 or hash==0x523C79AEEFCC4A2A then state.blood=false
 elseif hash==0x6585D955A68452A5 or hash==0xE3144B932DFDFF65 then state.dirt=false
 elseif hash==0x0E5173C163976E38 then state.decorated=false
 elseif hash==0x77FF8D35EEC6BBC4 then
  assert(not state.wet and not state.blood and not state.dirt and not state.decorated,'clear before base preset')
 elseif hash==0xC5E7204F322E49EB then
  nextTexture=nextTexture+1; textures[nextTexture]={}; return nextTexture
 elseif hash==0x86BB5FF45F193A02 then
  textures[args[1]][#textures[args[1]]+1]=args[2]; return 0
 elseif hash==0x0B46E25761519058 then
  applied=applied+1; state.face=textures[args[3]]
 elseif hash==0x6BEFAA907B076859 then textures[args[1]]=nil
 elseif hash==0x31DC8D3F216D8509 or hash==0xA0BC8FAED8CFEB3C then return true
 end
end}
CharacterV2OverlayCatalog={Get=function() return {ids={123},palette=false,variants=1} end}
dofile('client/appearance.lua'); dofile('client/preview.lua')
local appearance=CharacterV2Appearance
local document={attributes={Albedo={hash=99}},clothing={},overlays={}}
assert(CharacterV2Preview.Open('creator','mp_male').ok)
assert(replacements==1,'same-model creator entry must rebuild rather than reuse logged-out ped')
assert(appearance.Apply(ped,document).ok)
assert(type(state.face)=='table' and #state.face==0 and applied==1,'empty overlays must attach a clean base texture')
document.overlays={ageing={textureId=1,variant=0,opacity=1,color1=0,color2=0,color3=0}}
assert(appearance.Apply(ped,document).ok and #state.face==1,'new creator overlays still work')
document.overlays={}
assert(appearance.Apply(ped,document).ok and #state.face==0,'removing last overlay cannot preserve the old one')
state.wet=true; state.blood=true; state.dirt=true; state.decorated=true
assert(CharacterV2Preview.Open('creator','mp_male').ok and replacements==2)
assert(appearance.Apply(ped,document).ok and #state.face==0,'creator reentry resets prior draft too')
assert(not state.wet and not state.blood and not state.dirt and not state.decorated)
print('PASS creator reset: same-model rebuild, clear before base, dry/damage/dirt/decor cleanup, inherited face replacement, empty overlay removal and repeat entry (mocked natives)')

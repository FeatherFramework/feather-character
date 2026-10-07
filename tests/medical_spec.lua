local callbacks, revived, moved, health = {}, 0, 0, nil
local caller, session, changeOnWait = 'feather-medical', 'current', false
local grounded, groundCalls = true, 0
exports = function(name, fn) callbacks[name] = fn end
GetInvokingResource = function() return caller end
PlayerPedId = function() return 10 end
DoesEntityExist = function() return true end
SetEntityHealth = function(_, value) health = value end
ResurrectPed = function() revived = revived + 1 end
SetAttributeCoreValue = function() end
RestorePedStamina = function() end
DisplayHud = function() end
DisplayRadar = function() end
DoScreenFadeOut = function() end
DoScreenFadeIn = function() end
RequestCollisionAtCoord = function() end
HasCollisionLoadedAroundEntity = function() return true end
SetEntityCoords = function() moved = moved + 1 end
SetEntityHeading = function() end
PlaceEntityOnGroundProperly = function() groundCalls = groundCalls + 1; return grounded end
GetGameTimer = function() return 1000 end
Wait = function() if changeOnWait then session = 'replacement' end end
dofile('client/medical.lua')
CharacterV2Medical.GetContext = function() return {sessionId = session, characterId = 'character'} end
local plan = {kind = 'staff', sessionId = 'current', characterId = 'character'}
assert(callbacks.ApplyMedicalRecovery(plan).ok and revived == 1, 'current authorized application')
caller = 'foreign'
assert(callbacks.ApplyMedicalRecovery(plan).code == 'forbidden' and revived == 1, 'foreign caller rejected')
caller = 'feather-medical'
session = 'replacement'
assert(callbacks.ApplyMedicalRecovery(plan).code == 'stale_session' and revived == 1, 'old-session recovery rejected')
session, changeOnWait = 'current', true
plan.kind, plan.destination = 'doctor', {x = 1, y = 2, z = 3}
assert(callbacks.ApplyMedicalRecovery(plan).code == 'stale_session' and moved == 0 and revived == 1, 'session change during fade cannot move or revive replacement')
assert(callbacks.ApplyMedicalCondition({lifeState = 'dead'}).ok and health == 0, 'restore dead without model replacement')
session, changeOnWait = 'current', false
assert(callbacks.ApplyMedicalRecovery(plan).ok and groundCalls == 1 and revived == 2, 'doctor recovery grounds resurrected ped')
grounded = false
assert(callbacks.ApplyMedicalRecovery(plan).code == 'ground_placement_failed', 'failed ground placement cannot report successful recovery')
plan.kind = 'staff'
local before = groundCalls
assert(callbacks.ApplyMedicalRecovery(plan).ok and groundCalls == before, 'staff revive does not relocate or ground target')
print('PASS 8 Character Medical application harness checks')

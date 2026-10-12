-- Run from the Character resource root with Lua 5.4. No Weapons dependency.
local registered,events={},{}
local invoking='feather-weapons'
local state='started'
local provider={}
exports=setmetatable({['feather-weapons']=provider},{__call=function(_,name,fn) registered[name]=fn end})
GetInvokingResource=function() return invoking end
GetResourceState=function(owner) assert(owner=='feather-weapons'); return state end
AddEventHandler=function(name,fn) events[name]=fn end
CharacterV2Result={Ok=function(value) return {ok=true,value=value} end,
 Err=function(code,message) return {ok=false,code=code,message=message} end}
dofile('client/checkpoints.lua')
local register=registered.RegisterLogoutCheckpoint
assert(not register('', 'Checkpoint').ok)
invoking=nil; assert(not register('native-weapons','Checkpoint').ok); invoking='feather-weapons'
assert(register('native-weapons','Checkpoint').ok)
invoking='other'; assert(not register('native-weapons','Other').ok); invoking='feather-weapons'
local context={characterId='character',reason='logout'}
local calls=0
local mode='success'
local remote=setmetatable({__cfx_functionReference='test-checkpoint'}, {__call=function(_,value)
 assert(value==context,'original context must reach the callable reference')
 calls=calls+1
 if mode=='throw' then error('checkpoint exception') end
 if mode=='malformed' then return true end
 return {ok=mode=='success'}
end})
-- CFX resource proxy consumes its first argument as the resource receiver.
provider.Checkpoint=function(self,...)
 assert(self==provider,'dynamic export lookup requires resource receiver')
 return remote(...)
end
assert(CharacterV2Checkpoints.Run(context).ok and calls==1)
for _,failure in ipairs({'refused','throw','malformed'}) do
 mode=failure
 local result=CharacterV2Checkpoints.Run(context)
 assert(not result.ok and result.code=='checkpoint_failed','failed callback must veto logout')
end
mode='success'; state='stopped'
local before=calls
assert(CharacterV2Checkpoints.Run(context).ok and calls==before)
state='started'; assert(CharacterV2Checkpoints.Run(context).ok and calls==before,'stopped owner registration removed')
assert(register('native-weapons','Checkpoint').ok)
events.onClientResourceStop('unrelated'); assert(CharacterV2Checkpoints.Run(context).ok and calls==before+1)
events.onClientResourceStop('feather-weapons')
assert(CharacterV2Checkpoints.Run(context).ok and calls==before+1,'resource-stop removes only its registrations')
print('Character checkpoints PASS (CFX proxy/callable reference, context forwarding, owner isolation, logout veto, stop cleanup)')

-- Actual Character repository + existing Admin RPC callback; mocked DB/Cfx ports.
dofile('shared/result.lua')
local caller,calls,rows,throwing='feather-admin',0,{},false
local lastSql,lastArgs
function GetInvokingResource() return caller end
DB={query=function(sql,...)
 calls=calls+1; lastSql=sql; lastArgs={...}
 if throwing then error('private SQL failure') end
 return rows
end}
dofile('server/profiles.lua')
local search=CharacterV2Profiles.SearchProfiles
for _,owner in ipairs({'untrusted','feather-core','feather-character',''}) do
 caller=owner; assert(search('',1,20).code=='forbidden')
end
caller=nil; assert(search('',1,20).code=='forbidden'); assert(calls==0)
caller='feather-admin'
for _,args in ipairs({{false,1,20},{string.rep('a',97),1,20},{'a\n',1,20},{'',0,20},{'',1001,20},{'',1.5,20},{'',1,0},{'',1,101},{'',1,2.5},{'',math.huge,20},{'',0/0,20},{'','1',20}}) do
 assert(search(table.unpack(args)).code=='invalid_input')
end
assert(calls==0,'denied/invalid calls never reach DB')
local result=search('  A_%!  ',2,2); assert(result.ok and #result.value.profiles==0 and not result.value.hasNext)
assert(lastArgs[1]=='%A!_!%!!%' and lastArgs[4]=='A_%!' and lastArgs[5]=='A_%!')
assert(lastArgs[6]==3 and lastArgs[7]==2)
assert(lastSql:find("`status` = 'active'",1,true))
assert(lastSql:find('CONCAT_WS',1,true) and lastSql:find('ORDER BY `last_name`, `first_name`, `character_id`',1,true))
assert(not lastSql:find('A_%!',1,true),'query must be bound, never interpolated')
local function row(id) return {character_id='c'..id,account_id='a'..id,first_name='First',last_name='Last',status='active',description='private',date_of_birth='private'} end
rows={row(1),row(2),row(3)}
result=search('First Last',1,2); assert(result.ok and #result.value.profiles==2 and result.value.hasNext)
assert(result.value.profiles[1].accountId=='a1' and result.value.profiles[1].characterId=='c1')
assert(result.value.profiles[1].description==nil and result.value.profiles[1].dateOfBirth==nil)
assert(lastArgs[1]=='%First Last%')
rows={row(1),row(2)}; assert(not search('',1,2).value.hasNext)
local uuid='11111111-1111-4111-8111-111111111111'
assert(search(uuid,1000,100).ok and lastArgs[4]==uuid and lastArgs[6]==101 and lastArgs[7]==99900)
throwing=true; result=search('',1,20); assert(result.code=='database_unavailable' and not result.message:find('SQL'))
throwing=false; rows=nil; assert(search('',1,20).code=='database_unavailable')
-- Load the existing Admin service without modifying that sibling repository.
local rpcs,events={},{}
local permitted=true
FeatherAdmin={
 RegisterRPC=function(name,fn) rpcs[name]=fn end,
 RequirePermission=function(_,permission) assert(permission=='staff.search'); return permitted end,
 Identity={GetStaff=function() return nil end},
 CanActOnAccount=function() return true end
}
Config={staff={searchLimit=2},authority={roles={}}}
function GetPlayers() return {} end
function RegisterCommand() end
function TriggerClientEvent(...) events[#events+1]={...} end
exports={['feather-core']={GetProvider=function(_,kind,_,version)
 assert(kind=='character-profile' and version==1)
 return {ok=true,value={implementation={SearchProfiles=search}}}
end}}
dofile('../feather-admin/server/services/staff_management.lua')
local adminSearch=assert(rpcs['feather-admin:staff:search'])
rows={row(1),row(2),row(3)}; caller='feather-admin'
adminSearch({query='First',page=1},nil,10)
local event=events[#events]
assert(event[1]=='feather-admin:staff:search:result' and event[2]==10 and #event[3]==2 and event[4]==1 and event[5]==true)
assert(event[3][1].accountId=='a1' and event[3][1].characterName=='First Last')
local before=calls; permitted=false; adminSearch({query='First',page=1},nil,10); assert(calls==before)
permitted=true; FeatherAdmin.CanActOnAccount=function() return false end
adminSearch({query='First',page=1},nil,10); assert(#events[#events][3]==0)
rows={}; adminSearch({query='Nobody',page=1},nil,10); assert(#events[#events][3]==0 and events[#events][5]==false)
throwing=true; adminSearch({query='First',page=1},nil,10); assert(events[#events][6]=='invalid_staff_search')
print('PASS profile search: trusted caller, bounds, SQL bindings/projection/order, pagination/lookahead, DB failures; actual Admin permission/hierarchy/result integration (mocked ports)')

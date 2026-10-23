-- Actual main.lua bootstrap with mocked read-only RPC/UI/presentation ports.
local originalPrint=print
local function run(mode)
 dofile('config.lua'); dofile('shared/result.lua'); dofile('client/flow.lua')
 local threads,handlers,commands,logs,registered={},{},{},{},{}
 local attempts,closed,opened,reads,weatherEntered,weatherLeft=0,0,0,0,0,0
 local succeed=mode=='eventual'
 local hidden,frozen=false,false
 print=function(v) logs[#logs+1]=v end
 CreateThread=function(fn) threads[#threads+1]=coroutine.create(fn) end
 Wait=function() coroutine.yield() end
 AddEventHandler=function(name,fn) handlers[name]=fn end
 RegisterCommand=function(name,fn) commands[name]=fn end
 NetworkIsSessionStarted=function() return true end; PlayerPedId=function() return 1 end
 DoesEntityExist=function(ped) return ped==1 end
 SetEntityVisible=function(_,v) hidden=not v end
 SetEntityAlpha=function() end; FreezeEntityPosition=function(_,v) frozen=v end
 DisplayRadar=function() end; DoScreenFadeOut=function() end
 IsScreenFadedIn=function() return true end; TriggerEvent=function() end
 CharacterV2Medical={}
 CharacterV2Environment={Enter=function(view)
  assert(view=='selector'); weatherEntered=weatherEntered+1
 end,Leave=function(reason)
  assert(reason=='bootstrap_cleanup'); weatherLeft=weatherLeft+1
 end}
 CharacterV2Appearance={InitializePed=function() return CharacterV2Result.Ok(true) end,
  Apply=function() return CharacterV2Result.Ok(true) end}
 CharacterV2Preview={Open=function()
  attempts=attempts+1
  if mode=='activation_race' then CharacterV2Flow.Transition('activating') end
  if succeed and attempts>=3 then return CharacterV2Result.Ok({ped=2}) end
  return CharacterV2Result.Err(mode=='fatal' and 'invalid_model' or 'preview_timeout','test')
 end,Close=function()
  closed=closed+1
  return mode=='cleanup_failure' and CharacterV2Result.Err('cleanup_failed','test') or CharacterV2Result.Ok(true)
 end,StashSelector=function() return CharacterV2Result.Ok(true) end,
 ActivateSelector=function() return CharacterV2Result.Ok(true) end}
 local menu=setmetatable({}, {__index=function(_,name) return function()
  if name=='OpenMenu' then opened=opened+1 end
  return CharacterV2Result.Ok({menuId='menu',pageId='page',elementId='element'})
 end end})
 exports=setmetatable({['feather-menu-v2']=menu,['feather-core']={CallRPCAsync=function(_,name)
  reads=reads+1
  if name=='character.selection.route.enter.v1' then return CharacterV2Result.Ok(true) end
  if name=='character.list.v1' then return CharacterV2Result.Ok({{characterId='c',firstName='Test',lastName='Player',model='mp_male'}}) end
  if name=='character.appearance.get.v1' then return CharacterV2Result.Ok({document={}}) end
  error('bootstrap must never activate/write a character: '..name)
 end}}, {__call=function(_,name,fn) registered[name]=fn end})
 dofile('client/main.lua')
 local function step(thread) local ok,problem=coroutine.resume(thread); assert(ok,problem) end
 step(threads[1]); assert(#threads==2)
 step(threads[2]) -- selection setup yields before preparing the stage
 local count=#threads; handlers.playerSpawned(); commands.characterSelectionRetry()
 assert(#threads==count,'duplicate spawned/manual triggers cannot overlap opening')
 local function pump()
  for _=1,100 do
   local active=false
   for _,thread in ipairs(threads) do if coroutine.status(thread)~='dead' then active=true; step(thread) end end
   if not active then return end
  end
  error('bootstrap did not stop after bounded retries')
 end
 pump()
 assert(not registered.HasActiveCharacter(),'retry must not activate a character')
 if mode=='eventual' then
  assert(attempts==3 and closed==2 and opened==1 and CharacterV2Flow.State().phase=='selection')
  count=#threads; commands.characterSelectionRetry(); handlers.playerSpawned(); assert(#threads==count)
 elseif mode=='all_fail' then
  assert(attempts==3 and closed==3 and opened==0 and CharacterV2Flow.State().phase=='idle' and hidden and frozen)
  count=#threads; handlers.playerSpawned(); assert(#threads==count,'spawned events cannot silently start another exhausted batch')
  succeed=true; count=#threads; commands.characterSelectionRetry(); commands.characterSelectionRetry()
  assert(#threads==count+1); pump()
  assert(attempts==4 and opened==1 and CharacterV2Flow.State().phase=='selection','manual retry recovers exhausted bootstrap')
 elseif mode=='fatal' then
  assert(attempts==1 and closed==1 and CharacterV2Flow.State().phase=='idle','nontransient errors do not auto-retry')
 elseif mode=='cleanup_failure' then
  assert(attempts==1 and closed==1 and CharacterV2Flow.State().phase=='selection')
  count=#threads; commands.characterSelectionRetry(); assert(#threads==count,'uncertain cleanup requires reconnect')
 elseif mode=='activation_race' then
  assert(attempts==1 and closed==0 and CharacterV2Flow.State().phase=='activating','never reset an activation/world owner')
 end
 assert(reads<=12,'retries remain bounded read-only RPC work')
 assert(weatherEntered==attempts,'every actual selector preview requests its environment')
 assert(weatherLeft==closed,'every bootstrap preview cleanup releases scene intent/handle')
end
for _,mode in ipairs({'eventual','all_fail','fatal','cleanup_failure','activation_race'}) do run(mode) end
print=originalPrint
print('selection bootstrap PASS: real main flow, bounded transient retry/reset/cleanup, manual recovery, overlap/activation guards and read-only RPC; mocked ports')

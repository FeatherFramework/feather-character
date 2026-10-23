-- Actual optional scene adapter against Weather's pure owner/handle model.
-- Run from feather-character with Lua 5.4; no FXServer or native application.
local passed = 0
local function test(name, fn) fn(); passed=passed+1; print('PASS ' .. name) end
local function eq(a,b) assert(a==b, ('expected %s, got %s'):format(tostring(b), tostring(a))) end
local function setup()
    dofile('config.lua')
    dofile('../feather-weather/config.lua')
    dofile('../feather-weather/shared/contract.lua')
    dofile('../feather-weather/client/overrides.lua')
    local env = {now=0, provider='started', epoch='one', calls={acquire=0,update=0,release=0}, handlers={}, threads={}}
    env.model = WeatherOverrides.New(WeatherConfig, env.epoch)
    function GetCurrentResourceName() return 'feather-character' end
    function GetGameTimer() return env.now end
    function GetResourceState() return env.provider end
    function CreateThread(fn) env.threads[#env.threads+1]=fn end
    function AddEventHandler(name, fn) env.handlers[name]=fn end
    function RegisterCommand() end
    function Wait(ms)
        if coroutine.isyieldable() then coroutine.yield() else
            env.now=env.now+ms
            if env.onWait then env.onWait() end
        end
    end
    local api={}
    function api:AcquireOverride(spec)
        env.calls.acquire=env.calls.acquire+1
        if env.denied then return Weather.Err('denied','not admitted') end
        if env.unavailable then return Weather.Err('unavailable','waiting') end
        return env.model:Acquire('feather-character',spec,env.now/1000)
    end
    function api:UpdateOverride(handle,spec)
        env.calls.update=env.calls.update+1
        return env.model:Update('feather-character',handle,spec,env.now/1000)
    end
    function api:ReleaseOverride(handle)
        env.calls.release=env.calls.release+1
        if env.failRelease then error('test release failure') end
        return env.model:Release('feather-character',handle)
    end
    function api:GetLocalState()
        if env.badState then return {ok=true,value={effective={channels={}}}} end
        if env.delayUntil and env.now<env.delayUntil then return Weather.Err('unavailable','application pending') end
        local winners,count=env.model:Resolve(env.now/1000)
        local clock=winners.clock and winners.clock.value or 32400
        local weather=winners.weather and winners.weather.value or {name='rain'}
        return Weather.Ok({effective={clock=clock,weather=weather,wind={direction=0,speed=0},
            snow=false,channels=winners,overrideCount=count}})
    end
    exports={['feather-weather']=api}
    dofile('client/environment.lua')
    env.adapter=CharacterV2Environment
    env.thread=coroutine.create(env.threads[1])
    assert(coroutine.resume(env.thread))
    function env:step(ms)
        self.now=self.now+(ms or 1000)
        local ok,message=coroutine.resume(self.thread); assert(ok,message)
    end
    function env:count() local _,count=self.model:Resolve(self.now/1000); return count end
    return env
end
test('selector acquires only the four local presentation channels',function()
    local e=setup(); assert(e.adapter.Enter('selector'))
    eq(e.calls.acquire,1); eq(e:count(),1); eq(e.adapter.State().status,'active')
    local winners=e.model:Resolve(0); eq(winners.clock.value,43200); eq(winners.snow.value,false)
end)
test('carousel reuse does not allocate or update additional handles',function()
    local e=setup(); e.adapter.Enter('selector')
    for _=1,5 do assert(e.adapter.Enter('selector')) end
    eq(e.calls.acquire,1); eq(e.calls.update,0); eq(e:count(),1)
end)
test('creator and cancel-to-selector update the same owned handle',function()
    local e=setup(); e.adapter.Enter('selector')
    CharacterV2Config.sceneEnvironment.creator.clock=64800
    assert(e.adapter.Enter('creator')); eq(e.calls.update,1); eq(e:count(),1)
    local winners=e.model:Resolve(0); eq(winners.clock.value,64800)
    assert(e.adapter.Enter('selector')); eq(e.calls.update,2); eq(e:count(),1)
end)
test('long creator sessions renew before TTL without extra handles',function()
    local e=setup(); e.adapter.Enter('creator')
    for _=1,10 do e:step(30000); eq(e:count(),1) end
    eq(e.calls.acquire,1); eq(e.calls.update,10)
end)
test('foreground reveal waits for application readiness',function()
    local e=setup(); e.delayUntil=400
    assert(e.adapter.Enter('selector')); eq(e.now,400)
end)
test('missing provider never blocks and recovers during an active scene',function()
    local e=setup(); e.provider='missing'
    assert(not e.adapter.Enter('selector')); eq(e.now,0); eq(e.calls.acquire,0)
    e.provider='started'; e:step(); eq(e:count(),1); eq(e.adapter.State().status,'active')
end)
test('disabled integration never calls optional exports',function()
    local e=setup(); CharacterV2Config.sceneEnvironment.enabled=false
    assert(not e.adapter.Enter('creator')); e:step(); eq(e.calls.acquire,0)
end)
test('invalid limits degrade without blocking Character or throwing',function()
    local e=setup(); CharacterV2Config.sceneEnvironment.renewIntervalMs=0/0
    assert(not e.adapter.Enter('selector')); e:step(); eq(e.calls.acquire,0)
    eq(e.adapter.State().status,'invalid_config')
end)
test('denied owner returns immediately and retries after policy recovery',function()
    local e=setup(); e.denied=true
    assert(not e.adapter.Enter('selector')); eq(e.now,0); eq(e.adapter.State().status,'denied')
    e.denied=false; e:step(); eq(e:count(),1)
end)
test('unready bootstrap has bounded foreground wait then background recovery',function()
    local e=setup(); e.unavailable=true
    assert(not e.adapter.Enter('selector')); eq(e.now,5000)
    eq(e.adapter.State().status,'degraded')
    e.unavailable=false; e:step(); eq(e:count(),1)
end)
test('malformed state envelope cannot crash scene reveal',function()
    local e=setup(); e.badState=true
    assert(not e.adapter.Enter('selector')); eq(e.now,5000)
end)
test('activation releases handle and worker cannot reacquire',function()
    local e=setup(); e.adapter.Enter('creator'); assert(e.adapter.Leave('activation'))
    eq(e:count(),0); local before=e.calls.acquire
    e:step(60000); eq(e.calls.acquire,before); eq(e.adapter.State().view,nil)
end)
test('bootstrap cleanup releases and a later retry reacquires once',function()
    local e=setup(); e.adapter.Enter('selector'); e.adapter.Leave('bootstrap_cleanup')
    eq(e:count(),0); assert(e.adapter.Enter('selector')); eq(e.calls.acquire,2)
end)
test('logout/reentry starts a fresh scene and idempotent release is safe',function()
    local e=setup(); e.adapter.Enter('selector'); e.adapter.Leave('activation'); e.adapter.Leave('again')
    assert(e.adapter.Enter('selector')); eq(e:count(),1); eq(e.calls.acquire,2)
end)
test('Weather restart reacquires only while a scene is wanted',function()
    local e=setup(); e.adapter.Enter('creator')
    e.provider='stopped'; e.handlers.onClientResourceStop('feather-weather')
    e.model=WeatherOverrides.New(WeatherConfig,'two'); e:step(); eq(e:count(),0)
    e.provider='started'; e:step(); eq(e:count(),1)
    e.adapter.Leave('activation'); e.handlers.onClientResourceStop('feather-weather')
    e.model=WeatherOverrides.New(WeatherConfig,'three'); e:step(); eq(e:count(),0)
end)
test('expired handle is replaced once after a stalled creator worker',function()
    local e=setup(); e.adapter.Enter('creator'); e:step(121000)
    eq(e:count(),1); eq(e.calls.acquire,2)
end)
test('failed release retries without extending lifetime or reacquiring',function()
    local e=setup(); e.adapter.Enter('selector'); e.failRelease=true
    assert(not e.adapter.Leave('activation')); eq(e.adapter.State().status,'release_pending')
    e:step(); eq(e.calls.acquire,1); eq(e.calls.update,0)
    e.failRelease=false; e:step(); eq(e:count(),0)
end)
test('Leave cancels an in-flight foreground readiness wait',function()
    local e=setup(); e.delayUntil=99999
    e.onWait=function() e.adapter.Leave('cancelled'); e.onWait=nil end
    assert(not e.adapter.Enter('selector')); eq(e:count(),0); e:step(); eq(e.calls.acquire,1)
end)
test('Character stop explicitly releases owned handles',function()
    local e=setup(); e.adapter.Enter('creator'); e.handlers.onClientResourceStop('feather-character')
    eq(e:count(),0); eq(e.adapter.State().view,nil)
end)
test('timer wrap does not prevent renewal',function()
    local e=setup(); e.now=4294967000; e.adapter.Enter('selector')
    e.now=30000; e:step(1000)
    eq(e.calls.update,1)
end)
print(('Character scene environment: %d checks passed (mocked Cfx, real handle model).'):format(passed))

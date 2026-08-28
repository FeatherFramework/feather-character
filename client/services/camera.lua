-- Scripted camera helper used throughout character select/creation/spawn
-- (there's exactly one active `camera` at a time -- switching screens calls
-- StartCam again rather than juggling multiple cams).
local camera

function StartCam(x, y, z, heading, zoom)
    DestroyAllCams(true)
    camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x, y, z, -10.0, 00.00, heading, zoom, true, 0)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 500, true, true, 0)
    return camera
end

function SwitchCam(x, y, z, heading, zoom)
    SetCamParams(camera, x, y, z, -10.0, 0.0, heading, zoom, 1500, 1, 3, 1)
end

function FollowCam(entity, distance, height)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
    if camera then DestroyCam(camera, false) end
    camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    AttachCamToEntity(camera, entity, 0.0, -(distance or 8.0), height or 4.0, true)
    PointCamAtEntity(camera, entity, 0.0, 0.0, 1.0, true)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 750, true, true, 0)
    return true
end

function EndCam()
    RenderScriptCams(false, true, 1000, true, false, 0)
    DestroyCam(camera, false)
    camera = nil
    DestroyAllCams(true)
    SetFocusEntity(PlayerPedId())
end

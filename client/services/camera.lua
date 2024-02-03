local camera, show

function StartCam(x, y, z, heading, zoom)
    Citizen.InvokeNative(0x17E0198B3882C2CB, PlayerPedId())
    DestroyAllCams(true)
    camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x, y, z, -10.0, 00.00, heading, zoom, true, 0)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 500, true, true)
    return camera
end

function SwitchCam(x, y, z, heading, zoom)
    SetCamParams(camera, x, y, z, -10.0, 0.0, heading, zoom, 1500, 1, 3, 1)
end

function EndCam()
    RenderScriptCams(false, true, 1000, true, false)
    DestroyCam(camera, false)
    camera = nil
    DestroyAllCams(true)
    SetFocusEntity(PlayerPedId())
end

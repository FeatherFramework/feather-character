UIState = false

local function setNuiData()
    SendNUIMessage({
        type = 'toggle',
        visible = UIState,
        config = {
            defaults = Config.defaults
        }
    })
end

function SetUIState(state)
    UIState = state
    setNuiData()
end

function ToggleUIState()
    UIState = not UIState
    setNuiData()
end

RegisterCommand('ToggleCMenu', function()
    ToggleUIState()
end)


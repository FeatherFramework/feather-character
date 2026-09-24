-- Tracks selection, live-player creation, and world activation phases.
CharacterV2Flow = {}

local phase = 'idle'
local generation = 0
local transitions = {
    idle = { selection = true },
    selection = { creator = true, activating = true, idle = true },
    creator = { selection = true, activating = true, idle = true },
    activating = { world = true, selection = true, idle = true },
    world = { selection = true, idle = true }
}

function CharacterV2Flow.State()
    return { phase = phase, generation = generation }
end

function CharacterV2Flow.Transition(nextPhase)
    if not transitions[phase] or transitions[phase][nextPhase] ~= true then
        return CharacterV2Result.Err('invalid_transition',
            ('Cannot transition from %s to %s.'):format(phase, tostring(nextPhase)))
    end
    phase = nextPhase
    generation = generation + 1
    return CharacterV2Result.Ok(CharacterV2Flow.State())
end

function CharacterV2Flow.IsCurrent(ticket)
    return type(ticket) == 'table' and ticket.phase == phase
        and ticket.generation == generation
end

function CharacterV2Flow.Reset()
    phase = 'idle'
    generation = generation + 1
    return CharacterV2Result.Ok(CharacterV2Flow.State())
end

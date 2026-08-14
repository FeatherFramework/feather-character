-- Forces a specific world door (near the character creation/select area)
-- into a known-open state so it doesn't block the creation camera framing
-- or the walk-to-camera path in create.lua.
function SetupDoor()
    if not IsDoorRegisteredWithSystem(3277501452) then
        AddDoorToSystemNew(3277501452, true, true, false, 0, 0, false)
    end
    DoorSystemSetDoorState(3277501452, 0)
end
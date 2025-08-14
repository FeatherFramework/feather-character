function SetupDoor()
    if not IsDoorRegisteredWithSystem(3277501452) then
        AddDoorToSystemNew(3277501452, true, true, false, 0, 0, false)
    end
    DoorSystemSetDoorState(3277501452, 0)
end
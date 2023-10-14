function SetupDoor()
    if not IsDoorRegisteredWithSystem(3277501452) then
        Citizen.InvokeNative(0xD99229FE93B46286, 3277501452, 1, 1, 0, 0, 0, 0)
    end
    DoorSystemSetDoorState(3277501452, 0)
end
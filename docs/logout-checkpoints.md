# Logout checkpoints and Weapons integration

Dependent client resources register their own export using
`RegisterLogoutCheckpoint(name, exportName)`. Character forwards the logout
context through the CFX resource proxy with the resource receiver argument.
The remote handler may be a callable CFX function-reference table; it is not
required to be an ordinary Lua function.

An exception, malformed response or unsuccessful Result vetoes logout. Stopped
resource registrations are removed; one resource cannot replace another's
checkpoint registration. Character does not grant, remove or save ammunition.

Run `lua tests/checkpoints_spec.lua` from this resource's root with Lua 5.4.
The self-contained regression covers proxy/context forwarding, callable references,
registration ownership, refusal/exception/malformed-result veto and stop cleanup.
Weapons also retains its cross-resource release integration regression.

Live acceptance, 2026-10-12: the scoped native Weapons host released through
logout and restored on Jane login without a Weapons restart. Inventory/Equipment
closed at selection and stayed closed on login; subsequent player equip/unequip
worked. Final Inventory verification retained item112 revision1, ammo ledger21,
carried0, loose2 and receipts22. This does not establish exhaustive in-flight
logout/death, disconnect, crash or multiplayer recovery coverage.

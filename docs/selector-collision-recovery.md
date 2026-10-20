# Selector collision startup recovery

Implemented 2026-10-19; live verification on the affected second PC is pending.

Reported failure: character list and appearance snapshot succeeded, then
`Open preview: preview_timeout The selector stage collision did not load.`
Weapons subsequently waited for character readiness; it did not request a loadout.

The source player was unfrozen before stage collision loaded, and bootstrap
failure left the local flow in `selection`, preventing ordinary Begin retries.
The log does not independently establish why collision was slow on that PC.

The selector now keeps its hidden source frozen, explicitly restores source
collision before requesting the distant stage, and checks source identity and
generation during the bounded wait. Timeout cleans owned presentation objects;
it never deletes the player. Cancellation does not clean up a newer generation.
The existing configured collision timeout is unchanged.

Startup retries transient selector preview/model/render timeouts at most three
times, with a one-second pause and menu/preview cleanup plus local flow reset
between attempts. Other failures do not auto-retry. Exhaustion remains hidden
and frozen in idle and logs the F8 command `characterSelectionRetry`. That command
is available only after a clean failed bootstrap, never while opening, selecting,
creating, activating or in world. Spawned events cannot silently start another
exhausted batch. Cleanup uncertainty stops retries and instructs reconnect.
No character activation, persistence or equipment/ammo grant occurs in retries.

Automated validation: all six Character Lua specs and runtime syntax PASS.
New tests execute actual preview/main implementations with mocked native/RPC/UI
ports: delayed collision, numeric BOOL, stale source collision, timeout/retry,
cancelled generation, clone cleanup, third-attempt success, exhausted/manual
recovery, overlap prevention, nontransient failure, cleanup failure and activation
race. These tests do not prove actual RedM streaming timing or visual behavior.

Deploy only `client/main.lua` and `client/preview.lua`. No config, manifest or SQL
change; no new-script refresh is required. Fully disconnect both clients before
restarting Character; avoid hot-restarting selection authority under active players.
Reconnect the affected second PC first. Confirm character selection opens, then
select the character and confirm normal readiness. If streaming still times out,
capture attempt/timeout logs and use the logged manual retry command once; do not
force character activation or grant Weapons to bypass readiness.

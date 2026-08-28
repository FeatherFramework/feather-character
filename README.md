# Feather Character

> Welcome to Feather Character, the official character creator for the Feather Framework.

## Features

- Character customization
- Character creator
- Character selector

## First time setup

[https://featherframework.net/guide](https://featherframework.net/guide)

## API Documentation and Usage

[https://featherframework.net/api](https://featherframework.net/api)

## Rebuild status

Feather Character is entering a clean-slate Contract 1 rebuild. The target resource will own character profiles, creation, selection, appearance, and spawn state while Feather Core owns account identity and active session binding. Roles, permissions, currency, inventory, and weapons remain separate domains.

The detailed build order, contracts, test gates, and current checklist are maintained in `MASTER_PLAN.md`. Architecture decisions are recorded in `docs/architecture-contract-1.md`.

The Contract 1 persistence foundation is live. After a full server restart, run this in the server console:

```text
CharacterPersistenceSmokeTest
```

It verifies the migration ledger, idempotent migrations, atomic profile/appearance/spawn creation, ownership scoping, and public snapshot filtering. These tables now back the live selector and creator.

Then run:

```text
CharacterProfileContractSmokeTest
```

This verifies the three versioned profile routes, the Core provider registration, persistent idempotent creation, provider ownership checks, and filtered provider snapshots.

The versioned appearance service is live. Run:

```text
CharacterAppearanceSmokeTest
```

It checks the appearance routes, initial revision, successful revision increment, stale-write rejection, persisted document, and rejection of unknown document sections.

After the appearance test passes, run:

```text
CharacterActivationContractSmokeTest
```

This checks activation/spawn/logout routes, lifecycle events, configured spawn resolution, session-bound plans, ownership rejection, and Core session input validation.

## Contract 1 character flow

The selector and creator use Contract 1 exclusively. New characters are UUID
profiles stored in Character-owned tables. Creation atomically saves the profile,
initial appearance, and server-owned spawn point, then activates it and plays the
configured city-arrival journey. Selecting an existing character activates its Core session, applies
its versioned appearance, uses the authorized spawn plan, and acknowledges spawn
completion.

Legacy numeric characters are intentionally not copied into the new profile
store and will not appear in this mode. During initial testing, create a new
character. After spawning it, run:

```text
CharacterLiveCutoverSmokeTest [serverId]
InvCharacterUuidSmokeTest [serverId]
WeaponCharacterIdentitySmokeTest [serverId]
```

The expected totals are `6/6`, `6/6`, and `5/5` respectively.

## Character deletion

Players can soft-delete a character from the selection menu through a dedicated
confirmation page. The server independently verifies ownership and requires an
explicit confirmation, and refuses to delete the currently active character. Deleted profiles disappear
from selection immediately while their appearance, spawn, inventory, and weapon
records remain available for future recovery tooling.

Deletion behavior is configured under `Config.Character.deletion`:

- `requireConfirmation` requires an explicit confirmed deletion request.
- `minimumAgeHours` prevents deleting characters newer than the configured age.
- `recoveryDays` records the intended retention window for future restore/purge tooling.

Run `CharacterDeletionContractSmokeTest` from the server console after a full
restart. All six checks should pass.

## Logout and position persistence

Character owns the `/logout` command. While a character is active, its position
is persisted at `Config.Contract1.positionSyncMs` intervals. Logout performs a
final position save, closes the Core character session, notifies dependent
client resources, and returns the player to character selection. The next time
that character is selected, the server-authorized spawn plan uses the saved
position.

After a full restart, run `CharacterActivationContractSmokeTest`. The expanded
test should pass all eight checks.

## Death and doctor respawn

While a Contract 1 character is active, Character disables RedM's generic
automatic respawn. A dead player keeps the same metaped, position, session,
inventory, and equipment. After the configured countdown, holding the respawn
prompt revives the player at the nearest configured doctor's office and saves
that position. Staff may revive the player at the death location before the
timer ends.

The respawn prompt uses `G`. Death is scoped to the active session; logging out
or reconnecting starts the selected character alive. Cross-session persistent
death is deliberately deferred to a future medical/death-system phase.

Configure the delay, prompt control, camera, restored health, and doctor
locations under `Config.Contract1.death`. Doctor placement uses Core's safe
teleport contract. The respawn prompt remains Character-local because RedM
prompt handles must be created and rendered by the consuming client resource.
A complete medical/injury resource may later replace the rules while retaining
these Character lifecycle boundaries.

## Core Contract 1 cutover

Character no longer imports Core's legacy `initiate()` API, Character cache, or
legacy activation/spawn services. It uses named Core readiness, RPC, locale,
notification, account-session, provider, event, and instance contracts. Selection
objects and preview peds are private Character presentation helpers.

After a full server restart, run:

```text
CharacterCoreCutoverSmokeTest
```

All five checks should pass. Then verify selection, creation, activation, `/logout`,
inventory, weapons, and Admin identity in one connected session.

## Troubleshooting

If you encounter any issues or have questions, post in our [discords](https://discord.gg/zBCPbPJGZw) bugs and support channel. You may also open an issue on the issue tracker tab of GitHub.

## Contributing

Contributions to the any of our Feather scripts are welcome! If you have improvements or bug fixes, feel free to submit a pull request.

## License

This inventory script is licensed under GPL3 License. Refer to the LICENSE file for more information.


## Current roadmap

- Character-owned UUID profile and appearance persistence
- Atomic creation and authoritative ownership checks
- Core session-based selection, activation, spawn, logout, and switching
- Versioned appearance documents and deterministic restoration
- Server-owner configuration, diagnostics, and smoke tests
- New selection/creation UI after the server contracts are proven
- Inventory, weapons, admin, economy, and role-provider integration
- Removal of all legacy Core Character APIs and compatibility bridges
<img width="1918" height="1079" alt="image1" src="https://github.com/user-attachments/assets/41f1b620-3d8e-4e01-919f-b17b67030790" />
<img width="1919" height="1075" alt="image2" src="https://github.com/user-attachments/assets/29318cab-0758-483b-a94a-b78d1c1d0e72" />
<img width="1919" height="1079" alt="image3" src="https://github.com/user-attachments/assets/a6be8da3-9fc9-4c85-882a-77bcabf69046" />
<img width="1915" height="1053" alt="image4" src="https://github.com/user-attachments/assets/c9e546b7-3cc7-4d2d-afdb-f979d704294a" />
<img width="1917" height="1075" alt="image5" src="https://github.com/user-attachments/assets/04389c8b-a1a9-4cff-8ac0-25fdf4394886" />
<img width="1919" height="1074" alt="image6" src="https://github.com/user-attachments/assets/ad6f1b90-626d-4c85-922d-81da9c47c91b" />
<img width="1919" height="1079" alt="image7" src="https://github.com/user-attachments/assets/73104fe8-9547-4bd1-a3a6-07e81cb70dbd" />

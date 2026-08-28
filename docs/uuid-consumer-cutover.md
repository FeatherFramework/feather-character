# Character UUID Consumer Cutover

Status: live Contract 1 selector passed; Inventory and Weapons are UUID-only

## Why the live switch remains off

Feather Character can now create UUID profiles, resolve appearance, build spawn plans, and activate Core sessions. Enabling that flow today would create a valid Character/Core session but leave Inventory unable to resolve it. Inventory still treats character IDs as numeric values and several tables reference the legacy `characters(id)` key.

The cutover must use one canonical UUID. A permanent UUID-to-integer compatibility map is rejected because it would preserve two identities for every character, allow consumers to disagree about authority, and keep the legacy Character schema alive indefinitely.

## Required order

1. Inventory accepts canonical UUID character IDs throughout its public and internal APIs.
2. Inventory-owned schemas store character IDs as `CHAR(36)` and no longer reference legacy `characters(id)`.
3. Inventory resolves the current actor through Core `GetSessionContext`/RPC context rather than `Feather.Character.GetCharacter`.
4. Weapons removes remaining numeric coercion and consumes the UUID-capable Inventory contract.
5. Character enables the Contract 1 client list/create/activate/spawn flow.
6. Admin moves identity/audit/moderation fields to UUID strings and provider snapshots.
7. Legacy Core Character records, cache dependencies, events, and tables are removed.

## Inventory changes required

### Schema

- Change character ownership columns from `BIGINT`/`INT` to `CHAR(36)`:
  - `inventory.character_id`
  - `inventory.owner_character_id`
  - `inventory_access.character_id`
  - `inventory_access.granted_by_character_id`
  - `character_equipment.character_id`
- Remove foreign keys to legacy `characters(id)`.
- Do not add a foreign key across resource-owned schemas. Character ownership is verified through the Character provider and Core session context.
- Rebuild development tables or provide an explicit migration before production release.

### Runtime/API

- Remove `tonumber(characterId)` validation and normalization.
- Validate canonical UUID strings at Inventory boundaries.
- Replace `Feather.Character.GetCharacter({ src = source })` with Core session/account context.
- Subscribe to `core.session.ready.v1`, `core.session.leaving.v1`, and `core.session.left.v1`, or the Character lifecycle equivalents where profile readiness is specifically required.
- Key inventory lookup, access grants, equipment, transaction context, and diagnostics by UUID.
- Keep item-instance IDs numeric if desired; only character identity changes.
- Add a UUID smoke test covering inventory creation, lookup, access, equipment, reconnect, and session leaving.

### Known files/areas from the current audit

- `server/controllers/inventory.lua`
- `server/services/character.lua`
- `server/services/callbacks.lua`
- `server/services/commands.lua`
- `server/services/equipment.lua`
- `server/services/instances.lua`
- `server/services/inventory.lua`
- `server/services/inventory_access.lua`
- `server/services/items.lua`
- `server/services/ground.lua`
- `server/services/transactions.lua`
- client listeners that currently wait for `Feather:Character:Spawned`

## Weapons changes required

- [x] Replace the legacy Core Character adapter with named Core session exports.
- Remove `tonumber` checks from issuance and any character-ID comparisons.
- Subscribe to Contract 1 session/Character lifecycle events.
- Confirm equipment and inventory adapter calls accept UUIDs end to end.
- Run equip/reload/fire/attachment/repair/reconnect tests with two UUID characters.

Weapons item instance IDs, weapon serials, metadata revisions, ammo handling, and transaction behavior do not need to change solely because character identity becomes UUID-based.

## Admin changes required

- Change persisted character ID columns to `CHAR(36)` where the value represents a Character Contract 1 ID.
- Stop using `tonumber(characterId)` and direct `characters`/`users` joins.
- Resolve online identity through Core session context and Character provider snapshots.
- Move role mutation away from `characters.role_id`; roles are a separate provider/domain in the new architecture.
- Keep account/platform identifiers separate from character UUIDs in moderation and audit records.

Admin is not a blocker for basic gameplay activation, but its player list and character-targeted actions must be disabled or migrated before the legacy schema is deleted.

## Character enablement gate

The live Contract 1 selector may be enabled only when:

- Inventory accepts and persists UUID ownership.
- A UUID session creates/opens the correct character inventory.
- Inventory leaving cleanup completes without legacy cache access.
- Weapons restores equipment for the UUID session.
- Reconnect and character switching do not cross-load inventory or equipment.

The Inventory and Weapons gates now pass. Selection, creation, activation, and
spawn use Contract 1 without a legacy fallback. The final combined client
cutover passed its live regression tests.

## Current implementation checkpoint

- Inventory UUID normalization and Core session resolution are live.
- Inventory, access-grant, equipment, instance, and transactional-creation paths preserve UUID strings.
- New recipe schema uses `CHAR(36)` without legacy Character foreign keys.
- Existing databases have an explicit one-time schema script.
- `InvCharacterUuidSmokeTest` passed 6/6 against the migrated schema.
- `WeaponCharacterIdentitySmokeTest` passed 5/5 during the bridge gate.
- The live client selector/creator now creates UUID profiles and returns them to selection.
- `CharacterLiveCutoverSmokeTest` verifies the first connected UUID character.
- Inventory and Weapons are now UUID-only; numeric character identities are rejected.

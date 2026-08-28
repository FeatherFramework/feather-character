# Feather Character — Clean-Slate Master Plan

> **Planning premise:** backward compatibility is not required. Existing exports, events, RPC names, database tables, configuration, UI flow, and file layout may be replaced. The current implementation remains only as a temporary test bridge until each replacement slice passes its acceptance tests.

## Current implementation status

- [x] Current resource and Core coupling audited.
- [x] Character/Core ownership boundary defined.
- [x] Contract 1 architecture decisions recorded.
- [x] Temporary Core readiness/session bridge installed and subsequently removed.
- [x] Phase 1 lifecycle, migration, and repository foundation staged for runtime verification.
- [x] Character-owned schema and checksummed migrations.
- [x] Character profile repository and ownership service.
- [x] Contract 1 list/create/get routes and profile provider.
- [x] Selection and session-activation state machine staged for live testing.
- [x] Appearance document and revision service.
- [x] Spawn orchestration and session activation server contracts.
- [x] Contract 1 selection/list/preview path is live.
- [x] Contract 1 creation submits profile, appearance, and spawn state atomically and returns to selection.
- [x] Contract 1 self-service soft deletion with an explicit confirmation page and active-session protection.
- [x] Character-owned periodic/final position persistence and `/logout` return-to-selection flow staged.
- [x] Character runtime cut off Core's legacy `initiate()`, Character API/cache,
  generic object/ped helpers, notification RPC, and direct DataView import.
- [x] Preview bodies, clothing, ground placement, and hair render deterministically on the initial selector load.
- [x] Inventory, weapons, and admin identity consumers use stable UUID/session/provider contracts.
  - [x] Inventory UUID-only character-ID contract passed 6/6.
  - [x] Weapons UUID-only character-ID contract passed 5/5.
  - [x] Admin account/character identity and policy domains cut over and smoke-tested.
- [x] Character-side legacy Core bridge removed.
- [x] Core legacy Character code removed after dependent consumers migrated.
- [x] Active Character sessions own death state by disabling generic
  spawnmanager respawns; staff revive can operate on the original metaped.
- [ ] Legacy database tables remain retained until the separate data-cleanup gate passes.

## 1. Purpose

Feather Character owns the complete lifecycle of a playable character from creation through selection, activation, spawning, play, logout, and deletion. It is the authority for character profiles, appearance, and spawn state. Feather Core supplies account identity, secure transport, active-session binding, provider registration, policy evaluation, guards, and operational health.

The rebuilt resource must make these questions easy to answer:

- Which characters belong to this connected account?
- Can this account create, select, rename, or delete this character?
- Which character profile and appearance revision are current?
- Is character activation still valid for the same Core account and session?
- Where and how should this character spawn?
- Which parts of a profile may a client propose, and which are server-controlled?
- How do dependent resources obtain a safe, versioned character snapshot?
- Why did creation, selection, appearance save, or spawn fail?

## 2. Product goals

- Own character records outside Feather Core.
- Use durable UUID character IDs; keep numeric database keys private if retained at all.
- Provide one server-authoritative create/select/activate/logout lifecycle.
- Use Core Contract 1 result envelopes, context, sessions, routes, providers, policy, and guards.
- Make every mutation ownership-scoped, validated, atomic, and concurrency-safe.
- Store appearance as a versioned document with optimistic concurrency control.
- Separate durable character state from transient client presentation.
- Make spawn location server-authoritative and presentation client-side.
- Publish narrow character snapshots instead of mutable database records.
- Make character limits, models, names, dates, spawn points, and deletion rules configurable and validated.
- Provide server-owner diagnostics and repeatable smoke tests.
- Preserve a playable server during staged construction, then remove every compatibility bridge.

## 3. Non-goals

Character will not own:

- Platform identifiers, account records, connection gates, or session IDs; Core owns them.
- Inventory contents, equipment, weapons, ammunition, or attachments.
- Authorization infrastructure or hardcoded admin levels.
- Jobs, gangs, permissions, or framework-wide roles.
- General-purpose bank/account ledgers or arbitrary currency mutation.
- Injuries, treatment gameplay, medical jobs, billing, and persistent wounds.
  Character owns only the baseline death, staff-revive, and doctor-respawn
  lifecycle required to preserve an active character session.
- Horses, wagons, housing, crafting, shops, needs, progression, or skills.
- Generic menus, notifications, cameras, peds, objects, or other reusable client helpers.
- A public SQL or mutable-cache API.

Character may publish identity and lifecycle facts that those resources consume, but it will not absorb their domain state.

## 4. Clean-slate rules

- No new code may depend on `exports['feather-core'].initiate()`.
- No new public contract uses positional multi-returns, implicit globals, or raw database rows.
- Do not preserve integer character IDs as public identity.
- Do not trust client-supplied account IDs, character IDs outside ownership scope, role IDs, balances, position, model hashes, or appearance payload shape.
- Do not update schema from controller startup code.
- Do not mix character creation, appearance persistence, session activation, and spawn presentation in one operation.
- Do not keep a compatibility alias after every first-party consumer has moved.
- Prefer a clean development database rebuild. A production migration/rebuild guide is required before release.
- Delete replaced code only after its replacement passes contract and gameplay tests.

## 5. Ownership boundary

| Concern | Target owner | Character responsibility |
| --- | --- | --- |
| Account identity | `feather-core` | Consume authoritative `accountId` from request context |
| Active session binding | `feather-core` | Request activate/leave only after Character validates ownership |
| Character profile | `feather-character` | Own schema, validation, repository, snapshots, lifecycle |
| Appearance | `feather-character` | Own versioned document and application contract |
| Spawn state | `feather-character` | Own allowed spawn references and persisted last position |
| Spawn presentation | `feather-character` client | Cameras, selection room, transitions, arrival sequence |
| Roles/permissions | policy or dedicated role resource | Expose character identity to policy context only |
| Money/gold/tokens | dedicated economy/ledger resource | No balances in the new character row |
| Inventory/equipment | `feather-inventory` | Receive session lifecycle and stable character ID |
| Weapons | `feather-weapons` | Receive active character session through Core |
| Baseline death/respawn | `feather-character` | Preserve the active session and provide configurable doctor respawn |
| Medical gameplay | dedicated medical resource | Injuries, treatment, jobs, billing, and persistent wounds |
| Admin operations | `feather-admin` | Use Character issuance/management APIs with policy checks |

### 5.1 Boundary decisions

- Roles are not character columns in Contract 1. Policy consumes a provider-owned role/capability model.
- Currency is not character profile data. Starting funds are issued by an economy provider after character creation commits.
- `description` and portrait URL are optional profile fields with strict size/scheme validation.
- Current position is a spawn-state concern, not client-authored profile data.
- Appearance is separate from the profile so its larger document and revisions do not inflate routine list/select queries.

## 6. Target architecture

```text
feather-core
  account context + RPC context + session kernel + providers/policy/guards
       |
       v
feather-character
  bootstrap
  +-- migrations and repositories
  +-- profile/ownership service
  +-- creation service
  +-- appearance service
  +-- selection/activation service
  +-- spawn service
  +-- character provider + diagnostics
       |
       +--> client selection/creation/appearance/spawn presentation
       +--> inventory, weapons, admin, economy, roles, medical
```

### 6.1 Suggested layout

```text
feather-character/
  config/
    defaults.lua
    schema.lua
    spawn_points.lua
  shared/
    contracts/
      errors.lua
      profile.lua
      appearance.lua
      lifecycle.lua
    validation/
  server/
    bootstrap/
    migrations/
    repositories/
      characters.lua
      appearances.lua
      spawn_state.lua
    services/
      profiles.lua
      creation.lua
      appearance.lua
      activation.lua
      spawn.lua
      deletion.lua
    transport/
      routes.lua
      provider.lua
    operations/
      logging.lua
      health.lua
  client/
    bootstrap.lua
    state.lua
    flows/
      selection.lua
      creation.lua
      activation.lua
      spawn.lua
    appearance/
    presentation/
  tests/
  docs/
```

Modules return explicit tables and receive dependencies explicitly. File order must not create hidden global dependencies.

## 7. Domain model

### 7.1 Character profile

Public character profile:

```lua
{
  characterId = 'uuid',
  firstName = 'John',
  lastName = 'Doe',
  dateOfBirth = '1860-01-01',
  model = 'mp_male',
  description = nil,
  portraitUrl = nil,
  status = 'active',
  createdAt = 'UTC timestamp',
  updatedAt = 'UTC timestamp'
}
```

The public snapshot excludes account IDs, private database keys, balances, permissions, raw JSON, internal revisions not needed by the caller, and other resources' state.

### 7.2 Appearance document

```lua
{
  characterId = 'uuid',
  revision = 3,
  schemaVersion = 1,
  model = 'mp_male',
  attributes = {},
  clothing = {},
  overlays = {},
  tints = {},
  updatedAt = 'UTC timestamp'
}
```

- JSON must decode to the documented shape.
- Category names, value types, counts, nesting depth, and encoded byte size are bounded.
- Saves require `expectedRevision`; stale writes return `conflict`.
- Model and component compatibility are server-validated against trusted catalogs.
- Appearance save and profile update are separate operations.

### 7.3 Spawn state

```lua
{
  characterId = 'uuid',
  mode = 'first_spawn' | 'last_position' | 'configured',
  spawnPointId = 'valentine',
  position = { x = 0.0, y = 0.0, z = 0.0, heading = 0.0 },
  revision = 1,
  updatedAt = 'UTC timestamp'
}
```

Clients select only an allowed `spawnPointId`. Raw coordinates are accepted only from an authenticated server-owned position service and are validated before persistence.

### 7.4 Character status

`active`, `pending_delete`, `deleted`, and `suspended` are explicit states. Deleted records are never selectable. Deletion policy decides whether deletion is immediate or delayed; hard deletion is not the default operational action.

## 8. Persistence

Target tables:

- `character_schema_migrations`
- `character_profiles`
  - UUID primary/public ID
  - Core account UUID foreign reference by contract, not cross-resource SQL joins
  - normalized identity/profile fields
  - status and timestamps
  - unique/account indexes required for ownership queries
- `character_appearance`
  - character UUID
  - schema version, revision, bounded JSON document, timestamps
- `character_spawn_state`
  - character UUID
  - mode, configured point, validated last position, revision, timestamps

Rules:

- Character repositories are the only writers to Character tables.
- Migrations are ordered and checksum-verified before readiness.
- Character creation inserts profile, initial appearance, and initial spawn state in one transaction.
- The per-account character limit is enforced inside the transaction with locking/concurrency protection.
- UUIDs are generated server-side.
- List queries select only list-card fields; full appearance is fetched only when required.
- Cross-resource ownership is verified through contracts, not direct joins to Core tables.
- Legacy `characters`, `character_appearance`, and role/balance columns are removed after cutover.

## 9. Lifecycle state machines

### 9.1 Connection and selection

```text
Core account ready
  -> Character list loading
  -> selecting | creating
  -> activation pending
  -> Core session ready
  -> appearance applied
  -> spawn authorized
  -> playing
```

Every transition has one owner, one correlation ID, a timeout, and a recoverable failure state.

### 9.2 Creation

```text
idle -> draft client-side -> submitted -> validating -> committing
     -> created -> selection
     -> rejected (editable draft)
```

- A duplicate submit cannot create a second record.
- Client preview data has no authority until committed.
- Creation emits one post-commit event.
- Starting inventory, money, clothing ownership, or other onboarding rewards are issued by subscribers/providers after creation, with idempotency keys.

### 9.3 Activation

1. Resolve authoritative Core account context.
2. Lock/read the requested Character profile by `characterId` and account ownership.
3. Reject unavailable, suspended, deleted, or already active characters.
4. Ask Core to activate a new UUID session.
5. Return profile, appearance, and spawn authorization tied to that session ID.
6. Client applies presentation and acknowledges spawn completion.
7. Publish `character.spawned.v1` only for the current session.

If any step fails, no partial Character authority is retained. A delayed acknowledgement for an old session is rejected.

### 9.4 Logout/switch/disconnect

```text
playing -> leaving -> dependent guards/hooks -> persist safe state
        -> Core session left -> selection or disconnect
```

- Logout and switch are server-authorized actions.
- Dependent resources receive a bounded synchronous leaving hook where required.
- Session currency is rechecked before final persistence.
- Disconnect cleanup cannot depend on the client responding.
- A resource restart clears runtime state and reconstructs only from Core's current session plus Character persistence.

## 10. Public Contract 1

All public operations use Core result envelopes. Expected rejections never throw.

### 10.1 Capabilities

```lua
{
  resource = 'feather-character',
  contract = 1,
  state = 'ready',
  features = {
    profiles = 1,
    creation = 1,
    appearance = 1,
    activation = 1,
    spawn = 1,
    provider = 1,
    health = 1
  }
}
```

### 10.2 Client-to-server routes

- `character.list.v1`
- `character.create.v1`
- `character.get.v1`
- `character.appearance.get.v1`
- `character.appearance.update.v1`
- `character.activate.v1`
- `character.spawn.complete.v1`
- `character.logout.v1`
- `character.delete.v1`

Each route declares schema validation, maximum bytes/depth/nodes, rate limits, timeout, whether a session is required, and its owning resource.

### 10.3 Server exports/provider operations

- `GetCapabilities()`
- `GetHealth()`
- `AwaitReady(timeoutMs)`
- Character provider:
  - `GetProfile(characterId, context)`
  - `GetCurrentProfile(source)`
  - `OwnsCharacter(accountId, characterId)`
  - `ListProfiles(accountId, options)` for trusted server consumers only

No consumer receives repository objects or mutation methods.

### 10.4 Events

- `character.created.v1`
- `character.activation.started.v1`
- `character.ready.v1`
- `character.spawned.v1`
- `character.leaving.v1`
- `character.left.v1`
- `character.appearance.updated.v1`
- `character.deleted.v1`

Post-commit events fire only after their owning transaction commits. Events include IDs, revisions, session ID where applicable, and correlation ID—not full mutable profile documents unless explicitly required.

### 10.5 Error codes

Use Core standard codes plus:

- `character_limit`
- `character_unavailable`
- `name_invalid`
- `date_invalid`
- `model_invalid`
- `appearance_invalid`
- `spawn_invalid`
- `spawn_not_ready`
- `character_active`
- `confirmation_invalid`
- `deletion_cooldown`
- `deletion_blocked`

## 11. Security and authority

- Derive `source`, account, character, session, and caller resource from Core context.
- Ownership checks occur on every read and mutation exposed to a client.
- Recheck session currency immediately before delayed writes and success responses.
- Validate strings by type, normalized length, allowed characters, and byte cap.
- Validate dates as real calendar dates within configured bounds.
- Resolve model and spawn IDs through trusted server catalogs.
- Bound appearance payload size, depth, nodes, categories, and values.
- Rate-limit list/create/activate/update/logout routes independently.
- Use idempotency keys for creation and onboarding side effects.
- Prevent simultaneous activation of one character and concurrent creation beyond the account limit.
- Never accept client balance, role, permissions, inventory, coordinates, or session identity.
- Fail closed if Core, policy, guard, or required provider state is unavailable.
- Redact identifiers, appearance documents, and internal failure data from client errors.

## 12. Configuration

Split configuration into server-only, client-safe, and shared catalogs. Validate at startup.

Server-owner settings include:

- maximum characters per account;
- allowed player models;
- name/date/profile rules;
- deletion policy and delay;
- allowed spawn points and first-spawn behavior;
- position-save interval and validation bounds;
- appearance size/category limits;
- route rate limits and timeouts;
- debug logging and smoke-test commands;
- optional provider requirements for economy, roles, notifications, and onboarding.

Unknown critical keys and invalid values prevent readiness with a precise path and expected value.

## 13. Client and UI rebuild

- Replace global flags and cross-file globals with one explicit client state machine.
- Keep selection, creation, appearance editing, activation, and spawn presentation as separate flows.
- Render character cards from the lightweight list snapshot.
- Fetch appearance per selected character using correlated requests; no fixed `Wait` as synchronization.
- Disable and debounce submitted actions until a result arrives.
- Show stable rejection messages and preserve editable drafts after validation failure.
- Ensure menus/cameras/peds/objects/focus/fades clean up on success, failure, logout, disconnect, and resource stop.
- Apply appearance deterministically and acknowledge the exact revision applied.
- Make keybindings configurable and avoid collisions.
- Design UI around keyboard/controller accessibility and common screen sizes.
- Move reusable object/ped/horse/menu/notification functionality to providers or focused resources instead of importing Core's monolithic client API.

## 14. Integration contracts

### Inventory

- Opens character inventory only after `character.ready.v1`/Core session ready.
- Keys ownership by stable character UUID.
- Flushes/rejects pending mutations when the session leaves.
- Does not query Character tables.

### Weapons

- Restores equipment only for the current session and character UUID.
- Unequips/flushes state during bounded leaving hooks.
- Does not consume profile, role, or appearance internals.

### Admin

- Uses action-based policy and dedicated Character management operations.
- Cannot mutate Character tables or call repository methods.
- Unique inventory/weapon issuance remains with their owning resource.

### Economy and roles

- Register providers with Core.
- Character creation emits idempotent onboarding work; it does not insert balances or role IDs.
- Character snapshots may include provider-composed display summaries only when explicitly versioned.

## 15. Diagnostics and operations

Health reports:

- lifecycle and Contract version;
- migration state/checksums;
- Core dependency contract and provider status;
- active selection/creation/activation/spawn counts;
- current Character/Core session consistency count;
- route/provider/event registration state;
- recent sanitized failures and timeouts;
- repository/cache counts without private data.

Server-console smoke tests are ACE-restricted or console-only and produce a clear PASS/FAIL summary. Production debug logs are gated.

## 16. Testing strategy

### Unit

- Profile/name/date/model validation.
- Appearance schema, bounds, and revision checks.
- Spawn-point resolution and position validation.
- State-machine transitions.
- Snapshot redaction/defensive copying.
- Capability compatibility and error envelopes.

### Persistence/integration

- Clean migration and idempotent restart.
- Concurrent creation cannot exceed account limit.
- Create commits profile, appearance, and spawn state atomically.
- Ownership-scoped list/get/update/delete.
- Stale appearance revision conflicts.
- Failed validation leaves no rows or events.
- Soft delete removes selection eligibility.

### Contract

- Real capabilities and readiness.
- Account context cannot be overridden by payload.
- Routes return envelopes and safe errors.
- Activation creates exactly one current Core session.
- Stale session work fails after switch/logout/disconnect.
- Provider snapshots contain no private fields.
- Registrations clean up after resource stop.

### End-to-end

1. New account creates a character and reaches the configured first spawn.
2. Existing account lists multiple characters with correct appearances.
3. Repeated/double-click creation produces exactly one character.
4. Selecting another account's UUID is rejected.
5. Switch A → B invalidates A's delayed inventory/weapon work.
6. Logout returns to selection with no duplicate cameras, peds, or session.
7. F8 quit and reconnect restores the correct character-owned state.
8. Character/Core/domain-resource restart behavior matches the recovery guide.
9. Malformed and oversized appearance payloads fail safely.

## 17. Delivery phases

### Phase 0 — Contract and boundary freeze

- Audit current code and dependencies.
- Freeze ownership, result, capability, profile, appearance, spawn, lifecycle, and event contracts.
- Decide roles/economy/provider boundaries.
- Record clean-rebuild and temporary-bridge policy.

**Exit:** this plan and `docs/architecture-contract-1.md` are accepted.

### Phase 1 — Foundation and persistence

- Add explicit bootstrap/readiness/health.
- Add validated configuration and logging.
- Add checksummed Character migrations.
- Add UUID profile, appearance, and spawn repositories.
- Add repository smoke test.

**Exit:** clean database and idempotent restart tests pass; legacy gameplay remains available.

Status: complete. `CharacterPersistenceSmokeTest` passed 5/5 on a live server.

### Phase 2 — Profiles and creation

- Implement ownership service and lightweight list/get routes.
- Implement atomic, idempotent creation with concurrency-safe character limits.
- Publish Character provider and post-commit creation event.
- Cut selection list and creation submit to Contract 1.

**Exit:** list/create/ownership/concurrency tests pass without Core character APIs.

Status: complete. `CharacterProfileContractSmokeTest` passed 6/6 on a live server. The player-facing selector and creator now use Contract 1 exclusively. Creation persists the profile, initial appearance, and spawn state atomically, then returns the player to selection instead of activating implicitly.

### Phase 3 — Appearance

- Implement schema/version/revision validation.
- Implement appearance get/update routes.
- Rebuild deterministic client application and revision acknowledgement.
- Cut selector previews and creator saves to the new service.

**Exit:** appearance persists across select/reconnect/restart and stale writes conflict.

Status: complete. `CharacterAppearanceSmokeTest` passed 6/6 on a live server,
selector previews read Contract 1 appearance documents, and initial-load preview
bodies, clothing, hair, visibility, and ground placement were verified live.

### Phase 4 — Activation and spawn

- Implement activation state machine against Core sessions.
- Implement server-authorized spawn plans and completion acknowledgement.
- Implement logout/switch/disconnect cleanup.
- Move old Core character spawn handling into Character.

**Exit:** full connect → select → activate → spawn → logout loop passes, including stale-session tests.

Status: complete and live-tested 8/8. The Character-owned client activates,
acknowledges spawn, periodically persists its last position, saves once more on
`/logout`, ends the Core session, publishes lifecycle events, clears local
character state, and returns to selection. Character's legacy Core bridge and
obsolete arrival spawner have been deleted. `CharacterCoreCutoverSmokeTest`
passed 5/5, `CharacterActivationContractSmokeTest` passed 8/8, and
`CoreRpcSmokeTest` passed 4/4 on a live server.

### Phase 5 — Consumer cutover

- Cut inventory, weapons, admin, economy/roles, medical, and remaining first-party resources to stable UUID/session/provider contracts.
- Add cross-resource restart and leaving-hook tests.

**Exit:** no first-party consumer reads legacy Character/Core records or events.

### Phase 6 — UI and server-owner polish

- Replace the current menu/state globals.
- Improve selection/creation/accessibility/controller behavior.
- Finalize configurable spawn presentation and error recovery.
- Publish install/configuration/diagnostics documentation.

**Exit:** server-owner and player acceptance matrices pass.

### Phase 7 — Legacy deletion and release

- Remove Core character controllers/services/cache/client spawn code.
- Remove Character legacy bridge, routes, events, globals, schema, and Core utility imports.
- Remove role/balance columns from Character ownership.
- Complete clean-install, migration/rebuild, soak, load, restart, and adversarial tests.

**Exit:** no compatibility shim remains and Contract 1 definition of done passes.

## 18. Workstream checklist

### Architecture and contracts

- [x] Audit current Character/Core boundary.
- [x] Assign profile, appearance, spawn, account, session, roles, and economy ownership.
- [x] Define Contract 1 names and lifecycle.
- [x] Finalize initial deletion policy: soft delete, explicit confirmation,
  active-session rejection, configurable minimum age, and retained recovery data.
- [ ] Finalize supported appearance catalog strategy.
- [x] Finalize initial position persistence policy: session-bound updates,
  world-bound validation, periodic synchronization, and final logout save.

### Persistence

- [x] Add Character migration ledger.
- [x] Add UUID profile schema.
- [x] Add versioned appearance schema.
- [x] Add spawn-state schema.
- [x] Add transactional repositories.
- [ ] Add clean rebuild and production migration/rebuild documentation.

### Server

- [x] Add lifecycle/readiness/capabilities/health.
- [x] Add ownership/profile service.
- [x] Add atomic creation service.
- [x] Add ownership-scoped soft-deletion service and lifecycle event.
- [x] Add appearance service and runtime smoke tests.
- [x] Add activation/spawn/logout server services.
- [x] Register Core routes/provider/events/guards.
- [x] Add structured diagnostics and foundation smoke tests.

### Client/UI

- [ ] Replace global state with explicit flow state.
- [x] Replace legacy RPC/events with Contract 1 routes.
- [x] Rebuild selection and character preview data flow.
- [x] Rebuild creation submission and validation feedback.
- [x] Add a dedicated deletion confirmation page to character selection.
- [x] Restore post-creation city arrival travel through the Contract 1 activation flow.
- [x] Rebuild deterministic appearance application for selection and activation.
- [x] Rebuild activation/spawn/logout cleanup and verify it live.
- [x] Test reconnect, logout/reselect, initial preview loading, and resource restart.

### Dependencies

- [x] Inventory uses stable character UUID/session lifecycle.
- [x] Weapons uses stable character UUID/session lifecycle.
- [x] Admin uses Character identity/provider and Core policy actions.
- [ ] Economy/roles providers own their state.
- [x] Core removes legacy Character domain implementation.

### Security

- [ ] Threat-model all client routes.
- [ ] Add ownership/session/revision checks.
- [ ] Add payload bounds and rate limits.
- [ ] Add concurrency/idempotency tests.
- [ ] Add resource ownership and restart cleanup tests.
- [ ] Verify safe logs and client errors.

## 19. Definition of done

Feather Character Contract 1 is complete when:

- Character—not Core—owns all character-domain persistence and behavior.
- Core owns only account identity and active session binding.
- Stable UUID character IDs are used by every first-party resource.
- Character creation is atomic, idempotent, validated, and concurrency-safe.
- List/get/update/select/delete paths enforce authoritative account ownership.
- Appearance is bounded, versioned, revision-controlled, and deterministic after reconnect/restart.
- Activation, spawn, logout, switch, disconnect, and restart state machines pass.
- No stale-session work can commit or report success.
- Roles, permissions, and currency are owned by explicit providers/resources.
- Inventory, weapons, admin, and other consumers use documented contracts only.
- Every public route/export/event is documented and returns the defined envelope/payload.
- Capabilities and health report real runtime state.
- Server-owner install, configuration, rebuild/migration, diagnostics, and recovery guides match the code.
- No legacy Core Character API, client spawn handler, schema dependency, event, global, or `initiate()` bridge remains.

## 20. Recommended first implementation slice

Build the persistence/profile seam before changing the player-facing selector:

1. Add Character lifecycle, real capabilities, health, and Core dependency validation.
2. Add checksummed migrations for UUID profiles, appearance, and spawn state.
3. Add transaction-bound repositories.
4. Implement server-only `ListProfiles(accountId)`, `GetProfile(characterId)`, and `OwnsCharacter(accountId, characterId)`.
5. Implement atomic `CreateCharacter(accountContext, input, idempotencyKey)` with the character-limit lock.
6. Add a console smoke test covering clean creation, ownership, limits, rollback, and restart.
7. Keep the current UI on the temporary bridge until the new service passes, then cut list/create over together. Completed: the bridge was removed after the combined cutover passed.

This creates the new authority without destabilizing selection, spawning, inventory, or weapons during the first step.

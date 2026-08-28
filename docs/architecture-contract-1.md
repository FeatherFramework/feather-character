# Feather Character Contract 1 Architecture Decisions

Status: accepted for the clean-slate foundation

## Ownership

- Feather Core owns account identity, authenticated request context, active character-session binding, transport, provider lifecycle, policy, guards, and health infrastructure.
- Feather Character owns character profiles, ownership mapping, creation, selection, appearance, spawn state, spawn presentation, deletion state, and Character-domain persistence.
- Roles/permissions and currency are separate domains. Contract 1 will not store role IDs or balances in the Character profile.
- Inventory, weapons, admin, medical, and other resources consume documented UUID/session/provider contracts and never query Character tables.

## IDs

- Public character IDs are server-generated UUIDs.
- Core account UUIDs are stored as ownership references but are not exposed in client character snapshots.
- Numeric legacy character IDs are not Contract 1 identity.
- Every activation receives a new Core session UUID; source IDs are transport addresses only.
- Feather-owned SQL schemas store these identifiers as `CHAR(36)` and supply
  generated values explicitly, avoiding MariaDB's newer native `UUID` type and
  UUID expression defaults.

## Results and capabilities

- Public synchronous operations use Core result envelopes.
- Expected domain rejection is `ok = false`; exceptions are reserved for programming/startup faults.
- Capabilities report Character's actual contract, feature versions, and lifecycle state.
- Missing or incompatible required Core capabilities prevent Character readiness.

## Profiles and appearance

- Profiles contain identity/presentation fields only.
- Appearance is a separate bounded JSON document with `schemaVersion`, monotonic `revision`, and optimistic concurrency.
- Clients never supply account ownership, roles, balances, session identity, or unrestricted model hashes.
- Public operations return defensive snapshots, never repository rows.

## Creation

- Character limit checks and profile/appearance/spawn inserts occur in one transaction.
- Creation is idempotent and protected against concurrent submissions.
- Starting inventory, equipment, currency, and roles are post-commit onboarding responsibilities owned by their domains.
- Failed validation/provider preconditions create no Character rows and publish no success event.

## Activation and spawn

- Character verifies profile ownership and status before asking Core to activate a session.
- Activation results are bound to the new session ID.
- Spawn coordinates are resolved from server-owned spawn point configuration or validated server-owned position state.
- The client presents and acknowledges a spawn plan; delayed acknowledgement for a stale session is rejected.
- Logout, switch, disconnect, and resource stop use explicit leaving/left cleanup.

## Transport

- Client routes are globally unique and versioned as `character.<operation>.v1`.
- Routes declare payload limits, validation, rate limits, timeouts, and session requirements.
- Lifecycle events are versioned and publish only committed or current state.
- The server Character provider exposes narrow read operations for trusted consumers.

## Compatibility during construction

- Backward compatibility is not a release requirement.
- The current Core `initiate()` bridge remains temporarily so gameplay stays testable while Contract 1 slices are built.
- No new implementation may use the bridge.
- Each legacy path is removed as soon as its replacement and consumer cutover pass.

## Persistence and release

- Character owns checksummed migrations and repository-only writes.
- Development should use a clean database rebuild where practical.
- Production migration or a clearly documented rebuild process is required before release.
- Core's legacy character controllers, service, cache records, client spawn handler, and schema dependencies are deleted in the final cutover.

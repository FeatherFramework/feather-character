# Core Contract 1 Cutover

The temporary Character/Core bridge has been removed. Character now consumes
only named Core Contract 1 surfaces.

## Current boundary

- Waits for truthful Feather Core readiness before loading server character services.
- Requires Core Contract 1 and the lifecycle, account-context, session, and RPC features.
- Fails startup with an actionable error when the required contract is unavailable.
- Uses UUID-backed Core sessions as the only live character binding.
- Uses named RPC, locale, notification, provider, event, and instance contracts.
- Keeps selection objects and preview peds private to Character.

## What remains outside this cutover

- Core's old Character API/schema may remain temporarily for other consumers,
  especially unfinished Admin economy/staff paths.
- Those consumers must migrate before Core deletes that old implementation.
- Character itself does not use that surface.

## Verification

After a complete server restart, run in the server console:

```text
CharacterCoreCutoverSmokeTest
```

All five checks must pass. Then test selection, logout/reselection, inventory,
weapons, and Admin identity because those resources consume the same session lifecycle.

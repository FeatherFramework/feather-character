# Feather Character

Feather Character provides character creation, selection, appearance,
first-spawn placement, position saving, logout, and character deletion for a
Feather Framework RedM server.

## Requirements

Install and start these resources before `feather-character`:

- `oxmysql`
- `feather-core`
- `feather-routing`
- `feather-economy`
- `feather-menu-v2`

Do not run this resource alongside the legacy Feather Character resource. Both
versions use the same resource name and character contracts.

## Installation

1. Back up your database and server resources.
2. Place the complete `feather-character` folder in your resources directory.
3. Confirm all requirements are installed and configured.
4. Add the resources to `server.cfg` in dependency order:

```cfg
ensure oxmysql
ensure feather-core
ensure feather-routing
ensure feather-economy
ensure feather-menu-v2
ensure feather-character
```

5. Start the server and run `CharacterV2Status` in the server console.
6. Allow players to connect only after the command reports `state=ready`.

Database migrations run automatically. The resource creates and maintains its
own `fc2_*` tables. It does not import or modify legacy character tables.

## Basic configuration

Edit `config.lua` to configure:

- the maximum characters allowed per account;
- identity and birth-date limits;
- available starting towns;
- direct spawn positions;
- optional horse arrival sequences;
- selector and creator presentation settings;
- model and collision timeouts.

Each selectable town requires an entry in `spawnPoints`. This position is used
for Direct spawning and as the safe fallback when a cinematic cannot finish.

```lua
spawnPoints = {
    valentine = {
        label = 'Valentine',
        x = -273.9114,
        y = 794.7129,
        z = 118.6634,
        heading = 158.8537
    }
}
```

## Selecting Direct or Horse by town

Every configured town under `arrivals.towns` has a `type` setting:

```lua
arrivals = {
    enabled = true,
    towns = {
        valentine = {
            type = 'horse', -- Use 'direct' or 'horse'.
            playerSpawn = {
                x = -259.387,
                y = 827.443,
                z = 121.058,
                heading = 148.436
            },
            horseSpawn = {
                x = -260.298,
                y = 828.047,
                z = 120.908,
                heading = 157.753
            },
            destination = {
                x = -357.067,
                y = 785.343,
                z = 116.139
            },
            horse = {
                -- Horse model, travel speed, equipment, and cleanup settings.
            },
            camera = {
                offsetX = 0.0,
                offsetY = -7.0,
                offsetZ = 3.0,
                fov = 50.0
            }
        }
    }
}
```

Use one of these values:

- `type = 'direct'` places a newly created character at the matching
  `spawnPoints` position.
- `type = 'horse'` plays the configured horse arrival after character creation.

Horse arrivals keep the screen black while the player and horse are prepared.
The screen fades in after road navigation begins. At the destination, the
player dismounts naturally and the temporary horse flees before fading out and
being deleted.

Horse arrivals run only after initial character creation. Returning characters
load at their last saved position. If an arrival cannot load, mount, navigate,
or finish within its timeout, Character cleans it up and uses the town's Direct
spawn instead.

## Adding or changing a town

For every town you enable:

1. Add a safe Direct fallback under `spawnPoints`.
2. Add a matching entry under `arrivals.towns`.
3. Choose `type = 'direct'` or `type = 'horse'`.
4. For Horse, provide `playerSpawn`, `horseSpawn`, and `destination`.
5. Test collision loading, mounting, navigation, dismounting, logout, and the
   Direct fallback in game.

`playerSpawn` and `horseSpawn` use `x`, `y`, `z`, and `heading`.
`destination` uses only `x`, `y`, and `z`; the player keeps the natural facing
direction produced by the dismount animation.

The included configuration contains Direct and Horse data for:

- Valentine
- Saint Denis
- Strawberry
- Rhodes
- Blackwater
- Van Horn
- Armadillo
- Tumbleweed

## Testing controls

The selector can display temporary Town and Spawn sequence controls for testing:

```lua
debug = {
    selectorSpawnSequence = false
}
```

Set `selectorSpawnSequence = true` only while testing. It allows a tester to
select any configured town and force either Direct or Horse using an existing
character. Keep it `false` on a normal player-facing server.

## Player commands

- `/logout` saves the current position and returns the player to character
  selection.
- `/savequit` saves the current position and disconnects the player.

Logging out during a horse arrival cancels the sequence, cleans up its horse and
camera, and returns the player to selection. Selecting that character again uses
the town's safe Direct spawn.

## Operational notes

- Restarting `feather-character` while players are connected is not a supported
  production workflow. Character lifecycle integrations in Inventory, Settings,
  and other resources can also be interrupted.
- Use a full coordinated server restart when updating Character or its required
  Feather resources.
- Back up the database before updating the resource.
- Confirm creation, selection, logout, reconnect, Direct spawn, and every
  enabled cinematic on a test server before deploying changes.

Architecture plans and development documents are maintained separately in the
[Feather Framework Docs repository](https://github.com/DavFount/feather-framework-docs/tree/main/feather-character).

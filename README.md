# Feather Character

Feather Character owns character profiles, appearance, selection, creation,
activation, spawn state, position persistence, logout, and deletion for Feather.
This repository is a clean rewrite of the original resource and intentionally
does not provide backward compatibility with its code or database tables.

The rewrite has reached release-candidate testing. The following flows have been
verified live in RedM with both male and female characters:

- create a character and enter the world directly;
- select and switch between owned characters;
- logout to the selector and enter the world again;
- reconnect and restore the last saved position;
- restart the server and restore characters and positions;
- persist the supported appearance, hair, facial hair, and face details;
- permanently delete a character through an explicit confirmation screen;
- logout or save and quit through Feather Settings;
- clear Inventory and its hotbar when the active character leaves.

The selector uses disposable local clone peds. The creator uses
`PlayerPedId()` so RedM metaped overlays render reliably. The player ped is never
deleted during presentation cleanup. World entry uses one direct,
server-authorized activation path for both newly created and returning
characters.

## Requirements

- `oxmysql`
- `feather-core`
- `feather-routing`
- `feather-economy`
- `feather-menu-v2`

Load dependencies before `feather-character`. The manifest deliberately names
the resource `feather-character`; do not run this rewrite alongside the legacy
implementation because both own the same resource contracts.

## Database

On startup, checksummed migrations create and maintain Character-owned `fc2_*`
tables. Legacy Character tables are not read, changed, deleted, or migrated.
Back up the database before replacing an existing installation and decide how
legacy character data will be handled before production cutover.

The server console command `CharacterV2Status` reports migration and service
readiness. Require `state=ready` before accepting players.

## Configuration

Edit `config.lua` to set:

- the maximum characters allowed per account;
- identity and birth-date limits;
- selector and creator stage positions, cameras, and selector poses;
- supported first-spawn locations;
- model and collision timeouts.

Starter clothing is the verified neutral legacy default for each model. Clothing
selection and changeable cosmetics are intentionally outside character creation;
cosmetics are reserved for a future salon workflow.

## Player flow

1. The account's character summaries and appearance documents are loaded once
   when the selector opens.
2. The selector cycles through a bounded pool of grounded, locally owned preview
   clones.
3. Creation edits the live player ped inside an isolated presentation route and
   persists the completed profile and appearance atomically.
4. Enter World and successful creation use the same activation service and a
   server-authorized spawn.
5. Position synchronization preserves the active character's last valid world
   location.
6. `/logout` saves and returns to selection. Save and Quit saves, tears down the
   session, and disconnects the client.

## Current scope

Direct spawn is the supported entry path. Horse, wagon, boat, and train arrival
cinematics are not included. A broader clothing editor, salon cosmetics,
production migration from legacy Character data, and a final visual polish pass
remain separate work.

Architecture decisions, implementation plans, test plans, and other project
planning live in the
[Feather Framework Docs repository](https://github.com/DavFount/feather-framework-docs/tree/main/feather-character),
not in this runtime resource.

CharacterV2Config = {
    -- Development slice only; not a production cutover.
    development = true,
    maxCharacters = 5,
    identity = {
        firstNameMaxBytes = 24,
        lastNameMaxBytes = 24,
        descriptionMaxBytes = 512,
        birthDateMin = '1819-01-01',
        birthDateMax = '1881-12-31'
    },
    appearance = { schemaVersion = 3, maxDocumentBytes = 65536 },
    -- These presets initialize the network metaped's drawable slots after
    -- SetPlayerModel. Saved components replace their visible outfit pieces.
    -- Matches the v1 LoadPlayer defaults. Female preset 2 belongs to the old
    -- creation-stage transition and includes the unwanted mask/red jacket.
    playerBasePreset = { mp_male = 4, mp_female = 3 },
    preview = {
        selector = {
            ped = { x = 124.4016, y = 3.9637, z = 102.8792, heading = 123.04 },
            scenarioSettleMs = 1800,
            scenarios = {
                -- Disabled after live selector review; retained for easy
                -- comparison while the final pose pool is being curated.
                -- 'MP_COOP_LOBBY_STANDING_A',
                -- 'MP_COOP_LOBBY_STANDING_C',
                -- 'MP_COOP_LOBBY_STANDING_D',
                'MP_LOBBY_SCENARIO_02',
                -- 'MP_LOBBY_SCENARIO_04',
                'MP_LOBBY_SCENARIO_07',
                'WORLD_HUMAN_SMOKE_CARRYING'
            },
            camera = {
                x = 121.8207, y = 2.3031, z = 103.1410,
                rotX = -5.1234, rotY = 0.0, rotZ = -62.2142, fov = 38.0
            }
        },
        creator = {
            ped = { x = 2551.2200, y = -1167.7000, z = 53.6835, heading = 180.75 },
            defaultView = 'full',
            pageViews = {
                general = 'full', face = 'face', body = 'full', hair = 'face',
                makeup = 'face', spawn = 'full', review = 'full'
            },
            views = {
                full = { label = 'Full Body', x = 2551.1057, y = -1169.8320, z = 53.6426,
                    rotX = -1.8421, rotY = 0.0, rotZ = 2.4902, fov = 50.0 },
                upper = { label = 'Upper Body', x = 2551.0530, y = -1169.1630, z = 54.0829,
                    rotX = -4.1390, rotY = 0.0, rotZ = 0.7499, fov = 44.25 },
                face = { label = 'Face', x = 2551.0720, y = -1169.3289, z = 54.4293,
                    rotX = -4.1390, rotY = 0.0, rotZ = 0.7499, fov = 20.50 },
                lower = { label = 'Lower Body', x = 2551.1580, y = -1169.4940, z = 53.3575,
                    rotX = -4.1390, rotY = 0.0, rotZ = 0.7499, fov = 38.25 }
            }
        },
        modelTimeoutMs = 10000,
        collisionTimeoutMs = 5000
    },
    spawnPoints = {
        saint_denis = { label = 'Saint Denis', x = 2714.99, y = -1424.91, z = 46.45, heading = 143.0 },
        rhodes = { label = 'Rhodes', x = 1300.1214599609, y = -1285.8166503906, z = 75.653411865234, heading = 52.365936279297 },
        valentine = { label = 'Valentine', x = -273.9114074707, y = 794.712890625, z = 118.66342163086, heading = 158.85372924805 },
        blackwater = { label = 'Blackwater', x = -686.24639892578, y = -1244.5211181641, z = 43.102550506592, heading = 83.719284057617 }
    }
}

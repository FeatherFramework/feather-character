CharacterV2Config = {
    debug = {
        selectorSpawnSequence = false
    },
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
                x = 121.8207,
                y = 2.3031,
                z = 103.1410,
                rotX = -5.1234,
                rotY = 0.0,
                rotZ = -62.2142,
                fov = 38.0
            }
        },
        creator = {
            ped = { x = 2551.2200, y = -1167.7000, z = 53.6835, heading = 180.75 },
            defaultView = 'full',
            pageViews = {
                general = 'full',
                face = 'face',
                body = 'full',
                hair = 'face',
                makeup = 'face',
                spawn = 'full',
                review = 'full'
            },
            views = {
                full = {
                    label = 'Full Body',
                    x = 2551.1057,
                    y = -1169.8320,
                    z = 53.6426,
                    rotX = -1.8421,
                    rotY = 0.0,
                    rotZ = 2.4902,
                    fov = 50.0
                },
                upper = {
                    label = 'Upper Body',
                    x = 2551.0530,
                    y = -1169.1630,
                    z = 54.0829,
                    rotX = -4.1390,
                    rotY = 0.0,
                    rotZ = 0.7499,
                    fov = 44.25
                },
                face = {
                    label = 'Face',
                    x = 2551.0720,
                    y = -1169.3289,
                    z = 54.4293,
                    rotX = -4.1390,
                    rotY = 0.0,
                    rotZ = 0.7499,
                    fov = 20.50
                },
                lower = {
                    label = 'Lower Body',
                    x = 2551.1580,
                    y = -1169.4940,
                    z = 53.3575,
                    rotX = -4.1390,
                    rotY = 0.0,
                    rotZ = 0.7499,
                    fov = 38.25
                }
            }
        },
        modelTimeoutMs = 10000,
        collisionTimeoutMs = 5000
    },
    spawnPoints = {
        saint_denis = { label = 'Saint Denis', x = 2714.99, y = -1424.91, z = 46.45, heading = 143.0 },
        rhodes = { label = 'Rhodes', x = 1300.1214599609, y = -1285.8166503906, z = 75.653411865234, heading = 52.365936279297 },
        valentine = { label = 'Valentine', x = -273.9114074707, y = 794.712890625, z = 118.66342163086, heading = 158.85372924805 },
        blackwater = { label = 'Blackwater', x = -686.24639892578, y = -1244.5211181641, z = 43.102550506592, heading = 83.719284057617 },
        strawberry = { label = 'Strawberry', x = -1803.722, y = -372.405, z = 161.257 },
        van_horn = { label = 'Van Horn', x = 2954.420, y = 533.524, z = 44.671 },
        armadillo = { label = 'Armadillo', x = -3700.318, y = -2607.767, z = -13.736 },
        tumbleweed = { label = 'Tumbleweed', x = -5515.937, y = -2923.037, z = -2.423 }
    },
    arrivals = {
        enabled = true,
        modelTimeoutMs = 10000,
        collisionTimeoutMs = 5000,
        towns = {
            valentine = {
                type = 'horse',
                playerSpawn = { x = -259.387, y = 827.443, z = 121.058, heading = 148.436 },
                horseSpawn = { x = -260.298, y = 828.047, z = 120.908, heading = 157.753 },
                destination = { x = -357.067, y = 785.343, z = 116.139 },
                horse = {
                    model = 'a_c_horse_arabian_rosegreybay',
                    travelSpeed = 1.5,
                    routeTimeoutMs = 90000,
                    arrivalRadius = 6.0,
                    preMountDelayMs = 750,
                    mountTimeoutMs = 10000,
                    postMountDelayMs = 1000,
                    dismountTimeoutMs = 5000,
                    components = {
                        0x20D4A0BF, -- Saddlecloth 3
                        0x43FC9BB6, -- Saddle 7
                        0x587DD49F, -- Stirrup 3
                        0xB4F40DD9, -- Saddlebag 10
                        0x27543EBB  -- Bedroll 4
                    },
                    cleanup = {
                        fleeDistance = 100.0,
                        fleeTimeoutMs = 15000,
                        fleeType = 6,
                        fleeSpeed = 3.0,
                        fadeAfterMs = 7000,
                        fadeDurationMs = 1000
                    }
                },
                camera = { offsetX = 0.0, offsetY = -7.0, offsetZ = 3.0, fov = 50.0 }
            },
            saint_denis = {
                type = 'horse',
                playerSpawn = { x = 2633.922, y = -1280.040, z = 52.199, heading = 111.346 },
                horseSpawn = { x = 2633.922, y = -1280.040, z = 52.199, heading = 111.346 },
                destination = { x = 2621.063, y = -1223.786, z = 53.280 },
                horse = {
                    model = 'a_c_horse_arabian_rosegreybay',
                    travelSpeed = 1.5,
                    routeTimeoutMs = 90000,
                    arrivalRadius = 6.0,
                    preMountDelayMs = 750,
                    mountTimeoutMs = 10000,
                    postMountDelayMs = 1000,
                    dismountTimeoutMs = 5000,
                    components = {
                        0x20D4A0BF, -- Saddlecloth 3
                        0x43FC9BB6, -- Saddle 7
                        0x587DD49F, -- Stirrup 3
                        0xB4F40DD9, -- Saddlebag 10
                        0x27543EBB  -- Bedroll 4
                    },
                    cleanup = {
                        fleeDistance = 100.0,
                        fleeTimeoutMs = 15000,
                        fleeType = 6,
                        fleeSpeed = 3.0,
                        fadeAfterMs = 7000,
                        fadeDurationMs = 1000
                    }
                },
                camera = { offsetX = 0.0, offsetY = -7.0, offsetZ = 3.0, fov = 50.0 }
            },
            strawberry = {
                type = 'horse',
                playerSpawn = { x = -1801.313, y = -326.499, z = 167.201, heading = 165.061 },
                horseSpawn = { x = -1801.313, y = -326.499, z = 167.201, heading = 165.061 },
                destination = { x = -1803.722, y = -372.405, z = 161.257 },
                horse = {
                    model = 'a_c_horse_arabian_rosegreybay',
                    travelSpeed = 1.5,
                    routeTimeoutMs = 90000,
                    arrivalRadius = 6.0,
                    preMountDelayMs = 750,
                    mountTimeoutMs = 10000,
                    postMountDelayMs = 1000,
                    dismountTimeoutMs = 5000,
                    components = { 0x20D4A0BF, 0x43FC9BB6, 0x587DD49F, 0xB4F40DD9, 0x27543EBB },
                    cleanup = {
                        fleeDistance = 100.0,
                        fleeTimeoutMs = 15000,
                        fleeType = 6,
                        fleeSpeed = 3.0,
                        fadeAfterMs = 7000,
                        fadeDurationMs = 1000
                    }
                },
                camera = { offsetX = 0.0, offsetY = -7.0, offsetZ = 3.0, fov = 50.0 }
            },
            rhodes = {
                type = 'horse',
                playerSpawn = { x = 1299.666, y = -1291.946, z = 76.084, heading = 233.880 },
                horseSpawn = { x = 1299.666, y = -1291.946, z = 76.084, heading = 233.880 },
                destination = { x = 1342.731, y = -1307.353, z = 76.457 },
                horse = {
                    model = 'a_c_horse_arabian_rosegreybay',
                    travelSpeed = 1.5,
                    routeTimeoutMs = 90000,
                    arrivalRadius = 6.0,
                    preMountDelayMs = 750,
                    mountTimeoutMs = 10000,
                    postMountDelayMs = 1000,
                    dismountTimeoutMs = 5000,
                    components = { 0x20D4A0BF, 0x43FC9BB6, 0x587DD49F, 0xB4F40DD9, 0x27543EBB },
                    cleanup = {
                        fleeDistance = 100.0,
                        fleeTimeoutMs = 15000,
                        fleeType = 6,
                        fleeSpeed = 3.0,
                        fadeAfterMs = 7000,
                        fadeDurationMs = 1000
                    }
                },
                camera = { offsetX = 0.0, offsetY = -7.0, offsetZ = 3.0, fov = 50.0 }
            },
            blackwater = {
                type = 'horse',
                playerSpawn = { x = -798.742, y = -1395.573, z = 43.328, heading = 348.275 },
                horseSpawn = { x = -798.742, y = -1395.573, z = 43.328, heading = 348.275 },
                destination = { x = -804.162, y = -1312.746, z = 43.515 },
                horse = {
                    model = 'a_c_horse_arabian_rosegreybay',
                    travelSpeed = 1.5,
                    routeTimeoutMs = 90000,
                    arrivalRadius = 6.0,
                    preMountDelayMs = 750,
                    mountTimeoutMs = 10000,
                    postMountDelayMs = 1000,
                    dismountTimeoutMs = 5000,
                    components = { 0x20D4A0BF, 0x43FC9BB6, 0x587DD49F, 0xB4F40DD9, 0x27543EBB },
                    cleanup = {
                        fleeDistance = 100.0,
                        fleeTimeoutMs = 15000,
                        fleeType = 6,
                        fleeSpeed = 3.0,
                        fadeAfterMs = 7000,
                        fadeDurationMs = 1000
                    }
                },
                camera = { offsetX = 0.0, offsetY = -7.0, offsetZ = 3.0, fov = 50.0 }
            },
            van_horn = {
                type = 'horse',
                playerSpawn = { x = 2968.941, y = 583.495, z = 44.339, heading = 161.306 },
                horseSpawn = { x = 2968.941, y = 583.495, z = 44.339, heading = 161.306 },
                destination = { x = 2954.420, y = 533.524, z = 44.671 },
                horse = {
                    model = 'a_c_horse_arabian_rosegreybay',
                    travelSpeed = 1.5,
                    routeTimeoutMs = 90000,
                    arrivalRadius = 6.0,
                    preMountDelayMs = 750,
                    mountTimeoutMs = 10000,
                    postMountDelayMs = 1000,
                    dismountTimeoutMs = 5000,
                    components = { 0x20D4A0BF, 0x43FC9BB6, 0x587DD49F, 0xB4F40DD9, 0x27543EBB },
                    cleanup = {
                        fleeDistance = 100.0,
                        fleeTimeoutMs = 15000,
                        fleeType = 6,
                        fleeSpeed = 3.0,
                        fadeAfterMs = 7000,
                        fadeDurationMs = 1000
                    }
                },
                camera = { offsetX = 0.0, offsetY = -7.0, offsetZ = 3.0, fov = 50.0 }
            },
            armadillo = {
                type = 'horse',
                playerSpawn = { x = -3735.704, y = -2658.984, z = -14.475, heading = 324.901 },
                horseSpawn = { x = -3735.704, y = -2658.984, z = -14.475, heading = 324.901 },
                destination = { x = -3700.318, y = -2607.767, z = -13.736 },
                horse = {
                    model = 'a_c_horse_arabian_rosegreybay',
                    travelSpeed = 1.5,
                    routeTimeoutMs = 90000,
                    arrivalRadius = 6.0,
                    preMountDelayMs = 750,
                    mountTimeoutMs = 10000,
                    postMountDelayMs = 1000,
                    dismountTimeoutMs = 5000,
                    components = { 0x20D4A0BF, 0x43FC9BB6, 0x587DD49F, 0xB4F40DD9, 0x27543EBB },
                    cleanup = {
                        fleeDistance = 100.0,
                        fleeTimeoutMs = 15000,
                        fleeType = 6,
                        fleeSpeed = 3.0,
                        fadeAfterMs = 7000,
                        fadeDurationMs = 1000
                    }
                },
                camera = { offsetX = 0.0, offsetY = -7.0, offsetZ = 3.0, fov = 50.0 }
            },
            tumbleweed = {
                type = 'horse',
                playerSpawn = { x = -5545.458, y = -2869.511, z = -4.447, heading = 193.930 },
                horseSpawn = { x = -5545.458, y = -2869.511, z = -4.447, heading = 193.930 },
                destination = { x = -5515.937, y = -2923.037, z = -2.423 },
                horse = {
                    model = 'a_c_horse_arabian_rosegreybay',
                    travelSpeed = 1.5,
                    routeTimeoutMs = 90000,
                    arrivalRadius = 6.0,
                    preMountDelayMs = 750,
                    mountTimeoutMs = 10000,
                    postMountDelayMs = 1000,
                    dismountTimeoutMs = 5000,
                    components = { 0x20D4A0BF, 0x43FC9BB6, 0x587DD49F, 0xB4F40DD9, 0x27543EBB },
                    cleanup = {
                        fleeDistance = 100.0,
                        fleeTimeoutMs = 15000,
                        fleeType = 6,
                        fleeSpeed = 3.0,
                        fadeAfterMs = 7000,
                        fadeDurationMs = 1000
                    }
                },
                camera = { offsetX = 0.0, offsetY = -7.0, offsetZ = 3.0, fov = 50.0 }
            }
        }
    }
}

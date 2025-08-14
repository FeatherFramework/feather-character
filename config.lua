Config = {
    DevMode = true,
    DyeClothes = true,
    Heights = {
        0.8, 0.85, 0.9, 0.95, 1.0, 1.05, 1.1, 1.15, 1.2
    },
    defaults = {
        lang = 'ro',
        dob = {
            start = '1826-01-01',
            min = '1806-01-01',
            max = '1906-01-01'
        },
        money = 0,
        gold = 0,
        tokens = 0,
        xp = 0
    },
    Notify = "feather-menu", ----or use feather-core
    MaxAllowedChars = 4,

    SpawnProps = {
        obj1 = {
            name = 'mp005_s_posse_tent_bountyhunter07x',
            x = 130.37,
            y = -0.10,
            z = 102.29,
            h = 270.0
        },
        obj2 = {
            name = 'mp005_s_posse_butcher01x',
            x = 123.71,
            y = 3.27,
            z = 101.97,
            h = 220.0

        },
        obj3 = {
            name = 'p_campfire01x',
            x = 122.19,
            y = -0.90,
            z = 101.95,
            h = 90.0

        },
        obj4 = {
            name = 'p_chair02x',
            x = 124.93,
            y = -4.01,
            z = 102.18,
            h = 240.0

        }
    },

    CameraCoords = {
        selection = {
            x = 117.77,
            y = 0.01,
            z = 103.76,
            h = -90.51,
            zoom = 60.00
        },
        charcamera = {
            [1] = { x = 122.0727, y = 2.45, z = 103.54, h = 310.48, zoom = 80.0 },
            [2] = { x = 125.03, y = -0.32, z = 103.54, h = 272.14, zoom = 80.0 },
            [3] = { x = 122.75, y = -3.46, z = 103.54, h = 262.80, zoom = 80.0 },
            [4] = { x = 121.07, y = -2.83, z = 103.54, h = 264.52, zoom = 80.0 },
            [5] = { x = 117.75, y = -2.82, z = 103.38, h = 272.14, zoom = 80.0 },
            [6] = { x = 119.69, y = -4.50, z = 103.38, h = 272.14, zoom = 80.0 },
        },
        creation = {
            x = 2551.30, y = -1170.09, z = 54.0, h = 0.75, zoom = 50.0
        }
    },

    SpawnCoords = {
        creation = {
            x = 2553.15283203125, y = -1161.277587890625, z = 53.6835250854492
        },
        gotocoords = { x = 2551.22, y = -1167.70, z = 53.68 },

        charspots = {
            [1] = { x = 124.40160369873047, y = 3.96372103691101, z = 102.87928009033203 },
            [2] = { x = 126.94853973388672, y = -0.33047696948051, z = 103.12394714355469 },
            [3] = { x = 124.45506286621094, y = -3.68904304504394, z = 103.14924621582031 },
            [4] = { x = 122.08714294433594, y = -2.90044069290161, z = 103.03951263427735 },
            [5] = { x = 122.08714294433594, y = -4.90044069290161, z = 103.03951263427735 },
            [6] = { x = 122.08714294433594, y = -6.90044069290161, z = 103.03951263427735 },
            [7] = { x = 120.08714294433594, y = -2.90044069290161, z = 103.03951263427735 },

        },

        towns = {
            {
                --set to train coords still
                name = 'Saint Denis',                                                            --Name of Area
                arrival = 'Wagon',                                                               --Method of arriving (Train,Wagon,Horse,Boat)
                --tip = " " --Info to give to the player, don't include if not wanting
                cameracoords = { x = 2849.20, y = -1619.75, z = 97.54, h = 33.30, zoom = 80.0 }, --Coords character will spawn at
                startcoords = { x = 2774.99, y = -1351.91, z = 46.45, h = 143.0 },               --Coords character will spawn at
                gotocoords = { x = 2714.99, y = -1424.91, z = 46.45, h = 143.0 },
            },

            {
                name = 'Rhodes',
                arrival = 'Wagon',
                --tip = " "
                cameracoords = { x = 1302.3477783203, y = -1285.8200683594, z = 75.749298095703, h = 242.23068237305, zoom = 60.0 },
                startcoords = { x = 1335.205078125, y = -1210.04296875, z = 80.691871643066, h = 148.88484191895 },
                gotocoords = { x = 1300.1214599609, y = -1285.8166503906, z = 75.653411865234, h = 52.365936279297 },
            },
            {
                name = 'Valentine',
                arrival = 'Horse',
                --tip = " "
                cameracoords = { x = -248.94729614258, y = 798.03393554688, z = 166.78594970703, h = 94.020202636719, zoom = 60.0 },
                startcoords = { x = -244.72610473633, y = 839.16955566406, z = 122.93338012695, h = 131.92630004883 },
                gotocoords = { x = -273.9114074707, y = 794.712890625, z = 118.66342163086, h = 158.85372924805 },
            },
            {
                name = 'Blackwater',
                arrival = 'Boat',
                --tip = " "
                cameracoords = { x = -720.31, y = -1278.59, z = 42.23, h = 90.0, zoom = 60.0 },
                startcoords = { x = -644.51879882812, y = -1275.9403076172, z = 40.128196716309, h = 267.40234375 },
                gotocoords = { x = -686.24639892578, y = -1244.5211181641, z = 43.102550506592, h = 83.719284057617 },

            },
        }
    }
}

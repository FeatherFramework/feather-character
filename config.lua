Config = {}

Config.DevMode = true


Config.defaults = {
    lang = 'en_us',
    dob = {
        start = '1826-01-01',
        min = '1806-01-01',
        max = '1906-01-01'
    },
    money = 0,
    gold = 0,
    tokens = 0,
    xp = 0,
}

Config.MaxAllowedChars = 7

Config.tempclothhash = {
    [1] = 'a_f_m_armtownfolk_01',
    [2] = 'a_f_m_armtownfolk_02',
    [3] = 'a_f_m_lowersdtownfolk_01',
    [4] = 'a_m_m_lowersdtownfolk_01',
    [5] = 'u_m_m_bwmstablehand_01',
    [6] = 'u_m_m_nbxbankerbounty_01',
    [7] = 'a_m_m_valfarmer_01',
}

Config.SpawnProps = {
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

    },
}

Config.CameraCoords = {
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
}

Config.SpawnCoords = {
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

    spawns = {
        {
            --set to train coords still
            name = 'Saint Denis',                                               --Name of Area
            arrival = 'Train',                                                  --Method of arriving (Train,Wagon,Horse,Boat)
            --tip = " " --Info to give to the player, don't include if not wanting
            cameracoords = { x = 2813.99, y = -1437.91, z = 43.54, h = 90.0, zoom = 60.0 }, --Coords character will spawn at
            coords = { x = 2813.99, y = -1437.91, z = 43.54 },                  --Coords character will spawn at

        },
        {
            --set wagon coords still
            name = 'Rhodes',                                                        --Name of Area
            arrival = 'Wagon',                                                      --Method of arriving (Train,Wagon,Horse,Boat)
            --tip = " " --Info to give to the player, don't include if not wanting
            cameracoords = { x = 2813.99, y = -1437.91, z = 43.54, h = 90.0, zoom = 60.0 }, --Coords character will spawn at
            coords = { x = 2813.99, y = -1437.91, z = 43.54 },                      --Coords character will spawn at
        },
        {
            name = 'Valentine',                                                   --Name of Area
            arrival = 'Horse',                                                    --Method of arriving (Train,Wagon,Horse,Boat)
            --tip = " " --Info to give to the player, don't include if not wanting
            cameracoords = { x = -165.59, y = 632.28, z = 114.03, h = 90.0, zoom = 60.0 }, --Coords character will spawn at
            coords = { x = 2813.99, y = -1437.91, z = 43.54 },                    --Coords character will spawn at
        },
        {
            name = 'Blackwater',                                                  --Name of Area
            arrival = 'Boat',                                                     --Method of arriving (Train,Wagon,Horse,Boat)
            --tip = " " --Info to give to the player, don't include if not wanting
            cameracoords = { x = -720.31, y = -1278.59, z = 42.23, h = 90.0, zoom = 60.0 }, --Coords character will spawn at
            coords = { x = 2813.99, y = -1437.91, z = 43.54 },                    --Coords character will spawn at

        },
    }
}


Config.Locales = {
    ["welcome"] = "Welcome to ",
    ["arrive"] = "You will arrive by ",
    ["press"] = "Press <- or -> to cycle through options",
}

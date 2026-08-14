FeatherCore = exports['feather-core'].initiate()
FeatherMenu = exports['feather-menu'].initiate()

-- The single shared menu instance every screen in this resource routes
-- pages through (character select, creation, spawn-city select). `canclose
-- = false` -- there's no legitimate reason to let a player ESC out of
-- character selection/creation before a character is actually spawned.
CharacterMenu = FeatherMenu:RegisterMenu('feather:character:menu', {
    top = '1%',
    left = '1%',
    ['720width'] = '400px',
    ['1080width'] = '500px',
    ['2kwidth'] = '600px',
    ['4kwidth'] = '800px',
    style = {},
    contentslot = {
        style = {
            ['height'] = '650px',
            ['min-height'] = '500px'
        }
    },
    draggable = false,
    canclose = false
})

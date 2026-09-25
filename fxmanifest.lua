fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

description 'Feather Character clean-room rewrite (first-playable development slice)'
author 'Feather Framework'
name 'feather-character'
version '0.5.1'

shared_scripts {
    'config.lua',
    'shared/result.lua',
    'shared/defaults.lua',
    'shared/catalog.lua',
    'shared/hair_catalog.lua',
    'shared/overlay_catalog.lua',
    'shared/draft.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/schema.lua',
    'server/migrate.lua',
    'server/profiles.lua',
    'server/activation.lua',
    'server/main.lua'
}

client_scripts {
    'client/flow.lua',
    'client/preview.lua',
    'client/appearance.lua',
    'client/overlay_menu.lua',
    'client/checkpoints.lua',
    'client/arrival.lua',
    'client/main.lua'
}

dependencies {
    'oxmysql',
    'feather-core',
    'feather-routing',
    'feather-economy',
    'feather-menu-v2'
}

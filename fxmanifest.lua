fx_version 'cerulean'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

description 'The Character service for the Feather Framework'
author 'BCC Scripts'
name 'feather-character'
version '0.0.1'

github_version_check 'false'
github_version_type 'release'
github_ui_check 'false'
github_link 'https://github.com/FeatherFramework/feather-character'

shared_scripts {
    'config.lua',
    'shared/data/setup.lua',
    'shared/data/general.lua',
    'shared/data/clothing.lua',
    'shared/data/attributes.lua',
    'shared/data/features.lua',
    'shared/data/hair.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/helpers/feathercore.lua',
    'server/helpers/*.lua',
    'server/services/*.lua',
    'server/main.lua'
}

client_scripts {
    '@feather-core/shared/services/dataview.lua',
    'client/imports.lua',
    'client/helpers/*.lua',
    'client/services/*.lua',
    'client/main.lua',
    'client/services/character/*.lua',
}

dependencies {
    'oxmysql',
    'feather-menu',
    'feather-core'
}
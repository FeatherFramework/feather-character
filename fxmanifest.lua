fx_version 'cerulean'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

description 'The Character service for the Feather Framework'
author 'Feather @Jannings'
name 'feather-character'
version '0.1.0'

github_version_check 'true'
github_version_type 'release'
github_ui_check 'false'
github_link 'https://github.com/FeatherFramework/feather-character'

shared_scripts {
    'config.lua',
    'shared/imports.lua',
    'locale/*.lua',
    'shared/data/setup.lua',
    'shared/data/general.lua',
    'shared/data/clothing.lua',
    'shared/data/attributes.lua',
    'shared/data/features.lua',
    'shared/data/hair.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/imports.lua',
    'server/controllers/*.lua',
    'server/services/*.lua'
}

client_scripts {
    '@feather-core/shared/services/dataview.lua',
    'client/imports.lua',
    'client/helpers/*.lua',
    'client/services/*.lua',
    'client/main.lua',
    'client/services/character/*.lua',
    'client/services/creationmenu/*.lua',
    'client/services/creationmenu/faceadjustments/*.lua',
    'client/services/creationmenu/hair/*.lua',
    'client/services/creationmenu/clothing/*.lua',
    'client/services/creationmenu/makeup/*.lua',
}

dependencies {
    'oxmysql',
    'feather-menu',
    'feather-core'
}

files {
  'html/img/money.png',
  'html/img/gold.png',
  'html/img/shield.png',
  'html/img/token.png'
}
fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

description 'The Character service for the Feather Framework'
author 'Feather @Jannings'
name 'feather-character'
version '0.4.1'

shared_scripts {
    'config.lua',
    'shared/contracts/*.lua',
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
    'server/migrations/*.lua',
    'server/contract/*.lua',
    'server/persistence/*.lua',
    'server/repositories/*.lua',
    'server/transport/*.lua',
    'server/controllers/*.lua',
    'server/services/*.lua',
    'server/main.lua'
}

client_scripts {
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

fx_version "adamant"
games { "rdr3" }
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."
lua54 "yes"

description 'The Character service for the Feather Framework'
author 'BCC Scripts'
name 'feather-character'
version '0.0.1'
github ''
github_type ''

shared_scripts {
    "config.lua",
    'clothing.lua'
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/server.lua"
}

client_scripts {
    "client/client.lua",
    'client/menu.lua'
}


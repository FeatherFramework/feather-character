fx_version "adamant"
games { "rdr3" }
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."
lua54 "yes"

description 'The Character service for the Feather Framework'
author 'BCC Scripts'
name 'feather-character'
version '0.0.1'

github_version_check 'false'
github_version_type 'release'
github_ui_check 'false'
github_link 'https://github.com/FeatherFramework/feather-character'

shared_scripts {
    "config.lua",
    'shared/data/*.lua'
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/server.lua"
}

client_scripts {
    "client/client.lua",
    "client/ui.lua",
    "client/menu.lua"
}

ui_page {
    "ui/shim.html"
}

files {
    "ui/shim.html",
    "ui/js/*.*",
    "ui/css/*.*",
    "ui/fonts/*.*",
    "ui/img/*.*"
}
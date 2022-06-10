fx_version 'cerulean'
lua54 'yes'
game 'gta5'
description 'Car Remote by LazarusRising Edited by Kings'
author 'LazarusRising & Kings'
version '3.0.4'

client_scripts {
    "config.lua",
    "client/main.lua"
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "config.lua",
    "server/main.lua"
}

ui_page 'html/index.html'

files {
    'html/**/*'
}

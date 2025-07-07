fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'moxy | leo@vnsh.gg'
description 'Discord API Integration for FiveM'

shared_scripts {
    '@ox_lib/init.lua'
}

server_scripts {
    'config.lua',
    'main/sv_main.lua'
}

client_scripts {
    'main/cl_main.lua'
}
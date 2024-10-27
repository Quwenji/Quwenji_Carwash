fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Quwenji'
description 'Erweitertes Autowaschskript mit OX_Lib, Mitgliedschaft und dynamischer Preisgestaltung'
version '2.0.0'

shared_scripts {
    '@es_extended/imports.lua', 
    '@ox_lib/init.lua',         
    'config.lua',
    'locales.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
}

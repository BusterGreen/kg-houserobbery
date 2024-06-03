fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Knuckls'
description 'Allows players to rob houses for items to sell'
version '1.2.0'

shared_scripts {
    '@kg-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

dependencies {
    'kg-minigames'
}

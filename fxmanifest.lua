fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'bucu_notify'
description 'BUCU Core Modern Glassmorphism Notification, Progress Bar & Prompt System with Universal Hooks'
author 'BUCU Framework Team'
version '1.0.0'

shared_scripts {
    '@bucu_shared/shared/constants.lua',
    '@bucu_shared/shared/config.lua',
    'config.lua',
    'locales/en.lua',
    'locales/id.lua'
}

client_scripts {
    'client/nui.lua',
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js'
}

dependencies {
    'bucu_shared'
}

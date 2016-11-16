resource_type 'gametype' { name = 'TDM' }

description 'TDM Gamemode from Kanersps.'

ui_page 'pages/kills.html'

-- Client scripts
client_script 'client/main.lua'

-- Server scripts
server_script 'server/main.lua'
server_script 'server/accounts.lua'

client_script 'playerlist.lua'
server_script 'playerlist_sv.lua'

files {
    'pages/kills.html',
    'html/index.html',
    'html/css/style.css',
}
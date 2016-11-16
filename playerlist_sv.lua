local player_kills = {}
local player_deaths = {}

-- KD stuff
AddEventHandler('baseevents:onPlayerKilled', function(killer, kilerT)
	if(player_deaths[source] == nil)then
		player_deaths[source] = 0
	end
	if(player_kills[source] == nil)then
		player_kills[source] = 0
	end
	
	if(player_deaths[killer] == nil)then
		player_deaths[killer] = 0
	end
	if(player_kills[killer] == nil)then
		player_kills[killer] = 0
	end
	
	player_deaths[source] = player_deaths[source] + 1
	player_kills[killer] = player_kills[killer] + 1
	
	print(player_kills[killer])
	
end)

RegisterServerEvent("getPlayerData")
AddEventHandler("getPlayerData", function()
	TriggerClientEvent("playerkills", source, player_kills)
	TriggerClientEvent("playerdeaths", source, player_deaths)
end)
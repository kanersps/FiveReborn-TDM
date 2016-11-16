local player_kills = {}
local player_deaths = {}

function getPlayerKills(s)
	if(player_deaths[s] == nil)then
		player_deaths[s] = 0
	end
	if(player_kills[s] == nil)then
		player_kills[s] = 0
	end
	return player_kills[s]
end

function getPlayerDeaths(s)
	if(player_deaths[s] == nil)then
		player_deaths[s] = 0
	end
	if(player_kills[s] == nil)then
		player_kills[s] = 0
	end
	return player_deaths[s]
end

function getPlayerTeam(id)

	if(myPlayer.teamMembers[id] ~= nil)then
		return myPlayer.team .. ""
	else
		if(myPlayer.team == "alpha")then
			return "beta"
		else
			if(myPlayer.team == "none")then
				return "none"
			end
			
			return "alpha"
		end
	end
end

RegisterNetEvent("playerkills")
RegisterNetEvent("playerdeaths")

AddEventHandler("playerkills", function(v)	
	player_kills = v
end)
AddEventHandler("playerdeaths", function(v)	
	player_deaths = v
end)

Citizen.CreateThread( function()
	while true do
		Citizen.Wait(0)
		--Displays playerlist when player hold X
		if IsControlJustPressed(1, 323) then --Start holding
			ShowPlayerList()
		elseif IsControlJustReleased(1, 323) then --Stop holding
			ShowPlayerList()
		end
	end
end)

--Playerlist created by Arturs & Heavily modified by Kanersps (About 95% of the code changed lol)
local plist = false
function ShowPlayerList()
	TriggerServerEvent("getPlayerData")	
	if plist == false then
		local players 
		players = '<tr class= "titles"><th width="60%" class="name">Name</th><th width="7.5%" class="id">Kills</th><th width="7.5%" class="id">Deaths</th><th width="5%" class="id">ID</th></tr>'
		for i = 0,32 do
			if NetworkIsPlayerActive(GetPlayerFromServerId(i)) then --Check if player is active
				if(getPlayerTeam(i) == "alpha") then
				--if i ~= PlayerId() then -- enable this check to not display local player
					players = players..' <tr class="player"><th class="name">'..GetPlayerName(GetPlayerFromServerId(i))..'</th><th class="id">'..getPlayerKills(i)..'</th><th class="id">'..getPlayerDeaths(i)..'</th>'..'<th class="id">'..i..'</th></tr>'
				--end
				end
			end
		end
		players = players
		
		local players2 
		players2 = '<tr class= "titles"><th width="60%" class="name">Name</th><th width="7.5%" class="id">Kills</th><th width="7.5%" class="id">Deaths</th><th width="5%" class="id">ID</th></tr>'
		for i = 0,32 do
			if NetworkIsPlayerActive(GetPlayerFromServerId(i)) then --Check if player is active
				if(getPlayerTeam(i) == "beta")then
				--if i ~= PlayerId() then -- enable this check to not display local player
					players2 = players2..' <tr class="player"><th class="name">'..GetPlayerName(GetPlayerFromServerId(i))..'</th><th class="id">'..getPlayerKills(i)..'</th><th class="id">'..getPlayerDeaths(i)..'</th>'..'<th class="id">'..i..'</th></tr>'
				--end
				end
			end
		end
		players2 = players2
		
		SendNUIMessage({
			meta = 'open',
			players = players,
			players2 = players2,
			team = myPlayer.team
		})
		plist = true
	else
		SendNUIMessage({ 
			meta = 'close'
		})
		plist = false
	end
end
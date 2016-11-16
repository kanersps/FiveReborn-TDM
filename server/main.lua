-- Server
Users = {}
Teams = {}
Teams["alpha"] = 0
Teams["beta"] = 0

Maps = {}

Game = {}
Game.playersRequired = 2
Game.map = "barn_1"
Game.started = false
Game.ingame = {}
Game.dead = {}

Maps.barn_1 = {}

Maps.barn_1.middlespot = {x = 2339, y = 4833, z = 41}
Maps.barn_1.spawnPointsAlpha = {}
Maps.barn_1.spawnPointsAlpha[1] = {x = 2308.75, y = 4755.63, z = 37.16}
Maps.barn_1.spawnPointsAlpha[2] = {x = 2271.89, y = 4756.95, z = 38.66}
Maps.barn_1.spawnPointsAlpha[3] = {x = 2221.39, y = 4792.31, z = 40.31}
Maps.barn_1.spawnPointsBeta = {}
Maps.barn_1.spawnPointsBeta[1] = {x = 2333.11, y = 4896.44, z = 41.83}
Maps.barn_1.spawnPointsBeta[2] = {x = 2330.69, y = 4905.22, z = 41.83}
Maps.barn_1.spawnPointsBeta[3] = {x = 2373.61, y = 4892.22, z = 41.88}
Maps.barn_1.spawnPointsBeta[4] = {x = 2401.04, y = 4855.22, z = 39.46}


Maps.mt_chilliad = {}

RegisterServerEvent("chatCommandEntered")
RegisterServerEvent("baseevents:onPlayerDied")


RegisterServerEvent('playerConnecting')
AddEventHandler('playerConnecting', function(name, setCallback)
	local identifiers = GetPlayerIdentifiers(source)
	for i = 1, #identifiers do
        if(string.find(identifiers[i], "steam"))then
			if(Users[source] == nil)then
				print("TDM | Loading user")
				
				local steamID = string.sub(identifiers[i], 7)
				Users[source] = getAccount(steamID, source)      
					
				TriggerClientEvent("clientPlayerData", source, Users[source]["points"], Users[source]["kills"], Users[source]["deaths"])

                saveKD(source)
                
				TriggerClientEvent("removeAllMembers", source)
				setTeamMembers(source)
				
				return
			end
        end
	end
end)



RegisterServerEvent("spawning")
AddEventHandler("spawning", function()	
	if(Users[source] == nil)then
		TriggerClientEvent("runCommand", source, "/e")
	end

	if(Game.ingame[source] == nil or Game.started == false)then
		TriggerClientEvent("godmode", source, true)
	else
		if(Game.started == true and Game.ingame[source] ~= nil)then
			if(Users[source].team == "alpha")then
				local randomTeleportSpot = math.random(1, #Maps[Game.map].spawnPointsAlpha)
				local spawnPoint = Maps[Game.map].spawnPointsAlpha[randomTeleportSpot]
				TriggerClientEvent("teleport", source, spawnPoint.x, spawnPoint.y, spawnPoint.z)
			else
				local randomTeleportSpot = math.random(1, #Maps[Game.map].spawnPointsBeta)
				local spawnPoint = Maps[Game.map].spawnPointsBeta[randomTeleportSpot]
				TriggerClientEvent("teleport", source, spawnPoint.x, spawnPoint.y, spawnPoint.z)
			end
		end
	end
	
	if(Users[source] ~= nil)then
		if(Game.dead[source] ~= nil)then
			setTeamMembers(source)
			SetTimeout(4000, function()			
				TriggerClientEvent("godmode", source, false)
			end)
			Game.dead[source] = nil
		end
	end
end)

AddEventHandler('playerDropped', function(reason)
	for i = 1, #identifiers do
        if(string.find(identifiers[i], "steam"))then			
            local steamID = string.sub(identifiers[i], 7)
			Game.teams[Users[source].team] = Game.teams[Users[source].team] - 1
            Users[source] = nil    
            return
        end
	end
end)

AddEventHandler('baseevents:onPlayerDied', function()	
	if(Users[source] ~= nil) then
		Game.dead[source] = true
    else
        print("Player not loaded " .. GetPlayerName(source) .. " loading...")
        local identifiers = GetPlayerIdentifiers(source)
        for i = 1, #identifiers do
            if(string.find(identifiers[i], "steam"))then
                local steamID = string.sub(identifiers[i], 7)
                Users[source] = getAccount(steamID, source)      
                TriggerClientEvent("clientPlayerData", source, Users[source]["points"], Users[source]["kills"], Users[source]["deaths"])
                return
            end
        end
    end
end)

-- Player killed event.
RegisterServerEvent("baseevents:onPlayerKilled")
AddEventHandler('baseevents:onPlayerKilled', function(killer, kilerT)	
	for i = 1, 100 do
		if Users[i] ~= nil then
						
			local teamKiller = nil
			if(Users[killer] == nil)then
				teamKiller = Users[source]["team"]
			else
				teamKiller = Users[killer]["team"]
			end
			if(Users[source] == nil)then
				team = "none"
			else
				team = Users[source]["team"]
			end
			
			TriggerClientEvent("playerKilled", i, killer, GetPlayerName(source), source, team, teamKiller, Users[i].team)
		end
	end
	
    if(Users[source] ~= nil)then
        Users[source]["deaths"] = Users[source]["deaths"] + 1
        Game.dead[source] = true
				
        saveKD(source)
    else
        print("Player not loaded " .. GetPlayerName(source) .. " loading...")
        local identifiers = GetPlayerIdentifiers(source)
        for i = 1, #identifiers do
            if(string.find(identifiers[i], "steam"))then
                local steamID = string.sub(identifiers[i], 7)
                Users[source] = getAccount(steamID, source)     
                    
                Users[source]["deaths"] = Users[source]["deaths"] + 1
				
				Game.dead[source] = true
				
				TriggerClientEvent("removeAllMembers", source)
				setTeamMembers(source)
				
                saveKD(source)
                
				setTeamMembers(source)
				
                break
            end
        end
        
    end
        
    if(Users[killer] ~= nil)then           
		if(Users[killer].team == Users[source].team) then
			Users[killer]["deaths"] = Users[killer]["deaths"] + 1
			Users[source]["deaths"] = Users[source]["deaths"] - 1
			TriggerClientEvent("setHealth", killer, 0)
			
			SendPlayerChatMessage(killer, "You were killed because you killed a teammate!", { 255, 0, 0})
		else
			Users[killer]["kills"] = Users[killer]["kills"] + 1
		end
			
        saveKD(killer)
    else
        print("Player not loaded " .. GetPlayerName(killer) .. " loading...")
        local identifiers = GetPlayerIdentifiers(killer)
        for i = 1, #identifiers do
            if(string.find(identifiers[i], "steam"))then
                local steamID = string.sub(identifiers[i], 7)
                Users[killer] = getAccount(steamID, source)      
				
				if(Users[killer].team == Users[source].team) then
					Users[killer]["deaths"] = Users[killer]["deaths"] + 1
					TriggerClientEvent("setHealth", killer, 0)
					SendPlayerChatMessage(killer, "You were killed because you killed a teammate!", { 255, 0, 0})
				else
					Users[killer]["kills"] = Users[killer]["kills"] + 1
				end

				setTeamMembers(source)
				
                saveKD(killer)
                break
            end
        end
    end
end)

-- Disable vehicle usage
RegisterServerEvent("baseevents:enteringVehicle")
AddEventHandler("baseevents:enteringVehicle", function()
	TriggerClientEvent("teleport", source, "this")
end)

RegisterServerEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function()
	TriggerClientEvent("teleport", source, "this")
end)

RegisterServerEvent("baseevents:enteringAborted")
AddEventHandler("baseevents:enteringAborted", function()
end)

-- Hooking into chat messages to insert admin tags.
AddEventHandler('chatMessageEntered', function(name, color, message)
	CancelEvent()
	
	local tag = "^whiteUser ^black| ^gray"
	
	if(Users[source] ~= nil)then
		if(tonumber(Users[source].admin) > 0)then
			tag = "^redAdmin ^black| ^gray"
		end
	end
	
	TriggerEvent('chatMessage', source, tag .. GetPlayerName(source), message)

	TriggerClientEvent('chatMessage', -1, tag .. GetPlayerName(source), {0, 0x99, 255}, message)

	print(GetPlayerName(source) .. ': ' .. message)
end)

-- Chat commands
AddEventHandler('chatCommandEntered', function(fullcommand)
	command = stringsplit(fullcommand, " ")
	
	if(Users[source] == nil)then
		print("Player not loaded " .. GetPlayerName(source) .. " loading...")
        local identifiers = GetPlayerIdentifiers(source)
        for i = 1, #identifiers do
            if(string.find(identifiers[i], "steam"))then
                local steamID = string.sub(identifiers[i], 7)
                Users[source] = getAccount(steamID, source)     
                    
                Users[source]["deaths"] = Users[source]["deaths"] + 1

                saveKD(source)
                
				TriggerClientEvent("removeAllMembers", source)
				setTeamMembers(source)
				
                break
            end
        end
		
		TriggerClientEvent("runCommand", source, fullcommand)
        return
	end
	
	if(command[1] == "/team")then
		SendPlayerChatMessage(source, "Your team: " .. Users[source]["team"], { 0, 0x99, 255})
	elseif(command[1] == "/id")then
		SendPlayerChatMessage(source, "ID: " .. source, { 0, 0x99, 255})
	elseif(command[1] == "/loc")then
		TriggerClientEvent("giveLocation", source)
	elseif(command[1] == "/kill")then
		TriggerClientEvent("setHealth", source, 0)
		
	elseif(command[1] == "/god")then
	elseif(command[1] == "/join")then
		Game.ingame[source] = true	
		local count = 0
		for k,v in pairs(Game.ingame) do
			 count = count + 1
		end
				TriggerClientEvent("removeAllMembers", source)
				setTeamMembers(source)
				
		if(count > Game.playersRequired - 1)then
			if(Game.started == false)then
				Game.started = true
				for i = 1, 32 do
					if Game.ingame[i] ~= nil then
						TriggerClientEvent("godmode", i, false)
						SendPlayerChatMessage(i, "^5Game has enough players, starting game. teleporting to spawnpoints!", {0, 200, 0})
						if(Users[i].team == "alpha")then
							local randomTeleportSpot = math.random(1, #Maps[Game.map].spawnPointsAlpha)
							local spawnPoint = Maps[Game.map].spawnPointsAlpha[randomTeleportSpot]
							TriggerClientEvent("teleport", i, spawnPoint.x, spawnPoint.y, spawnPoint.z)
							TriggerClientEvent("godmode", i, false)
						else
							local randomTeleportSpot = math.random(1, #Maps[Game.map].spawnPointsBeta)
							local spawnPoint = Maps[Game.map].spawnPointsBeta[randomTeleportSpot]
							TriggerClientEvent("teleport", i, spawnPoint.x, spawnPoint.y, spawnPoint.z)
							TriggerClientEvent("godmode", i, false)
						end
					end
				end
			end
		else
			local count = 0
			for k,v in pairs(Game.ingame) do
				 count = count + 1
			end
			SendPlayerChatMessage(source, "^3Please wait until there are enough players in. Currently: " .. count .. " out of 2", {0, 200, 0})
		end
		
		if(Game.started and Game.ingame[source] ~= nil)then
			TriggerClientEvent("godmode", source, false)
			
				TriggerClientEvent("removeAllMembers", source)
				setTeamMembers(source)
			
			if(Users[source].team == "alpha")then
				local randomTeleportSpot = math.random(1, #Maps[Game.map].spawnPointsAlpha)
				local spawnPoint = Maps[Game.map].spawnPointsAlpha[randomTeleportSpot]
				TriggerClientEvent("teleport", source, spawnPoint.x, spawnPoint.y, spawnPoint.z)
			else
				local randomTeleportSpot = math.random(1, #Maps[Game.map].spawnPointsBeta)
				local spawnPoint = Maps[Game.map].spawnPointsBeta[randomTeleportSpot]
				TriggerClientEvent("teleport", source, spawnPoint.x, spawnPoint.y, spawnPoint.z)
			end
		end
	elseif(command[1] == "/leave")then
		if(Game.ingame[source] == nil)then
			SendPlayerChatMessage(source, "^3You are currently not in a game.", {0, 200, 0})
			return
		end
		Game.ingame[source] = nil
		
		if(Game.teams ~= nil)then
			Game.teams[Users[source].team] = Game.teams[Users[source].team] - 1
		end
		
		if(Game.started)then
			SendPlayerChatMessage(source, "^3Next respawn you will be put back in the lobby!", {0, 200, 0})
		else
			SendPlayerChatMessage(source, "^3You left the queue the current queue is: " .. #Game.ingame .. " out of 2", {0, 200, 0})
		end
	else
		SendPlayerChatMessage(source, "Unknown command, type /help for a list.", {255, 0, 0})
	end
end)

function setTeamMembers(id)
	-- Set player teams.
	TriggerClientEvent("clientTeam", id, Users[source]["team"])
    for i = 0,32 do            
        if Users[i] ~= nil then
			if Users[i]["team"] == Users[id]["team"] then
				TriggerClientEvent("newTeamMember", id, i)
				TriggerClientEvent("newTeamMember", i, id)
			end
		end
	end
end

function findTeamLowestPlayers()
	if(Teams.alpha < Teams.beta)then
		return "alpha"
	else
		return "beta"
	end
end

function stringsplit(self, delimiter)
  local a = self:Split(delimiter)
  local t = {}

  for i = 0, #a - 1 do
     table.insert(t, a[i])
  end

  return t
end

function SendPlayerChatMessage(source, message, color)
	if(color == nil) then
		color = { 0, 0x99, 255}
	end
	TriggerClientEvent("chatMessage", source, '', color, message)
end

-- Timeout faraway test
function farAwayTest()
	SetTimeout(15000, function()
		for i = 0,32 do            
			if Users[i] ~= nil then
				if(Game.started == true and Game.ingame[i] ~= nil and Game.dead[i] == nil)then
					TriggerClientEvent("doFarAwayTest", i, Maps[Game.map].middlespot.x, Maps[Game.map].middlespot.y)
				end
			end
		end
		farAwayTest()
	end)
end

farAwayTest()

print("----------------------------------------------")
print(" _         _             ")
print("| |_    __| |  _ __ ___  ")
print("| __|  / _` | | '_ ` _ \ ")
print("| |_  | (_| | | | | | | |")
print(" \__|  \__,_| |_| |_| |_|")
print("By Kanersps loaded. Alpha 1.0.2")
print("----------------------------------------------")


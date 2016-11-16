myPlayer = {}
myPlayer.points = 0
myPlayer.kills = 0
myPlayer.deaths = 0
myPlayer.team = "none"
myPlayer.teamMembers = {}

local function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)    
	SetEntityCoords()
end


RegisterNetEvent("clientPlayerData")
AddEventHandler("clientPlayerData", function(points, kills, deaths)
	myPlayer.points = points
	myPlayer.kills = kills
	myPlayer.deaths = deaths
end)

RegisterNetEvent("newTeamMember")
AddEventHandler("newTeamMember", function(w)
	myPlayer.teamMembers[w] = true
end)

RegisterNetEvent("removeAllMembers")
AddEventHandler("removeAllMembers", function()
	myPlayer.teamMembers = {}
end)

RegisterNetEvent("clientTeam")
AddEventHandler("clientTeam", function(team, players)
	myPlayer["team"] = team
	myPlayer["teamMembers"] = {}
end)

RegisterNetEvent("setHealth")
AddEventHandler("setHealth", function(health)
	SetEntityHealth(GetPlayerPed(-1), health)
end)

local godded = false
RegisterNetEvent("godmode")
AddEventHandler("godmode", function(godmode)
    godded = godmode
end)

RegisterNetEvent("giveLocation")
AddEventHandler("giveLocation", function()
	local pc = GetEntityCoords(GetPlayerPed(-1))
	TriggerEvent("chatMessage", '', { 0, 0x99, 255}, "X: " .. pc["x"] .. " Y: " .. pc["y"] .. " Z: " .. pc["z"])
end)

RegisterNetEvent("teleport")
AddEventHandler("teleport", function(x, y, z)

	if(x == "this")then
	local pc = GetEntityCoords(GetPlayerPed(-1))
		SetEntityCoords(GetPlayerPed(-1), pc.x, pc.y, pc.z)
		TriggerEvent("chatMessage", '', { 0, 0x99, 255}, "You cannot enter this!")
	else
		SetEntityCoords(GetPlayerPed(-1), x, y, z)
	end
end)

RegisterNetEvent("godtest")
AddEventHandler("godtest", function(x, y, z)
	TriggerEvent("chatMessage", '', { 0, 0x99, 255}, "Godded?: " .. GetPlayerInvincible(PlayerId()))
end)

local function distance ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

RegisterNetEvent("doFarAwayTest")
AddEventHandler("doFarAwayTest", function(x, y)
	local pc = GetEntityCoords(GetPlayerPed(-1))
	if(distance(x, y, pc["x"], pc["y"]) > 200)then
		TriggerEvent("setHealth", 0)
		TriggerEvent("chatMessage", '', { 0, 0x99, 255}, "You got killed for walking too far away.")
	end
end)

RegisterNetEvent("playerKilled")
AddEventHandler("playerKilled", function(killer, killed, idkiller, team, team2, myTeam)

	weapon = "KILLED"
	
	if(killer == GetPlayerFromServerId(killed))then
		weapon = "Suicide"
	end

	killer = GetPlayerFromServerId(killer)
	killer = GetPlayerName(killer)
	if(killer == "**Invalid**")then
		killer = GetPlayerName(PlayerId())
	end
	
    SendNUIMessage({
        killer = killer,
		killed = killed,
		weapon = weapon,
		friendlyK = isFriendly(team, myTeam),
		friendlyKI = isFriendly(team2, myTeam)
    })
end)

function isFriendly(team, friendTeam)
	if(friendTeam == team)then
		return false
	else
		return true
	end
end

Citizen.CreateThread(function()	
	while true do
		Citizen.Wait(0)
		RestorePlayerStamina(PlayerId(), 1.0)
		SetPlayerInvincible(PlayerId(), godded)
		
        DrawRect(0.95,0.329,0.19,0.10,0,0,0,150)
        drawTxt(1.009, 0.3,0.3,0.045,0.45, "Kills: " .. myPlayer.kills,255,255,255,255)
        drawTxt(1.009, 0.330,0.3,0.045,0.45, "Deaths: " .. myPlayer.deaths,255,255,255,255)
        drawTxt(1.009, 0.360,0.3,0.045,0.45, "Points: " .. myPlayer.points,255,255,255,255)
		
		-- Draw player markers.
        for i = 0,32 do            
            if NetworkIsPlayerActive(GetPlayerFromServerId(i))then
				local playerCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(i)))
				if (myPlayer["teamMembers"][i] ~= nil) then
					ped = GetPlayerPed(GetPlayerFromServerId(i))
					headDisplayId = N_0xbfefe3321a3f5015(ped, GetPlayerName(GetPlayerFromServerId(i)), 0, 0, " ", 0)
					N_0x63bb75abedc1f6a0(headDisplayId, 0, 1)
				end
			end
		end
    end
end)

local firstspawn = true
-- Enable PVP & Give the player the default weapon also make ssure you can't enter a vehicle.
AddEventHandler('playerSpawned', function(spawn)
	SetEntityInvincible(GetPlayerPed(-1), true)
	TriggerServerEvent("spawning")
	GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), 500, true, true)
	GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ASSAULTRIFLE"), 500, true, true)
	
	if(firstspawn)then
		TriggerEvent("chatMessage", '', { 0, 0x99, 255}, "^1Welcome to FiveReborn TDM.")
		TriggerEvent("chatMessage", '', { 0, 0x99, 255}, "^2When you want to join the current game. Type /join to leave type /leave")
	end
	
    Citizen.CreateThread(function()
        Citizen.Wait(0) --run it
        for i = 0,31 do
            if NetworkIsPlayerConnected(i) then
                if NetworkIsPlayerConnected(i) and GetPlayerPed(i) ~= nil then
                    SetCanAttackFriendly(GetPlayerPed(i), true, true)
                    NetworkSetFriendlyFireOption(true)
                end                
            end
        end
    end)
	
	firstspawn = false
end)

-- Command running from server.
RegisterNetEvent("runCommand")
AddEventHandler("runCommand", function(cmd)
	TriggerServerEvent('chatCommandEntered', cmd)
end)

-- Disable cops.
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		SetPlayerWantedLevel(PlayerId(), 0, false)
		SetPlayerWantedLevelNow(PlayerId(), false)
	end
end)

-- Resource stuff
AddEventHandler('onClientMapStart', function()
    exports.spawnmanager:setAutoSpawn(true)
    exports.spawnmanager:forceRespawn()
    SetClockTime(16, 0, 0)
    PauseClock(true)
end)

-- Disable any peds
Citizen.CreateThread(function()
	SetGarbageTrucks(0)
	SetRandomBoats(0)
   
    while true do
		Citizen.Wait(1)
    	SetVehicleDensityMultiplierThisFrame(0.0)
		SetPedDensityMultiplierThisFrame(0.0)
		SetRandomVehicleDensityMultiplierThisFrame(0.0)
		SetParkedVehicleDensityMultiplierThisFrame(0.0)
		SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
		
		local playerPed = GetPlayerPed(-1)
		local pos = GetEntityCoords(playerPed) 
		RemoveVehiclesFromGeneratorsInArea(pos['x'] - 500.0, pos['y'] - 500.0, pos['z'] - 500.0, pos['x'] + 500.0, pos['y'] + 500.0, pos['z'] + 500.0);
	end

end)
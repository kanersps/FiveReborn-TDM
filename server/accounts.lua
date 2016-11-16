-- Loading MySQL Class
require "resources/tdm/lib/MySQL"

-- Open MySQL connection
MySQL:open("127.0.0.1", "gta5_gamemode_tdm", "root", "1202")
local json = require( "json" ) 

function isAccountLoaded(source)
	
end

function getAccount(id, source)
    local steamid = id
	local executed_query = MySQL:executeQuery("SELECT * FROM users WHERE steamid = '@steamid'", {['@steamid'] = id})
	local result = MySQL:getResults(executed_query, {'admin', 'banned', 'kills', 'deaths', 'points', 'steamid'}, "steamid")
	if(result[1] ~= nil) then
		local team = findTeamLowestPlayers()
		result[1].team = team
		
		Teams[team] = Teams[team] + 1
		
		if(tonumber(result[1].admin) > 0)then
			TriggerClientEvent("admin", source)
		end
		
		return result[1]
    else
		-- Inserting Default User Account Stats
		MySQL:executeQuery("INSERT INTO users (`steamid`, `banned`, `admin`, `kills`, `deaths`, `points`) VALUES ('@username', '0', '0', '0', '0', '0')",
		{['@username'] = id})
        
        return getAccount(id)
	end
	return false    
end

function saveKD(source)
	MySQL:executeQuery("UPDATE users SET kills='@newKD' WHERE steamid = '@username'",
    {['@username'] = Users[source]["steamid"], ['@newKD'] = Users[source]['kills']})
	
	MySQL:executeQuery("UPDATE users SET deaths='@newKD' WHERE steamid = '@username'",
    {['@username'] = Users[source]["steamid"], ['@newKD'] = Users[source]['deaths']})
    
    TriggerClientEvent("clientPlayerData", source, Users[source]["points"], Users[source]["kills"], Users[source]["deaths"])
end
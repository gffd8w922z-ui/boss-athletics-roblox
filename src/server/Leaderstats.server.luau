--[[
	Leaderstats.server
	Starts the leaderstats and Phase 3 player data saving systems for BOSS Athletics.
	Stats are loaded when players join and saved when players leave or the server shuts down.
]]

local Players = game:GetService("Players")

local LeaderstatsService = require(script.Parent.LeaderstatsService)
local PlayerDataService = require(script.Parent.PlayerDataService)

-- Load saved stats, then create leaderstats for each new player.
Players.PlayerAdded:Connect(function(player: Player)
	local savedStats = PlayerDataService.loadStats(player)
	LeaderstatsService.createLeaderstats(player, savedStats)
end)

-- Save a player's current stats without blocking the rest of the game if saving fails.
local function savePlayerStats(player: Player)
	local statsSnapshot = LeaderstatsService.getStatsSnapshot(player)
	local didSave = PlayerDataService.saveStats(player, statsSnapshot)

	if not didSave then
		warn(`BOSS Athletics stats were not saved for {player.Name}. The player can continue playing, but progress from this server may be lost.`)
	end
end

-- Save player stats when they leave the server.
Players.PlayerRemoving:Connect(function(player: Player)
	savePlayerStats(player)
end)

-- Covers players already present if this script starts after they load in Studio.
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		local savedStats = PlayerDataService.loadStats(player)
		LeaderstatsService.createLeaderstats(player, savedStats)
	end)
end

-- Save remaining players during shutdown.
game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayerStats(player)
	end
end)

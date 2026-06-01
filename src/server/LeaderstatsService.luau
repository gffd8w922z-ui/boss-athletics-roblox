--[[
	LeaderstatsService
	Creates Roblox leaderstats for each player in Phase 1 of BOSS Athletics.
	This module only creates stat values and does not include DataStores or gameplay systems.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatConfig = require(ReplicatedStorage.Shared.StatConfig)

local LeaderstatsService = {}

-- Creates a leaderstats folder with all configured stat values for one player.
function LeaderstatsService.createLeaderstats(player: Player): Folder
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	for _, statName in ipairs(StatConfig.Order) do
		local statValue = Instance.new("IntValue")
		statValue.Name = statName
		statValue.Value = StatConfig.getDefaultValue(statName)
		statValue.Parent = leaderstats
	end

	return leaderstats
end

return LeaderstatsService

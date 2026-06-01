--[[
	LeaderstatsService
	Creates, reads, and updates Roblox leaderstats for BOSS Athletics players.
	Phase 3 data saving uses this module to apply loaded stats and capture save snapshots.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatConfig = require(ReplicatedStorage.Shared.StatConfig)

local LeaderstatsService = {}

-- Creates a leaderstats folder with all configured stat values for one player.
function LeaderstatsService.createLeaderstats(player: Player, loadedStats: { [string]: number }?): Folder
	local existingLeaderstats = player:FindFirstChild("leaderstats")
	if existingLeaderstats and existingLeaderstats:IsA("Folder") then
		LeaderstatsService.applyStats(player, loadedStats or {})
		return existingLeaderstats
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	for _, statName in ipairs(StatConfig.Order) do
		local statValue = Instance.new("IntValue")
		statValue.Name = statName
		statValue.Value = StatConfig.getDefaultValue(statName)
		statValue.Parent = leaderstats
	end

	LeaderstatsService.applyStats(player, loadedStats or {})
	return leaderstats
end

-- Applies loaded stat values onto existing leaderstats while ignoring unknown stats.
function LeaderstatsService.applyStats(player: Player, stats: { [string]: number })
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats or not leaderstats:IsA("Folder") then
		return
	end

	for _, statName in ipairs(StatConfig.Order) do
		local loadedValue = stats[statName]
		local statValue = leaderstats:FindFirstChild(statName)

		if typeof(loadedValue) == "number" and statValue and statValue:IsA("IntValue") then
			statValue.Value = math.floor(loadedValue)
		end
	end
end

-- Returns a plain table of the player's current stat values for DataStore saving.
function LeaderstatsService.getStatsSnapshot(player: Player): { [string]: number }
	local snapshot = {}
	local leaderstats = player:FindFirstChild("leaderstats")

	for _, statName in ipairs(StatConfig.Order) do
		local defaultValue = StatConfig.getDefaultValue(statName)
		local statValue = leaderstats and leaderstats:FindFirstChild(statName)

		if statValue and statValue:IsA("IntValue") then
			snapshot[statName] = statValue.Value
		else
			snapshot[statName] = defaultValue
		end
	end

	return snapshot
end

-- Finds one stat value for a player, creating leaderstats first if needed.
function LeaderstatsService.getStatValue(player: Player, statName: string): IntValue?
	if not StatConfig.isValidStat(statName) then
		warn(`Unknown BOSS Athletics stat: {statName}`)
		return nil
	end

	local leaderstats = LeaderstatsService.createLeaderstats(player)
	local statValue = leaderstats:FindFirstChild(statName)

	if statValue and statValue:IsA("IntValue") then
		return statValue
	end

	return nil
end

-- Adds a number to a player's stat and returns the new value.
function LeaderstatsService.addStat(player: Player, statName: string, amount: number): number?
	local statValue = LeaderstatsService.getStatValue(player, statName)
	if not statValue then
		return nil
	end

	statValue.Value += amount
	return statValue.Value
end

return LeaderstatsService

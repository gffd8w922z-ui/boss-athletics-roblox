--[[
	PlayerDataService
	Loads and saves BOSS Athletics player stats using Roblox DataStoreService.
	Failures are handled with retries and warnings so gameplay can continue with default stats.
]]

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatConfig = require(ReplicatedStorage.Shared.StatConfig)

local PlayerDataService = {}

local DATASTORE_NAME = "BossAthleticsPlayerStats_v1"
local MAX_ATTEMPTS = 3
local RETRY_DELAY_SECONDS = 1

local playerStatsStore = DataStoreService:GetDataStore(DATASTORE_NAME)

-- Builds the DataStore key for one player.
local function getPlayerKey(player: Player): string
	return `Player_{player.UserId}`
end

-- Returns true when a loaded DataStore value looks like a stats table.
local function isStatsTable(value: any): boolean
	return typeof(value) == "table"
end

-- Sanitizes saved data so only known numeric stats are applied to leaderstats.
local function sanitizeStats(savedStats: { [string]: any }): { [string]: number }
	local sanitizedStats = {}

	for _, statName in ipairs(StatConfig.Order) do
		local savedValue = savedStats[statName]
		if typeof(savedValue) == "number" then
			sanitizedStats[statName] = math.floor(savedValue)
		else
			sanitizedStats[statName] = StatConfig.getDefaultValue(statName)
		end
	end

	return sanitizedStats
end

-- Loads saved stats for a player, returning nil if loading fails or no data exists.
function PlayerDataService.loadStats(player: Player): { [string]: number }?
	local key = getPlayerKey(player)

	for attempt = 1, MAX_ATTEMPTS do
		local success, result = pcall(function()
			return playerStatsStore:GetAsync(key)
		end)

		if success then
			if isStatsTable(result) then
				return sanitizeStats(result)
			end

			return nil
		end

		warn(`Failed to load BOSS Athletics data for {player.Name} on attempt {attempt}: {result}`)
		if attempt < MAX_ATTEMPTS then
			task.wait(RETRY_DELAY_SECONDS)
		end
	end

	return nil
end

-- Saves a player's current stat snapshot, returning whether the save succeeded.
function PlayerDataService.saveStats(player: Player, statsSnapshot: { [string]: number }): boolean
	local key = getPlayerKey(player)
	local statsToSave = sanitizeStats(statsSnapshot)

	for attempt = 1, MAX_ATTEMPTS do
		local success, result = pcall(function()
			playerStatsStore:SetAsync(key, statsToSave)
		end)

		if success then
			return true
		end

		warn(`Failed to save BOSS Athletics data for {player.Name} on attempt {attempt}: {result}`)
		if attempt < MAX_ATTEMPTS then
			task.wait(RETRY_DELAY_SECONDS)
		end
	end

	return false
end

return PlayerDataService

--[[
	StatConfig
	Shared stat definitions for BOSS Athletics.
	This module keeps stat names, order, and default values consistent across server and client code.
]]

local StatConfig = {}

-- Stats are listed in the order they should be created and displayed.
StatConfig.Order = {
	"Strength",
	"Speed",
	"Stamina",
	"Coins",
	"Reputation",
}

-- New players start every stat at zero.
StatConfig.Defaults = {
	Strength = 0,
	Speed = 0,
	Stamina = 0,
	Coins = 0,
	Reputation = 0,
}

-- Returns the default value for a stat name.
function StatConfig.getDefaultValue(statName: string): number
	return StatConfig.Defaults[statName] or 0
end

-- Returns true when the provided stat exists in the config.
function StatConfig.isValidStat(statName: string): boolean
	return StatConfig.Defaults[statName] ~= nil
end

return StatConfig

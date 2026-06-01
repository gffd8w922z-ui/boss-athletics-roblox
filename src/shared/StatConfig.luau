--[[
	StatConfig
	Shared Phase 1 stat definitions for BOSS Athletics.
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

-- Phase 1 starts every stat at zero.
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

return StatConfig

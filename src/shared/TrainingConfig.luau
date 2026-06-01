--[[
	TrainingConfig
	Shared Phase 2 training area definitions for BOSS Athletics.
	The server uses this data to create equipment, rewards, and station behavior.
]]

local TrainingConfig = {}

-- Each area trains one stat, gives a small Coin reward, and appears at a fixed position on the baseplate.
TrainingConfig.Areas = {
	{
		id = "StrengthTraining",
		displayName = "Strength Training",
		statName = "Strength",
		gain = 1,
		coinReward = 1,
		cooldownSeconds = 1,
		promptText = "Lift Weights",
		position = Vector3.new(-18, 0.25, 0),
		color = Color3.fromRGB(210, 64, 64),
		equipmentType = "Weights",
	},
	{
		id = "SpeedTraining",
		displayName = "Speed Training",
		statName = "Speed",
		gain = 1,
		coinReward = 1,
		cooldownSeconds = 1,
		promptText = "Run Sprint",
		position = Vector3.new(0, 0.25, 0),
		color = Color3.fromRGB(58, 143, 255),
		equipmentType = "Treadmill",
	},
	{
		id = "StaminaTraining",
		displayName = "Stamina Training",
		statName = "Stamina",
		gain = 1,
		coinReward = 1,
		cooldownSeconds = 1,
		promptText = "Build Stamina",
		position = Vector3.new(18, 0.25, 0),
		color = Color3.fromRGB(67, 190, 124),
		equipmentType = "Bike",
	},
}

return TrainingConfig

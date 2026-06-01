--[[
	Training.server
	Bootstraps the Phase 2 BOSS Athletics training areas.
	The training areas are created on the server so all players see the same equipment and prompts.
]]

local Players = game:GetService("Players")

local TrainingAreaService = require(script.Parent.TrainingAreaService)

-- Build the Strength, Speed, and Stamina training stations in Workspace.
TrainingAreaService.start()

-- Remove stored training cooldown data when a player leaves.
Players.PlayerRemoving:Connect(function(player: Player)
	TrainingAreaService.removePlayer(player)
end)

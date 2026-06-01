--[[
	Leaderstats.server
	Starts the Phase 1 leaderstats system when players join BOSS Athletics.
	The stat creation logic is kept in LeaderstatsService so this script stays small.
]]

local Players = game:GetService("Players")

local LeaderstatsService = require(script.Parent.LeaderstatsService)

-- Create leaderstats for each new player.
Players.PlayerAdded:Connect(function(player: Player)
	LeaderstatsService.createLeaderstats(player)
end)

-- Create leaderstats for any players already present during Studio test startup.
for _, player in ipairs(Players:GetPlayers()) do
	LeaderstatsService.createLeaderstats(player)
end

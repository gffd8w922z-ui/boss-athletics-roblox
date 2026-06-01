--[[
	StatsGui.client
	Creates a simple ScreenGui that displays all Phase 1 BOSS Athletics stats.
	The GUI only reads leaderstats values and does not add gameplay systems.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatConfig = require(ReplicatedStorage.Shared.StatConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Build the ScreenGui in code so Phase 1 has no extra UI assets to manage.
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BossStatsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "StatsPanel"
panel.Position = UDim2.fromOffset(16, 16)
panel.Size = UDim2.fromOffset(220, 184)
panel.BackgroundColor3 = Color3.fromRGB(18, 24, 32)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel = 0
panel.Parent = screenGui

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(12, 10)
title.Size = UDim2.new(1, -24, 0, 28)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "BOSS Athletics"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local labelsByStat = {}

-- Create one text label per configured stat.
for index, statName in ipairs(StatConfig.Order) do
	local statLabel = Instance.new("TextLabel")
	statLabel.Name = statName .. "Label"
	statLabel.Position = UDim2.fromOffset(12, 38 + ((index - 1) * 26))
	statLabel.Size = UDim2.new(1, -24, 0, 24)
	statLabel.BackgroundTransparency = 1
	statLabel.Font = Enum.Font.Gotham
	statLabel.Text = statName .. ": 0"
	statLabel.TextColor3 = Color3.fromRGB(225, 232, 240)
	statLabel.TextSize = 16
	statLabel.TextXAlignment = Enum.TextXAlignment.Left
	statLabel.Parent = panel

	labelsByStat[statName] = statLabel
end

local leaderstats = player:WaitForChild("leaderstats")

-- Keep the GUI text synced as replicated stat values change.
for _, statName in ipairs(StatConfig.Order) do
	local statValue = leaderstats:WaitForChild(statName)
	local statLabel = labelsByStat[statName]

	local function updateStatText()
		statLabel.Text = statName .. ": " .. tostring(statValue.Value)
	end

	updateStatText()
	statValue:GetPropertyChangedSignal("Value"):Connect(updateStatText)
end

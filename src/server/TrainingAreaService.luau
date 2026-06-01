--[[
	TrainingAreaService
	Creates Phase 2 training equipment and handles ProximityPrompt training actions.
	Training increases leaderstats on the server so the stat UI updates live through replication.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LeaderstatsService = require(script.Parent.LeaderstatsService)
local TrainingConfig = require(ReplicatedStorage.Shared.TrainingConfig)

local TrainingAreaService = {}

local TRAINING_FOLDER_NAME = "BossTrainingAreas"
local playerCooldowns: { [Player]: { [string]: number } } = {}

-- Creates a basic anchored part used by the visual equipment models.
local function createPart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent

	return part
end

-- Adds a floating label so players can identify each training station quickly.
local function createAreaLabel(parent: Instance, adornee: BasePart, text: string)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "AreaLabel"
	billboardGui.Adornee = adornee
	billboardGui.AlwaysOnTop = true
	billboardGui.Size = UDim2.fromOffset(220, 48)
	billboardGui.StudsOffset = Vector3.new(0, 4, 0)
	billboardGui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 18
	label.TextStrokeTransparency = 0.35
	label.Parent = billboardGui
end

-- Builds weight equipment for Strength training.
local function createWeights(model: Model, origin: Vector3, color: Color3): BasePart
	local base = createPart(model, "StrengthPad", Vector3.new(12, 0.5, 10), origin, color)
	createPart(model, "Bench", Vector3.new(5, 0.5, 2), origin + Vector3.new(0, 1, 0), Color3.fromRGB(38, 38, 42))
	createPart(model, "BarbellBar", Vector3.new(8, 0.25, 0.25), origin + Vector3.new(0, 2.2, 0), Color3.fromRGB(210, 210, 220))
	createPart(model, "LeftWeight", Vector3.new(0.6, 1.8, 1.8), origin + Vector3.new(-4.5, 2.2, 0), Color3.fromRGB(28, 28, 32))
	createPart(model, "RightWeight", Vector3.new(0.6, 1.8, 1.8), origin + Vector3.new(4.5, 2.2, 0), Color3.fromRGB(28, 28, 32))

	return base
end

-- Builds treadmill equipment for Speed training.
local function createTreadmill(model: Model, origin: Vector3, color: Color3): BasePart
	local base = createPart(model, "SpeedPad", Vector3.new(12, 0.5, 10), origin, color)
	createPart(model, "RunningBelt", Vector3.new(7, 0.25, 3), origin + Vector3.new(0, 0.55, 0), Color3.fromRGB(30, 34, 40))
	createPart(model, "FrontConsole", Vector3.new(6, 2.5, 0.35), origin + Vector3.new(0, 1.6, -2), Color3.fromRGB(54, 60, 70))
	createPart(model, "LeftRail", Vector3.new(0.25, 1.5, 4), origin + Vector3.new(-3.5, 1.35, 0.25), Color3.fromRGB(210, 210, 220))
	createPart(model, "RightRail", Vector3.new(0.25, 1.5, 4), origin + Vector3.new(3.5, 1.35, 0.25), Color3.fromRGB(210, 210, 220))

	return base
end

-- Builds exercise bike equipment for Stamina training.
local function createBike(model: Model, origin: Vector3, color: Color3): BasePart
	local base = createPart(model, "StaminaPad", Vector3.new(12, 0.5, 10), origin, color)
	createPart(model, "BikeFrame", Vector3.new(5, 0.35, 0.35), origin + Vector3.new(0, 1.1, 0), Color3.fromRGB(230, 230, 235))
	createPart(model, "Seat", Vector3.new(1.5, 0.35, 1.2), origin + Vector3.new(-1.5, 2.1, 0), Color3.fromRGB(32, 32, 36))
	createPart(model, "Handlebars", Vector3.new(2.5, 0.25, 0.25), origin + Vector3.new(2.5, 2.2, 0), Color3.fromRGB(32, 32, 36))
	createPart(model, "Flywheel", Vector3.new(1.8, 1.8, 0.35), origin + Vector3.new(1, 1, 0), Color3.fromRGB(45, 50, 58))
	createPart(model, "RearSupport", Vector3.new(0.35, 1.8, 0.35), origin + Vector3.new(-1.5, 1.1, 0), Color3.fromRGB(230, 230, 235))

	return base
end

-- Applies a prompt to an area and connects it to server-side stat and Coin rewards.
local function attachTrainingPrompt(promptPart: BasePart, areaConfig)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "TrainPrompt"
	prompt.ActionText = areaConfig.promptText
	prompt.ObjectText = areaConfig.displayName
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = promptPart

	prompt.Triggered:Connect(function(player: Player)
		local now = os.clock()
		playerCooldowns[player] = playerCooldowns[player] or {}

		local nextAllowedTrainTime = playerCooldowns[player][areaConfig.id] or 0
		if now < nextAllowedTrainTime then
			return
		end

		playerCooldowns[player][areaConfig.id] = now + areaConfig.cooldownSeconds
		LeaderstatsService.addStat(player, areaConfig.statName, areaConfig.gain)
		LeaderstatsService.addStat(player, "Coins", areaConfig.coinReward)
	end)
end

-- Creates or refreshes all training areas in Workspace.
function TrainingAreaService.start()
	local existingFolder = Workspace:FindFirstChild(TRAINING_FOLDER_NAME)
	if existingFolder then
		existingFolder:Destroy()
	end

	local trainingFolder = Instance.new("Folder")
	trainingFolder.Name = TRAINING_FOLDER_NAME
	trainingFolder.Parent = Workspace

	for _, areaConfig in ipairs(TrainingConfig.Areas) do
		local model = Instance.new("Model")
		model.Name = areaConfig.id
		model.Parent = trainingFolder

		local promptPart: BasePart
		if areaConfig.equipmentType == "Weights" then
			promptPart = createWeights(model, areaConfig.position, areaConfig.color)
		elseif areaConfig.equipmentType == "Treadmill" then
			promptPart = createTreadmill(model, areaConfig.position, areaConfig.color)
		else
			promptPart = createBike(model, areaConfig.position, areaConfig.color)
		end

		model.PrimaryPart = promptPart
		createAreaLabel(model, promptPart, areaConfig.displayName)
		attachTrainingPrompt(promptPart, areaConfig)
	end
end

-- Clears cooldown tracking when players leave.
function TrainingAreaService.removePlayer(player: Player)
	playerCooldowns[player] = nil
end

return TrainingAreaService

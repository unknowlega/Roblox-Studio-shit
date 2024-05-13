-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ts = game:GetService("TweenService")

-- Variables
local auto = ReplicatedStorage:FindFirstChild("HA")
local character = game.Players.LocalPlayer.Character
local equippedBool = character:FindFirstChild("Equipped") or Instance.new("BoolValue")
equippedBool.Name = "Equipped"
equippedBool.Parent = character

local movementPart = auto:FindFirstChild("MeshPart")
local leftPart = auto:FindFirstChild("Left")
local rightPart = auto:FindFirstChild("Right")

if character then
	local humanoid = character:FindFirstChild("Humanoid")
	local Larm = character:FindFirstChild("RightLowerArm").Color
	local Rarm = character:FindFirstChild("LeftLowerArm").Color
	leftPart.BrickColor = BrickColor.new(Larm)
	rightPart.BrickColor = BrickColor.new(Rarm)
end

local offset2 = CFrame.new(0, -0.8, -4)
local offset1 = CFrame.new(2, -2, -4)
local isLerping = false
local targetOffset

local offsetCFrame1 = CFrame.new(2, -2, -4)
local offsetCFrame = CFrame.new(2, -4, -4)
local offsetCFrame2 = CFrame.new(0, -0.8, -4)
local targetOffsetCFrame = offset1
local interpolationSpeed = 1
local newCFrame

local currentOffset = offsetCFrame1

local tweenInfo = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

local lerpingTime = 1
local FOVChangeRate = 2

local function lerp(a, b, t)
	return a:Lerp(b, t)
end

-- Functions
local function updateAutoCFrame()
	local camera = workspace.CurrentCamera
	if camera then
		newCFrame = camera.CFrame:ToWorldSpace(currentOffset)
		local x, y, z = camera.CFrame:ToOrientation()
		y = y - math.rad(90)
		z = z - camera.CFrame:ToOrientation()
		x = 0
		newCFrame = CFrame.new(newCFrame.Position) * CFrame.fromOrientation(x, y, z)

		auto:SetPrimaryPartCFrame(newCFrame)
	end
end

local function equipAuto()
	if auto and auto.Parent ~= workspace then
		equippedBool.Value = true
		auto.Parent = workspace
		targetOffset = offsetCFrame1
		isLerping = true
	end
end

local function unequipAuto()
	equippedBool.Value = false
	if auto then
		auto.Parent = ReplicatedStorage
		currentOffset = offsetCFrame
		isLerping = true
	end
end

-- Event connections
RunService.RenderStepped:Connect(updateAutoCFrame)

UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.E then
		if equippedBool.Value then
			unequipAuto()
		else
			equipAuto()
		end
	end
end)

local function decreaseFOV()
	local camera = workspace.CurrentCamera
	if camera and camera.FieldOfView > 50 then
		camera.FieldOfView = camera.FieldOfView - FOVChangeRate
	end
end

local function increaseFOV()
	local camera = workspace.CurrentCamera
	if camera and camera.FieldOfView < 70 then
		camera.FieldOfView = camera.FieldOfView + FOVChangeRate
	end
end

UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		targetOffset = offset2
		isLerping = true

		RunService:BindToRenderStep("DecreaseFOV", Enum.RenderPriority.Camera.Value - 1, decreaseFOV)
		RunService:UnbindFromRenderStep("IncreaseFOV")
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		targetOffset = offset1
		isLerping = true

		RunService:BindToRenderStep("IncreaseFOV", Enum.RenderPriority.Camera.Value - 1, increaseFOV)
		RunService:UnbindFromRenderStep("DecreaseFOV")
	end
end)

while true do
	if isLerping then
		local startTime = tick()
		while tick() - startTime < lerpingTime do
			local elapsedTime = tick() - startTime
			local t = elapsedTime / lerpingTime
			currentOffset = lerp(currentOffset, targetOffset, t)
			updateAutoCFrame() -- Update CFrame during lerping
			RunService.RenderStepped:Wait()
		end
		isLerping = false
	end
	RunService.Heartbeat:Wait() -- Use Heartbeat for more precise timing
end

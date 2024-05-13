wait(0.1)-- this probably can be removed now but i like to keep my window from crahsing so it stays for performance reasons

--Services
local RS = game:GetService("RunService")
local player = game.Players.LocalPlayer

local blastRadius = 10
local blastDamage = 15
local maxRange = 500
local blastSpeed = 500
local maxAmmo = math.huge
local maxBlastsPerSecond = 15
local currentAmmo = maxAmmo
local lastBlastTime = tick()
local blastLifetime = 3

local shootSound = Instance.new("Sound")
shootSound.SoundId = "rbxassetid://5238024665"
shootSound.Parent = game.SoundService

local h = game.Players.LocalPlayer.Character:FindFirstChild("Equipped")

local Gui = game.Players.LocalPlayer.PlayerGui["In-GameGUI"]
local Frame = Gui.Frame
local Text = Frame.TextLabel

Text.Text = tostring(currentAmmo) .. "/" .. tostring(maxAmmo)

local maxDistanceThreshold = 0

function createBlast()
	if currentAmmo <= 0 then
		return
	end
	
	local currentTime = tick()
	local timeSinceLastBlast = currentTime - lastBlastTime
	local timeBetweenBlasts = 1 / maxBlastsPerSecond
	if timeSinceLastBlast < timeBetweenBlasts then
		return
	end
	
	currentAmmo = currentAmmo - 1
	
	lastBlastTime = currentTime
	
	local blastCreationTime = tick()
	
	local blast = game.ReplicatedStorage.Bullet:Clone()

	local cam = workspace.Camera
	if cam then
		local mousePosition = game:GetService("Players").LocalPlayer:GetMouse().Hit.p
		
		local offset = CFrame.new(0, 1, -5)
		
		local x, y, z = cam.CFrame:ToOrientation()

		local direction = (mousePosition - cam.CFrame.p).Unit
		blast.CFrame = cam.CFrame:ToWorldSpace() * offset * CFrame.fromOrientation(x, y, z)

		wait(0.1)
		
		local rotation = Vector3.new(0.003, 0, 0)
		cam.CFrame = cam.CFrame * CFrame.Angles(rotation.X, rotation.Y, rotation.Z)

		shootSound:Play()

		local nearestCharacter = nil
		local shortestDistance = math.huge
		
		for _, character in pairs(game.Workspace:GetChildren()) do
			if character:IsA("Model") and character ~= player.Character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
				local distance = (character.HumanoidRootPart.Position - player.Character.Head.Position and mousePosition - player.Character.Head.Position).Magnitude
				local mouseToCharacterDistance = (character.HumanoidRootPart.Position - mousePosition).Magnitude
				if distance < shortestDistance and mouseToCharacterDistance <= maxDistanceThreshold then
					shortestDistance = distance
					nearestCharacter = character
				end
			end
		end -- this section is basically aimbot but we call it accuracy because to lazy to do shot spread

		if nearestCharacter then
			direction = (nearestCharacter.HumanoidRootPart.Position - player.Character.Head.Position).Unit
		end

		blast.Velocity = Vector3.new(direction.X * blastSpeed, direction.Y * blastSpeed, direction.Z * blastSpeed)

		blast.Parent = game.Workspace

		local hasDamaged = {}

		blast.Touched:Connect(function(hit)
			blast:Destroy()

			local character = hit.Parent
			if character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid.Health > 0 and not hasDamaged[character] then
					humanoid:TakeDamage(blastDamage)
					print("Hit: " .. character.Name)
					hasDamaged[character] = true
				end
			end
		end)
	end

	RS.Heartbeat:Connect(function()
		if blast then
			local traveledDistance = (blast.Position - player.Character.Head.Position).Magnitude
			local currentTime = tick()

			if traveledDistance >= maxRange or currentTime - blastCreationTime >= blastLifetime then
				blast:Destroy()
			end
		end
	end)
	
	Text.Text = tostring(currentAmmo) .. "/" .. tostring(maxAmmo) --can be removed this is just for text but maxammo is already set a math.huge.
end

local setTrue = false

RS.RenderStepped:Connect(function()
	if h then
		if h.Value == true then
			setTrue = true
		else
			setTrue = false
		end
	end
	
	wait(0.1)
end)

local mouseButton1Down = false
local inputCd = 0
local blastCooldown = 0.001

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
		if setTrue == true then
			--wait(inputCd) i forgot what this was for maybe like a cooldown after not shooting for a while
			mouseButton1Down = true
			while mouseButton1Down do
				createBlast()
				wait(blastCooldown)
			end
		end
	end
end)-- you should definetly make this way better for working an automactic like make it shoot #bullets while holding down input instead of a loop foreach individual shot.

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouseButton1Down = false
		inputCd = 0.2
	end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		maxDistanceThreshold = 5 -- basically meaning it gives the player more 'accuracy'
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		maxDistanceThreshold = 0
	end
end)

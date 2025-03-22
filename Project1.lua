-- Made by Mister ToXxiC
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Settings
local AimbotEnabled = true
local ESPEnabled = true
local FOV = 100
local Smoothness = 0.12

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled = false
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = FOV
FOVCircle.Visible = true

-- Rainbow function
local function getRainbow()
	local t = tick()
	return Color3.fromHSV((t % 5) / 5, 1, 1)
end

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 140)
frame.Position = UDim2.new(0, 10, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2

local function createButton(name, posY, callback)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, -10, 0, 25)
	btn.Position = UDim2.new(0, 5, 0, posY)
	btn.Text = name
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.MouseButton1Click:Connect(callback)
end

createButton("Toggle Aimbot", 5, function()
	AimbotEnabled = not AimbotEnabled
end)

createButton("Toggle ESP", 35, function()
	ESPEnabled = not ESPEnabled
end)

createButton("FOV +10", 65, function()
	FOV = FOV + 10
end)

createButton("FOV -10", 95, function()
	FOV = math.max(10, FOV - 10)
end)

createButton("Smooth +0.01", 125, function()
	Smoothness = Smoothness + 0.01
end)

-- Aimbot Targeting
local function getClosestTarget()
	local closest, dist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character and plr.Character:FindFirstChild("Head") then
			local head = plr.Character.Head
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local mag = (Vector2.new(screenPos.X, screenPos.Y) - Camera.ViewportSize/2).Magnitude
				if mag < FOV and mag < dist then
					local ray = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 500, {
						FilterDescendantsInstances = {LP.Character}, 
						FilterType = Enum.RaycastFilterType.Blacklist
					})
					if not ray or ray.Instance:IsDescendantOf(plr.Character) then
						closest = plr
						dist = mag
					end
				end
			end
		end
	end
	return closest
end

-- ESP Storage
local drawings = {}

local function createESP(plr)
	local box = Drawing.new("Square")
	box.Thickness = 2
	box.Filled = false
	box.Color = Color3.fromRGB(0, 255, 0)

	local line = Drawing.new("Line")
	line.Thickness = 1.5
	line.Color = Color3.fromRGB(255, 255, 255)

	local charm = Drawing.new("Circle")
	charm.Radius = 4
	charm.Filled = true
	charm.Color = Color3.fromRGB(255, 0, 0)

	drawings[plr] = {
		Box = box,
		Line = line,
		Charm = charm
	}
end

local function removeESP(plr)
	if drawings[plr] then
		for _, d in pairs(drawings[plr]) do
			d:Remove()
		end
		drawings[plr] = nil
	end
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LP then createESP(plr) end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
	local center = Camera.ViewportSize / 2
	FOVCircle.Position = center
	FOVCircle.Radius = FOV
	FOVCircle.Color = getRainbow()
	FOVCircle.Visible = AimbotEnabled

	-- Aimbot
	if AimbotEnabled then
		local target = getClosestTarget()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			local headPos = target.Character.Head.Position
			local dir = (headPos - Camera.CFrame.Position).Unit
			local newCF = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir)
			Camera.CFrame = Camera.CFrame:Lerp(newCF, Smoothness)
		end
	end

	-- ESP
	for plr, esp in pairs(drawings) do
		local char = plr.Character
		if ESPEnabled and char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart") then
			local headPos = char.Head.Position
			local rootPos = char.HumanoidRootPart.Position

			local top = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 0.5, 0))
			local bottom = Camera:WorldToViewportPoint(rootPos - Vector3.new(0, 2.5, 0))
			local sizeY = math.abs(top.Y - bottom.Y)
			local sizeX = sizeY / 1.5
			local boxPos = Vector2.new(top.X - sizeX/2, top.Y)

			esp.Box.Size = Vector2.new(sizeX, sizeY)
			esp.Box.Position = boxPos
			esp.Box.Visible = true

			local headScreen = Camera:WorldToViewportPoint(headPos)
			esp.Line.From = Vector2.new(Camera.ViewportSize.X/2, 0)
			esp.Line.To = Vector2.new(headScreen.X, headScreen.Y)
			esp.Line.Visible = true

			esp.Charm.Position = Vector2.new(headScreen.X, headScreen.Y)
			esp.Charm.Visible = true
		else
			esp.Box.Visible = false
			esp.Line.Visible = false
			esp.Charm.Visible = false
		end
	end
end)

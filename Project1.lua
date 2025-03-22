-- Fisch Hub Mobile-Friendly by Mister C

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

-- Safe Teleport Function
local function safeTweenTP(target)
	local hrp = char:WaitForChild("HumanoidRootPart")
	local dist = (hrp.Position - target).Magnitude
	local t = math.clamp(dist / 50, 1, 4)
	local tween = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target)})
	tween:Play()
end

-- Lokasi Teleport
local Locations = {
	["Mousewood"] = Vector3.new(72, 3, -470),
	["Forsaken Veil"] = Vector3.new(-180, 3, -680),
	["Ancient Isle"] = Vector3.new(430, 3, -310),
}

-- UI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

-- Tombol kecil [≡] pojok kiri atas
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 5, 0, 5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.Text = "≡"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.ZIndex = 5

-- Frame utama
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 230)
frame.Position = UDim2.new(0.05, 0, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
Instance.new("UIStroke", frame).Color = Color3.fromRGB(70, 70, 70)

frame.Visible = true

toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- Dropdown UI
local selectedLocation = nil
local dropBtn = Instance.new("TextButton", frame)
dropBtn.Size = UDim2.new(1, -20, 0, 30)
dropBtn.Position = UDim2.new(0, 10, 0, 10)
dropBtn.Text = "Select Location ▼"
dropBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local dropList = Instance.new("Frame", frame)
dropList.Size = UDim2.new(1, -20, 0, 90)
dropList.Position = UDim2.new(0, 10, 0, 40)
dropList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dropList.Visible = false

local y = 0
for name, _ in pairs(Locations) do
	local btn = Instance.new("TextButton", dropList)
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.Position = UDim2.new(0, 0, 0, y)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.MouseButton1Click:Connect(function()
		selectedLocation = name
		dropBtn.Text = "Selected: " .. name .. " ▼"
		dropList.Visible = false
	end)
	y += 30
end

dropBtn.MouseButton1Click:Connect(function()
	dropList.Visible = not dropList.Visible
end)

-- Tombol Teleport
local tpBtn = Instance.new("TextButton", frame)
tpBtn.Size = UDim2.new(1, -20, 0, 30)
tpBtn.Position = UDim2.new(0, 10, 0, 100)
tpBtn.Text = "Teleport"
tpBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.MouseButton1Click:Connect(function()
	if selectedLocation and Locations[selectedLocation] then
		safeTweenTP(Locations[selectedLocation])
	end
end)

-- Toggle Switch Creator
local function createSwitch(name, posY, callback)
	local label = Instance.new("TextLabel", frame)
	label.Text = name
	label.Position = UDim2.new(0, 10, 0, posY)
	label.Size = UDim2.new(0, 130, 0, 25)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local switch = Instance.new("Frame", frame)
	switch.Position = UDim2.new(0, 140, 0, posY + 2)
	switch.Size = UDim2.new(0, 50, 0, 20)
	switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	switch.BorderSizePixel = 0

	local circle = Instance.new("Frame", switch)
	circle.Size = UDim2.new(0, 16, 0, 16)
	circle.Position = UDim2.new(0, 2, 0, 2)
	circle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
	circle.BorderSizePixel = 0
	circle.Name = "ToggleCircle"

	local on = false
	switch.InputBegan:Connect(function()
		on = not on
		if on then
			switch.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
			circle.Position = UDim2.new(1, -18, 0, 2)
		else
			switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			circle.Position = UDim2.new(0, 2, 0, 2)
		end
		callback(on)
	end)
end

-- Auto Fish
local autoFish = false
createSwitch("Auto Fish", 140, function(state)
	autoFish = state
end)

task.spawn(function()
	while task.wait(2.5) do
		if autoFish then
			local ev = ReplicatedStorage:FindFirstChild("FishingEvent")
			if ev then
				ev:FireServer("Cast")
				task.wait(2.5)
				ev:FireServer("Reel")
			end
		end
	end
end)

-- Auto Sell
local autoSell = false
createSwitch("Auto Sell", 170, function(state)
	autoSell = state
end)

task.spawn(function()
	while task.wait(60) do
		if autoSell then
			local sell = ReplicatedStorage:FindFirstChild("SellFish")
			if sell then
				sell:FireServer()
			end
		end
	end
end)

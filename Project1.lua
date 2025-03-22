-- SETTINGS
local settings = {
    aimbot = true,
    fov = 100,
    smoothness = 0.2,
    fovRainbow = true,
    targetPart = "Head",
    esp = true
}

-- SERVICES
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local cam = workspace.CurrentCamera
local lp = Players.LocalPlayer

-- DRAW FOV CIRCLE
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Radius = settings.fov
fovCircle.Filled = false
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Position = cam.ViewportSize / 2
fovCircle.Visible = true

-- RAINBOW FOV
task.spawn(function()
    while true do
        if settings.fovRainbow then
            local t = tick() * 0.5
            fovCircle.Color = Color3.fromHSV(t % 1, 1, 1)
        end
        RunService.RenderStepped:Wait()
    end
end)

-- ESP
local function createESP(plr)
    if plr == lp then return end
    local box = Drawing.new("Square")
    local line = Drawing.new("Line")
    box.Thickness, box.Color, box.Filled, box.Transparency = 1, Color3.new(0, 1, 0), false, 1
    line.Thickness, line.Color, line.Transparency = 1, Color3.new(1, 0, 0), 1

    local function update()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onscreen = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onscreen then
                local size = 50 / (plr.Character.HumanoidRootPart.Position - cam.CFrame.Position).Magnitude * 100
                box.Size = Vector2.new(size, size * 1.5)
                box.Position = Vector2.new(pos.X - size/2, pos.Y - size*1.5/2)
                box.Visible = settings.esp
                line.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                line.To = Vector2.new(pos.X, pos.Y)
                line.Visible = settings.esp
            else
                box.Visible = false
                line.Visible = false
            end
        else
            box.Visible = false
            line.Visible = false
        end
    end

    RunService.RenderStepped:Connect(update)
end

for _, p in pairs(Players:GetPlayers()) do
    createESP(p)
end

Players.PlayerAdded:Connect(createESP)

-- AIMBOT
local function getClosest()
    local nearest, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild(settings.targetPart) and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onscreen = cam:WorldToViewportPoint(v.Character[settings.targetPart].Position)

            local origin = cam.CFrame.Position
            local direction = (v.Character[settings.targetPart].Position - origin).Unit * 500
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {lp.Character}

            local ray = workspace:Raycast(origin, direction, rayParams)
            if ray and ray.Instance:IsDescendantOf(v.Character) and onscreen then
                local diff = (Vector2.new(pos.X, pos.Y) - cam.ViewportSize / 2).Magnitude
                if diff < dist and diff < settings.fov then
                    dist = diff
                    nearest = v
                end
            end
        end
    end
    return nearest
end

RunService.RenderStepped:Connect(function()
    fovCircle.Position = cam.ViewportSize / 2
    fovCircle.Radius = settings.fov

    if settings.aimbot then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild(settings.targetPart) then
            local aimPos = target.Character[settings.targetPart].Position
            local newCF = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + (aimPos - cam.CFrame.Position).Unit)
            cam.CFrame = cam.CFrame:Lerp(newCF, settings.smoothness)
        end
    end
end)

-- GUI TOGGLE + FOV/SMOOTHNESS
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AimbotSettings"
gui.ResetOnSpawn = false

local function createLabel(name, pos)
	local lbl = Instance.new("TextLabel", gui)
	lbl.Size = UDim2.new(0, 140, 0, 30)
	lbl.Position = pos
	lbl.Text = name
	lbl.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextScaled = true
	lbl.Name = name
	return lbl
end

local function createBtn(text, pos, callback)
	local btn = Instance.new("TextButton", gui)
	btn.Size = UDim2.new(0, 30, 0, 30)
	btn.Position = pos
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.MouseButton1Click:Connect(callback)
	return btn
end

createBtn("AIM", UDim2.new(0, 10, 0, 20), function()
	settings.aimbot = not settings.aimbot
end)

local fovLbl = createLabel("FOV: "..settings.fov, UDim2.new(0, 10, 0, 60))
createBtn("+", UDim2.new(0, 160, 0, 60), function()
	settings.fov = settings.fov + 10
	fovLbl.Text = "FOV: " .. settings.fov
	fovCircle.Radius = settings.fov
end)
createBtn("-", UDim2.new(0, 200, 0, 60), function()
	settings.fov = math.max(20, settings.fov - 10)
	fovLbl.Text = "FOV: " .. settings.fov
	fovCircle.Radius = settings.fov
end)

local smLbl = createLabel("Smooth: "..settings.smoothness, UDim2.new(0, 10, 0, 100))
createBtn("+", UDim2.new(0, 160, 0, 100), function()
	settings.smoothness = math.clamp(settings.smoothness + 0.05, 0.01, 1)
	smLbl.Text = "Smooth: " .. string.format("%.2f", settings.smoothness)
end)
createBtn("-", UDim2.new(0, 200, 0, 100), function()
	settings.smoothness = math.clamp(settings.smoothness - 0.05, 0.01, 1)
	smLbl.Text = "Smooth: " .. string.format("%.2f", settings.smoothness)
end)

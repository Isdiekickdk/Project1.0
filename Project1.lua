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
local cam = workspace.CurrentCamera
local lp = Players.LocalPlayer

-- FOV CIRCLE
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Visible = true

-- RAINBOW FOV COLOR
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
local function createESP(player)
    if player == lp then return end
    local box = Drawing.new("Square")
    local line = Drawing.new("Line")
    box.Color = Color3.new(0, 1, 0)
    box.Thickness = 1
    box.Filled = false
    box.Transparency = 1
    line.Color = Color3.new(1, 0, 0)
    line.Thickness = 1
    line.Transparency = 1

    RunService.RenderStepped:Connect(function()
        if settings.esp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            local hrp = player.Character.HumanoidRootPart
            local head = player.Character.Head
            local hrpPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))

            if onScreen then
                local distance = (cam.CFrame.Position - hrp.Position).Magnitude
                local scale = 1 / (distance * 0.3)
                local boxSize = Vector2.new(35 * scale * 100, 50 * scale * 100)

                box.Size = boxSize
                box.Position = Vector2.new(hrpPos.X - boxSize.X / 2, hrpPos.Y - boxSize.Y / 2)
                box.Visible = true

                line.From = Vector2.new(cam.ViewportSize.X / 2, 0)
                line.To = Vector2.new(headPos.X, headPos.Y)
                line.Visible = true
            else
                box.Visible = false
                line.Visible = false
            end
        else
            box.Visible = false
            line.Visible = false
        end
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    createESP(plr)
end
Players.PlayerAdded:Connect(createESP)

-- GET CLOSEST TARGET
local function getClosest()
    local closest, shortest = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild(settings.targetPart) and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local part = v.Character[settings.targetPart]
            local pos, onScreen = cam:WorldToViewportPoint(part.Position)

            local origin = cam.CFrame.Position
            local direction = (part.Position - origin).Unit * 500
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {lp.Character}

            local hit = workspace:Raycast(origin, direction, rayParams)
            if hit and hit.Instance:IsDescendantOf(v.Character) and onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - cam.ViewportSize / 2).Magnitude
                if dist < settings.fov and dist < shortest then
                    shortest = dist
                    closest = v
                end
            end
        end
    end
    return closest
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    fovCircle.Position = cam.ViewportSize / 2
    fovCircle.Radius = settings.fov

    if settings.aimbot then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild(settings.targetPart) then
            local aimPos = target.Character[settings.targetPart].Position
            local dir = (aimPos - cam.CFrame.Position).Unit
            local newCF = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + dir)
            cam.CFrame = cam.CFrame:Lerp(newCF, settings.smoothness)
        end
    end
end)

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false
gui.Name = "AimbotGUI"

local function createBtn(text, pos, size, callback)
	local btn = Instance.new("TextButton", gui)
	btn.Text = text
	btn.Size = size
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.MouseButton1Click:Connect(callback)
	return btn
end

createBtn("AIM ON/OFF", UDim2.new(0, 10, 0, 20), UDim2.new(0, 120, 0, 30), function()
	settings.aimbot = not settings.aimbot
end)

local fovLabel = Instance.new("TextLabel", gui)
fovLabel.Size = UDim2.new(0, 160, 0, 30)
fovLabel.Position = UDim2.new(0, 10, 0, 60)
fovLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
fovLabel.TextColor3 = Color3.new(1, 1, 1)
fovLabel.TextScaled = true
fovLabel.Text = "FOV: " .. settings.fov

createBtn("+", UDim2.new(0, 180, 0, 60), UDim2.new(0, 30, 0, 30), function()
	settings.fov += 10
	fovLabel.Text = "FOV: " .. settings.fov
end)
createBtn("-", UDim2.new(0, 220, 0, 60), UDim2.new(0, 30, 0, 30), function()
	settings.fov = math.max(10, settings.fov - 10)
	fovLabel.Text = "FOV: " .. settings.fov
end)

local smoothLabel = Instance.new("TextLabel", gui)
smoothLabel.Size = UDim2.new(0, 160, 0, 30)
smoothLabel.Position = UDim2.new(0, 10, 0, 100)
smoothLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
smoothLabel.TextColor3 = Color3.new(1, 1, 1)
smoothLabel.TextScaled = true
smoothLabel.Text = "Smooth: " .. settings.smoothness

createBtn("+", UDim2.new(0, 180, 0, 100), UDim2.new(0, 30, 0, 30), function()
	settings.smoothness = math.clamp(settings.smoothness + 0.05, 0.01, 1)
	smoothLabel.Text = "Smooth: " .. string.format("%.2f", settings.smoothness)
end)
createBtn("-", UDim2.new(0, 220, 0, 100), UDim2.new(0, 30, 0, 30), function()
	settings.smoothness = math.clamp(settings.smoothness - 0.05, 0.01, 1)
	smoothLabel.Text = "Smooth: " .. string.format("%.2f", settings.smoothness)
end)

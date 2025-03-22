--// CONFIG
local settings = {
    aimbot = true,
    esp = true,
    fov = 120,
    fovRainbow = true,
    targetPart = "Head"
}

--// SERVICES
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local cam = workspace.CurrentCamera
local lp = players.LocalPlayer

--// FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Filled = false
fovCircle.Radius = settings.fov
fovCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
fovCircle.Visible = true

--// Rainbow FOV
local hue = 0
local function updateFOVColor()
    if settings.fovRainbow then
        hue = (hue + 0.01) % 1
        fovCircle.Color = Color3.fromHSV(hue, 1, 1)
    else
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
    end
end

--// Toggle GUI
local toggleUI = Instance.new("ScreenGui", game.CoreGui)
local toggleBtn = Instance.new("TextButton", toggleUI)
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0, 20, 0, 20)
toggleBtn.Text = "Aimbot: ON"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.TextScaled = true

toggleBtn.MouseButton1Click:Connect(function()
    settings.aimbot = not settings.aimbot
    toggleBtn.Text = settings.aimbot and "Aimbot: ON" or "Aimbot: OFF"
    toggleBtn.BackgroundColor3 = settings.aimbot and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(100, 100, 100)
end)

--// Get Closest Player
function getClosestPlayer()
    local closest, dist = nil, math.huge
    for _, player in pairs(players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild(settings.targetPart) then
            local pos, visible = cam:WorldToViewportPoint(player.Character[settings.targetPart].Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - cam.ViewportSize/2).Magnitude
            if visible and magnitude < dist and magnitude <= settings.fov then
                dist = magnitude
                closest = player
            end
        end
    end
    return closest
end

--// ESP Function
function createESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Filled = false
    box.Visible = false

    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = Color3.fromRGB(255, 0, 0)
    line.Visible = false

    runService.RenderStepped:Connect(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos, onscreen = cam:WorldToViewportPoint(hrp.Position)
            if onscreen then
                local size = (cam:WorldToViewportPoint(hrp.Position + Vector3.new(2,3,0)).Y - pos.Y)
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
    end)
end

--// Add ESP to other players
for _, plr in pairs(players:GetPlayers()) do
    if plr ~= lp then
        createESP(plr)
    end
end
players.PlayerAdded:Connect(function(plr)
    if plr ~= lp then
        createESP(plr)
    end
end)

--// Aimbot Main Loop
runService.RenderStepped:Connect(function()
    updateFOVColor()
    fovCircle.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    if settings.aimbot then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(settings.targetPart) then
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character[settings.targetPart].Position)
        end
    end
end)

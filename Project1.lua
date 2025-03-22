--// Inisialisasi Layanan
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Cam = Workspace.CurrentCamera
local LP = Players.LocalPlayer

--// Variabel
local aimbotOn = true
local fovRadius = 150

--// GUI Utama
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "CheatGUI"

--// Tombol Toggle Aimbot
local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 140, 0, 40)
toggle.Position = UDim2.new(0, 20, 0, 100)
toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Text = "Aimbot: ON"
toggle.TextScaled = true

toggle.MouseButton1Click:Connect(function()
    aimbotOn = not aimbotOn
    toggle.Text = "Aimbot: " .. (aimbotOn and "ON" or "OFF")
end)

--// FOV Circle Rainbow
local fovFrame = Instance.new("Frame", gui)
fovFrame.Size = UDim2.new(0, fovRadius*2, 0, fovRadius*2)
fovFrame.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
fovFrame.BackgroundTransparency = 1

local fovCircle = Instance.new("ImageLabel", fovFrame)
fovCircle.Size = UDim2.new(1, 0, 1, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Image = "rbxassetid://11376928063"

local hue = 0
RunService.RenderStepped:Connect(function()
    hue = (hue + 1) % 360
    fovCircle.ImageColor3 = Color3.fromHSV(hue / 360, 1, 1)
end)

--// ESP Setup
local function addESP(player)
    if player == LP then return end

    local function createESP(part, color)
        local adorn = Instance.new("BoxHandleAdornment")
        adorn.Name = "ESPBox"
        adorn.Size = Vector3.new(2, 2, 2)
        adorn.Color3 = color
        adorn.AlwaysOnTop = true
        adorn.ZIndex = 5
        adorn.Adornee = part
        adorn.Parent = part
    end

    local function createLine(from, to)
        local attachment0 = Instance.new("Attachment", from)
        local attachment1 = Instance.new("Attachment", to)
        local beam = Instance.new("Beam", from)
        beam.Attachment0 = attachment0
        beam.Attachment1 = attachment1
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.Color = ColorSequence.new(Color3.new(1,0,0))
    end

    local char = player.Character or player.CharacterAdded:Wait()
    if char then
        if char:FindFirstChild("Head") then
            createESP(char.Head, Color3.fromRGB(255,0,0))
        end
        if char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") then
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            createESP(torso, Color3.fromRGB(0,255,0))
            if char:FindFirstChild("Head") then
                createLine(torso, char.Head)
            end
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    addESP(p)
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        wait(1)
        addESP(p)
    end)
end)

--// Aimbot Logic
local function getClosest()
    local closest = nil
    local shortest = fovRadius
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("Head") then
            local pos, visible = Cam:WorldToViewportPoint(player.Character.Head.Position)
            if visible then
                local dist = (Vector2.new(pos.X, pos.Y) - Cam.ViewportSize / 2).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not aimbotOn then return end
    local target = getClosest()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        Cam.CFrame = CFrame.new(Cam.CFrame.Position, target.Character.Head.Position)
    end
end)

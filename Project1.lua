-- Fisch Hub - Mobile Edition FINAL
-- Made by Mister C

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local PlaceId = game.PlaceId

-- === ANTI LAG BOOSTER ===
pcall(function()
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)

    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("Decal") then
            v.Transparency = 1
        elseif v:IsA("Explosion") then
            v.Visible = false
        elseif v:IsA("MeshPart") or v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        end
    end
end)

-- Rayfield UI
loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
local Window = Rayfield:CreateWindow({ Name = "Fisch Hub | Mobile", ConfigurationSaving = { Enabled = false }, Discord = { Enabled = false }, KeySystem = false })

-- State
local autofish = false
local autosell = false

-- Functions
function fish()
    while autofish do
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Remote") then
            tool.Remote:InvokeServer("Fish")
        end
        task.wait(1.2)
    end
end

function sellLoop()
    while autosell do
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SellAll"):FireServer()
        task.wait(60)
    end
end

function safeTweenTP(pos)
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (hrp.Position - pos).Magnitude
    local time = math.clamp(dist / 50, 1, 4)
    local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tween:Play()
end

function serverHopToLowPop()
    local cursor = ""
    local found = false
    repeat
        local url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100&cursor="..cursor
        local data = HttpService:JSONDecode(game:HttpGet(url))
        for _, server in ipairs(data.data) do
            if server.playing < 8 and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
                found = true
                break
            end
        end
        cursor = data.nextPageCursor or ""
    until found or cursor == "" or not cursor
end

-- === UI Elements ===
local Tab = Window:CreateTab("Fisch Hub", 4483362458)

Tab:CreateToggle({
    Name = "Auto Fishing",
    CurrentValue = false,
    Callback = function(v)
        autofish = v
        if v then task.spawn(fish) end
    end
})

Tab:CreateToggle({
    Name = "Auto Sell (tiap 60 detik)",
    CurrentValue = false,
    Callback = function(v)
        autosell = v
        if v then task.spawn(sellLoop) end
    end
})

Tab:CreateDropdown({
    Name = "Teleport Lokasi",
    Options = {"Mousewood", "Forsaken Veil", "Ancient Isle"},
    CurrentOption = "Mousewood",
    Callback = function(opt)
        local locs = {
            ["Mousewood"] = Vector3.new(-113, 8, -126),
            ["Forsaken Veil"] = Vector3.new(2295, 12, -1234),
            ["Ancient Isle"] = Vector3.new(-2022, 6, 1996)
        }
        if locs[opt] then safeTweenTP(locs[opt]) end
    end
})

Tab:CreateButton({
    Name = "Server Sepi",
    Callback = function()
        serverHopToLowPop()
    end
})

Tab:CreateButton({
    Name = "Sembunyikan UI (klik Show UI kecil)",
    Callback = function()
        Rayfield:Destroy()

        local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
        ScreenGui.Name = "FischMiniUI"
        ScreenGui.ResetOnSpawn = false

        local btn = Instance.new("TextButton", ScreenGui)
        btn.Size = UDim2.new(0, 90, 0, 30)
        btn.Position = UDim2.new(1, -100, 0, 20)
        btn.Text = "Show UI"
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.BorderSizePixel = 1
        btn.AutoButtonColor = true

        btn.MouseButton1Click:Connect(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/NamaKamu/RepoKamu/main/fisch_hub.lua"))()
            btn:Destroy()
        end)
    end
})

--// Fisch Hub by Mister C // Aman, KRNL Mobile Friendly

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")

-- Anti Lag
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
setfpscap(40)

-- UI
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tenbitload/uilib/main/minimal.lua"))()
local win = lib:Window("KAU APA")

-- Toggle states
local autofish = false
local autosell = false

-- Lokasi Teleport
local locations = {
    ["Mousewood"] = Vector3.new(-143, 2, -400),
    ["Forsaken Veil"] = Vector3.new(520, 2, 1090),
    ["Ancient Isle"] = Vector3.new(-900, 2, 880),
}

-- Auto Fishing
task.spawn(function()
    while task.wait(1.2) do
        if autofish and tool and tool:FindFirstChild("Remote") then
            pcall(function()
                tool.Remote:InvokeServer("Fish")
            end)
        end
    end
end)

-- Auto Sell
task.spawn(function()
    while task.wait(60) do
        if autosell then
            pcall(function()
                ReplicatedStorage.Remote:InvokeServer("Sell", "All")
            end)
        end
    end
end)

-- UI Elements
win:Toggle("Auto Fishing", false, function(v)
    autofish = v
end)

win:Toggle("Auto Sell", false, function(v)
    autosell = v
end)

win:Dropdown("Teleport", {"Mousewood", "Forsaken Veil", "Ancient Isle"}, function(loc)
    if locations[loc] then
        player.Character:MoveTo(locations[loc])
    end
end)

win:Button("Server Sepi (Auto Hop)", function()
    local placeId = game.PlaceId
    local function getServers()
        local cursor = nil
        while true do
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor then url = url .. "&cursor=" .. cursor end

            local data = HttpService:JSONDecode(game:HttpGet(url))
            for _, server in pairs(data.data) do
                if server.playing < 5 and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
                    return
                end
            end
            cursor = data.nextPageCursor
            if not cursor then break end
        end
    end
    getServers()
end)

-- Tombol Show/Hide UI (pojok kiri atas)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "FischUIToggle"
toggleBtn.Parent = game.CoreGui
toggleBtn.Size = UDim2.new(0, 100, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "Fisch Hub"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.SourceSansSemibold
toggleBtn.ZIndex = 9999

toggleBtn.MouseButton1Click:Connect(function()
    win:ToggleUI()
end)

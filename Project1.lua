--[[  
    Speed Hub for Fisch - by Mister C  
    Fitur: Auto Mancing (smart), Auto Jual, Teleport, Auto Beli, Server Sepi, Anti-Ban, Reconnect
--]]

local Library = loadstring(game:HttpGet("https://pastebin.com/raw/VQ9YpNpy"))() -- UI Library
local plr = game.Players.LocalPlayer
local FischRemote = game:GetService("ReplicatedStorage").RemoteEvent

-- Anti-AFK
pcall(function()
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        local VU = game:GetService("VirtualUser")
        VU:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        VU:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)

-- UI Setup
local win = Library:CreateWindow("Speed Hub - Fisch")
local autoTab = win:CreateTab("Auto")
local tpTab = win:CreateTab("Teleport")
local miscTab = win:CreateTab("Misc")

-- Variables
local autoFish = false
local autoSell = false
local autoBuy = false

-- Utils
function randomDelay(min, max)
    return math.random(min * 100, max * 100) / 100
end

function simulateInput(key)
    keypress(key)
    task.wait(0.1)
    keyrelease(key)
end

-- AUTO MANCING
autoTab:CreateToggle("Auto Mancing", function(v)
    autoFish = v
    task.spawn(function()
        while autoFish do
            -- Casting
            FischRemote:FireServer("Cast")
            task.wait(randomDelay(2, 3))

            -- Shake
            FischRemote:FireServer("Shake")
            task.wait(randomDelay(1, 1.5))

            -- Reel
            FischRemote:FireServer("Reel")
            task.wait(randomDelay(2, 3.5))
        end
    end)
end)

-- AUTO JUAL
autoTab:CreateToggle("Auto Jual Tiap 60 Detik", function(v)
    autoSell = v
    task.spawn(function()
        while autoSell do
            FischRemote:FireServer("Sell")
            task.wait(randomDelay(58, 65)) -- 1 menit acak
        end
    end)
end)

-- AUTO BELI
autoTab:CreateToggle("Auto Beli Rod & Umpan", function(v)
    autoBuy = v
    task.spawn(function()
        while autoBuy do
            FischRemote:FireServer("BuyRod")
            task.wait(1)
            FischRemote:FireServer("BuyBait", "Quality Bait Crate")
            task.wait(randomDelay(60, 70))
        end
    end)
end)

-- TELEPORT UI
local lokasi = {
    ["Spawn"] = CFrame.new(0, 5, 0),
    ["Dock"] = CFrame.new(100, 5, -200),
    ["Fishing Spot A"] = CFrame.new(500, 5, 300),
    ["Fishing Spot B"] = CFrame.new(-400, 5, 800),
}
tpTab:CreateDropdown("Pilih Lokasi", lokasi, function(opt)
    plr.Character:MoveTo(lokasi[opt].Position)
end)

-- SERVER SEPI
miscTab:CreateButton("Server Sepi", function()
    local Http = game:GetService("HttpService")
    local TP = game:GetService("TeleportService")
    local id = game.PlaceId
    local servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..id.."/servers/Public?sortOrder=Asc&limit=100")).data
    for i,v in pairs(servers) do
        if v.playing < 5 then
            TP:TeleportToPlaceInstance(id, v.id)
            break
        end
    end
end)

-- AUTO RECONNECT
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed or state == Enum.TeleportState.Started then
        repeat
            task.wait(5)
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        until false
    end
end)

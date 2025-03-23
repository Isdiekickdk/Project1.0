--// Fisch Hub by Mister C
--// Aman, stabil, full fitur buat KRNL Mobile

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")

-- Anti Lag
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
setfpscap(30)

-- UI Library
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tenbitload/uilib/main/minimal.lua"))()
local win = lib:Window("Fisch Hub")

-- Toggles
local autofish = false
local autosell = false

-- Locations
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

-- UI Setup
win:Toggle("Auto Fishing", false, function(v)
    autofish = v
end)

win:Toggle("Auto Sell", false, function(v)
    autosell = v
end)

win:Dropdown("Teleport", {"Mousewood", "Forsaken Veil", "Ancient Isle"}, function(loc)
    if locations[loc] then
        player.Character:Move

-- Premium Extreme v4.1 Private Stealth+ Extended - Fisch Bypass
pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end

    -- [MetaMethod Protection]
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if tostring(self):lower():find("log") or tostring(self):lower():find("report") then
            return wait(9e9)
        end
        if method == "Kick" or self.Name == "Kick" then
            return wait(9e9)
        end
        return oldNamecall(self, ...)
    end)

    mt.__index = newcclosure(function(self, key)
        if tostring(key):lower():find("kick") then
            return function() return nil end
        end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)

    -- [Runtime Hook]
    for _,v in next, getgc(true) do
        if typeof(v) == "function" and islclosure(v) and not isexecutorclosure(v) then
            local info = debug.getinfo(v)
            if info.name and (info.name:lower():find("ban") or info.name:lower():find("kick") or info.name:lower():find("flag")) then
                hookfunction(v, function(...) return nil end)
            end
        end
    end

    -- [Remote Filter]
    local BlockedRemotes = {"Flag", "Report", "Ban", "Log", "Detect"}
    local function isSuspicious(remote)
        local name = tostring(remote):lower()
        for _, keyword in pairs(BlockedRemotes) do
            if name:find(keyword:lower()) then
                return true
            end
        end
        return false
    end

    local raw; raw = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if isSuspicious(self) then return nil end
        return raw(self, ...)
    end))

    -- [Spoofing]
    if setidentity then setidentity(8) end

    hookfunction(game:GetService("DataStoreService").GetDataStore, function()
        return setmetatable({}, {
            __index = function() return function() return nil end end,
            __newindex = function() end
        })
    end)

    -- [Fake Input]
    task.spawn(function()
        while true do
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "W", false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "W", false, game)
            task.wait(1.5 + math.random())
        end
    end)

    -- [Anti-AFK]
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
    end)

    -- [Anti-Flag Rare Fish]
    local function spoofInventory()
        local plr = game:GetService("Players").LocalPlayer
        local inv = plr:FindFirstChild("Inventory")
        if inv then
            for _, item in pairs(inv:GetDescendants()) do
                if item:IsA("StringValue") and item.Name:lower():find("fish") then
                    item.Value = "CommonFish"
                end
            end
        end
    end

    task.spawn(function()
        while true do
            pcall(spoofInventory)
            task.wait(1.5)
        end
    end)

    warn("[Bypass] Premium v4.1 Private Stealth+ Extended loaded successfully.")
end)

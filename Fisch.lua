-- Premium Extreme Bypass v3 Final (Auto-Execute Safe)
pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end

    --==[ Metamethod Bypass ]==--
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if tostring(self):lower():find("log") or tostring(self):lower():find("report") or tostring(self):lower():find("exploit") then
            return wait(9e9)
        end
        if method == "Kick" or self.Name == "Kick" then
            return wait(9e9)
        end
        return oldNamecall(self, ...)
    end)

    mt.__index = newcclosure(function(self, key)
        if tostring(key):lower():find("kick") or tostring(key):lower():find("ban") then
            return function() return nil end
        end
        return oldIndex(self, key)
    end)

    setreadonly(mt, true)

    --==[ Function Hooking - Anti Detection ]==--
    for _,v in pairs(getgc(true)) do
        if typeof(v) == "function" and islclosure(v) and not isexecutorclosure(v) then
            local info = debug.getinfo(v)
            if info.name and (info.name:lower():find("ban") or info.name:lower():find("kick") or info.name:lower():find("log") or info.name:lower():find("detect")) then
                hookfunction(v, function(...) return nil end)
            end
        end
    end

    --==[ Anti-AFK + Fake Input ]==--
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    task.spawn(function()
        while true do
            game:GetService("VirtualInputManager"):SendKeyEvent(true, "A", false, game)
            task.wait(0.1)
            game:GetService("VirtualInputManager"):SendKeyEvent(false, "A", false, game)
            task.wait(1.4 + math.random())
        end
    end)

    --==[ Executor Spoofing ]==--
    if setidentity then pcall(function() setidentity(8) end) end

    --==[ DataStore Spoofing ]==--
    local DSS = game:GetService("DataStoreService")
    hookfunction(DSS.GetDataStore, function()
        return setmetatable({}, {
            __index = function() return function() return nil end end,
            __newindex = function() end
        })
    end)

    --==[ Confirmation Log ]==--
    warn("[Bypass] Premium Extreme v3 loaded successfully. You're now protected.")
end)

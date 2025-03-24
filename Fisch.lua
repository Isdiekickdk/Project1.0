-- Bypass Anti-Cheat (Extreme Safe Version)
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    local oldNamecall = mt.__namecall
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

    local oldIndex = mt.__index
    mt.__index = newcclosure(function(self, key)
        if tostring(key):lower():find("kick") then
            return function() return nil end
        end
        return oldIndex(self, key)
    end)

    setreadonly(mt, true)

    for _,v in pairs(getgc(true)) do
        if typeof(v) == "function" and islclosure(v) and not isexecutorclosure(v) then
            local info = debug.getinfo(v)
            if info.name and (info.name:lower():find("kick") or info.name:lower():find("ban") or info.name:lower():find("detect")) then
                hookfunction(v, function() return nil end)
            end
        end
    end

    warn("[Bypass] Safe Extreme Anti-Cheat injected.")
end)

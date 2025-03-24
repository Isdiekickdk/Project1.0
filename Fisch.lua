-- Bypass Anti-Cheat Extreme (Standalone)
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Blokir laporan eksploit ke server
        if tostring(self):lower():find("log") or tostring(self):lower():find("report") then
            return
        end

        if method == "Kick" then
            return warn("Bypassed Kick Attempt")
        end

        return oldNamecall(self, unpack(args))
    end)

    local oldIndex = mt.__index
    mt.__index = newcclosure(function(self, key)
        if tostring(key):lower():find("kick") then
            return function() return nil end
        end
        return oldIndex(self, key)
    end)

    setreadonly(mt, true)

    -- Nonaktifkan LocalScript deteksi cheat
    for _,v in pairs(getgc(true)) do
        if type(v) == "function" and islclosure(v) and not isexecutorclosure(v) then
            local info = getinfo(v)
            if info.name and (info.name:lower():find("kick") or info.name:lower():find("ban")) then
                hookfunction(v, function() return end)
            end
        end
    end

    warn("[Bypass] Extreme Anti-Cheat protection injected.")
end)

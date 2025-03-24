-- Extreme Bypass for Fisch (Standalone, Safe Inject)
pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldnamecall = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Block remote logs or suspicious calls
        if tostring(self):lower():find("log") or tostring(self):lower():find("report") then
            return wait(9e9)
        end

        -- Bypass anti-cheat function calls
        if method == "Kick" or self.Name == "Kick" then
            return wait(9e9)
        end

        return oldnamecall(self, unpack(args))
    end)

    -- Bypass detection functions
    local old; old = hookfunction(checkcaller or isluau, function(...)
        return true
    end)

    -- Dummy environment overwrite
    local fakeEnv = setmetatable({}, {__index = function() return function() end end})
    setfenv(1, setmetatable(getfenv(), {__index = fakeEnv}))

    -- Nil all potential AC scripts
    for _,v in pairs(getgc(true)) do
        if typeof(v) == "function" and islclosure(v) and debug.getinfo(v).name then
            local name = debug.getinfo(v).name:lower()
            if name:find("detect") or name:find("ban") or name:find("kick") then
                hookfunction(v, function() return nil end)
            end
        end
    end
end)

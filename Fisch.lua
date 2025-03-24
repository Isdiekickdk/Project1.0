-- Bypass Anti-Cheat Premium++++++++++ for Fisch (Extreme Safe)
pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end

    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    -- Anti Kick, Anti Log, Anti Report
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if method == "Kick" or tostring(self):lower():find("log") or tostring(self):lower():find("report") then
            warn("[Bypass] Blocked:", method, self)
            return wait(9e9)
        end

        return oldNamecall(self, unpack(args))
    end)

    -- Anti Kick via Index
    local oldIndex = mt.__index
    mt.__index = newcclosure(function(self, key)
        if tostring(key):lower():find("kick") then
            return function() return nil end
        end
        return oldIndex(self, key)
    end)

    -- Disable Dangerous Functions in getgc
    for _,v in pairs(getgc(true)) do
        if typeof(v) == "function" and islclosure(v) and not isexecutorclosure(v) then
            local info = debug.getinfo(v)
            if info.name and (info.name:lower():find("kick") or info.name:lower():find("ban") or info.name:lower():find("detect") or info.name:lower():find("report")) then
                hookfunction(v, function() return nil end)
            end
        end
    end

    -- Neutralize suspicious remotes or modules
    for _,v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            if v.Name:lower():find("report") or v.Name:lower():find("log") or v.Name:lower():find("kick") then
                v:Destroy()
            end
        end
    end

    setreadonly(mt, true)
    warn("[Bypass Premium++++++++++] Injected successfully.")
end)

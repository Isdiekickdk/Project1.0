--[[ Bypass Premium++++++++ for Fisch (Standalone, Auto-Execute Safe) ]]--
pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Blok log, report, suspicious remote
        local n = tostring(self):lower()
        if n:find("log") or n:find("report") or n:find("error") then
            return wait(9e9)
        end

        -- Bypass kick
        if method == "Kick" or self.Name == "Kick" then
            return wait(9e9)
        end

        return oldNamecall(self, unpack(args))
    end)

    -- Amankan __index jika deteksi dari property kick
    local oldIndex = mt.__index
    mt.__index = newcclosure(function(self, key)
        if tostring(key):lower():find("kick") then
            return function() return nil end
        end
        return oldIndex(self, key)
    end)

    setreadonly(mt, true)

    -- Hook semua function lokal yang mencurigakan (ban, kick, detect)
    for _,v in pairs(getgc(true)) do
        if typeof(v) == "function" and islclosure(v) and not isexecutorclosure(v) then
            local info = debug.getinfo(v)
            if info.name and (info.name:lower():find("ban") or info.name:lower():find("kick") or info.name:lower():find("detect")) then
                hookfunction(v, function() return nil end)
            end
        end
    end

    -- Patch environment & fake protection layer
    local fenv = getfenv()
    setfenv(1, setmetatable({}, { __index = function() return function() return nil end end }))
    setfenv(0, fenv)

    warn("[Bypass Fisch Premium++++] Injected and Running")
end)

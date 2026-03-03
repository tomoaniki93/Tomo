-- =====================================
-- Init.lua — Initialization & Slash Commands for TomoCastbar
-- =====================================

local addonName = ...
local mainFrame = CreateFrame("Frame")
local L = TomoCastbar_L

-- =====================================
-- SLASH COMMANDS
-- =====================================

SLASH_TOMOCASTBAR1 = "/tcb"
SLASH_TOMOCASTBAR2 = "/tomocastbar"
SlashCmdList["TOMOCASTBAR"] = function(msg)
    msg = string.lower(msg or "")

    if msg == "reset" then
        TomoCastbar_ResetDatabase()
        TomoCastbar_Module.RefreshAll()
        print("|cffd1b559TomoCastbar|r " .. L["ALL_RESET"])

    elseif msg == "lock" then
        if TomoCastbar_Module and TomoCastbar_Module.ToggleLock then
            TomoCastbar_Module.ToggleLock()
        end

    elseif msg == "reset player" then
        TomoCastbar_ResetUnit("player")
        TomoCastbar_Module.RefreshAll()

    elseif msg == "reset target" then
        TomoCastbar_ResetUnit("target")
        TomoCastbar_Module.RefreshAll()

    elseif msg == "reset focus" then
        TomoCastbar_ResetUnit("focus")
        TomoCastbar_Module.RefreshAll()

    elseif msg == "" or msg == "config" or msg == "options" then
        if TomoCastbar_Config and TomoCastbar_Config.Toggle then
            TomoCastbar_Config.Toggle()
        end

    elseif msg == "help" then
        print("|cffd1b559TomoCastbar|r " .. L["HELP_HEADER"])
        print(L["HELP_CONFIG"])
        print(L["HELP_LOCK"])
        print(L["HELP_RESET"])
        print(L["HELP_RESET_PLAYER"])
        print(L["HELP_RESET_TARGET"])
        print(L["HELP_RESET_FOCUS"])
        print(L["HELP_HELP"])
    else
        print("|cffd1b559TomoCastbar|r " .. L["UNKNOWN_COMMAND"])
    end
end

-- =====================================
-- ADDON_LOADED
-- =====================================

mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:RegisterEvent("PLAYER_LOGIN")

mainFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize saved variables
        TomoCastbar_InitDatabase()

    elseif event == "PLAYER_LOGIN" then
        -- Create castbars after login (all frames available)
        if TomoCastbar_Module and TomoCastbar_Module.Initialize then
            TomoCastbar_Module.Initialize()
        end

        print("|cffd1b559TomoCastbar|r " .. L["ADDON_LOADED"])

        self:UnregisterEvent("ADDON_LOADED")
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)

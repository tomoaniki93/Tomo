-- =====================================
-- Core/Init.lua — Addon Initialization
-- Slash commands: /tgf, /tomogroupframe
-- =====================================

local addonName = ...
local mainFrame = CreateFrame("Frame")
local L = TGF_L

-- =====================================
-- SLASH COMMANDS
-- =====================================

SLASH_TOMOGROUPFRAME1 = "/tgf"
SLASH_TOMOGROUPFRAME2 = "/tomogroupframe"
SlashCmdList["TOMOGROUPFRAME"] = function(msg)
    msg = string.lower(msg or "")

    if msg == "reset" then
        TGF_ResetDatabase()
        ReloadUI()

    elseif msg == "test" or msg == "test party" then
        TGF_PartyFrames.ToggleTestMode()

    elseif msg == "test raid" then
        TGF_RaidFrames.ToggleTestMode()

    elseif msg == "lock" or msg == "unlock" then
        TGF_PartyFrames.ToggleLock()
        TGF_RaidFrames.ToggleLock()

    elseif msg == "party lock" then
        TGF_PartyFrames.ToggleLock()

    elseif msg == "raid lock" then
        TGF_RaidFrames.ToggleLock()

    elseif msg == "help" or msg == "?" then
        print("|cffCC44FFTomo|r|cffFFFFFFGroupFrame|r " .. L["msg_help_title"])
        print("  |cffCC44FF/tgf|r — " .. L["msg_help_open"])
        print("  |cffCC44FF/tgf lock|r — " .. L["msg_help_lock"])
        print("  |cffCC44FF/tgf test|r — " .. L["msg_help_test"])
        print("  |cffCC44FF/tgf test raid|r — Test mode (raid)")
        print("  |cffCC44FF/tgf reset|r — " .. L["msg_help_reset"])
        print("  |cffCC44FF/tgf help|r — " .. L["msg_help_help"])
    else
        -- Default: open config
        if TGF_Config and TGF_Config.Toggle then
            TGF_Config.Toggle()
        end
    end
end

-- =====================================
-- EVENT HANDLERS
-- =====================================

mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:RegisterEvent("PLAYER_LOGIN")
mainFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

mainFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        TGF_InitDatabase()

    elseif event == "PLAYER_LOGIN" then
        if not TomoGroupFrameDB then return end

        -- Initialize profiles
        if TGF_Profiles then
            TGF_Profiles.EnsureProfilesDB()
            TGF_Profiles.InitSpecTracking()
        end

        -- Initialize dispel tracker (needs player class info)
        if TGF_DispelTracker then
            TGF_DispelTracker.UpdatePlayerDispels()
        end

        -- Initialize modules
        if TGF_PartyFrames then TGF_PartyFrames.Initialize() end
        if TGF_RaidFrames then TGF_RaidFrames.Initialize() end

        -- Welcome message
        local r, g, b = TGF_Utils.GetClassColor()
        print("|cffCC44FFTomo|r|cffFFFFFFGroupFrame|r " .. string.format(L["msg_loaded"], TGF_Utils.ColorText("/tgf", r, g, b)))

    elseif event == "PLAYER_SPECIALIZATION_CHANGED" and arg1 == "player" then
        if TGF_Profiles then
            local newSpecID = TGF_Profiles.GetCurrentSpecID()
            local needReload = TGF_Profiles.OnSpecChanged(newSpecID)
            if needReload then
                print("|cffCC44FFTomo|r|cffFFFFFFGroupFrame|r " .. L["msg_spec_changed_reload"])
                C_Timer.After(0.5, function()
                    ReloadUI()
                end)
            end
        end

        -- Re-check dispels on spec change
        if TGF_DispelTracker then
            TGF_DispelTracker.UpdatePlayerDispels()
        end
    end
end)

-- =====================================
-- Init.lua — Initialization & Slash Commands
-- TomoPlates v1.0.0
-- =====================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "TomoPlates" then
        TomoPlates_InitDB()
        print("|cff8b5cf6TomoPlates|r v1.0.0 chargé — |cffaaaaaa/tp|r pour les options.")

    elseif event == "PLAYER_LOGIN" then
        -- Nameplates module initializes on login (CVars + plate frames ready)
        if TomoPlates_NP then
            if TomoPlatesDB.enabled then
                TomoPlates_NP.Enable()
            end
        end
    end
end)

-- =====================================
-- SLASH COMMANDS  /tp  or  /tomoplates
-- =====================================
SLASH_TOMOPLATES1 = "/tomoplates"
SLASH_TOMOPLATES2 = "/tp"

SlashCmdList["TOMOPLATES"] = function(msg)
    msg = strtrim(msg or ""):lower()

    if msg == "" or msg == "config" or msg == "options" then
        TomoPlates_OpenConfig()

    elseif msg == "enable" or msg == "on" then
        TomoPlatesDB.enabled = true
        if TomoPlates_NP then TomoPlates_NP.Enable() end
        print("|cff8b5cf6TomoPlates|r : Activé.")

    elseif msg == "disable" or msg == "off" then
        TomoPlatesDB.enabled = false
        if TomoPlates_NP then TomoPlates_NP.Disable() end
        print("|cff8b5cf6TomoPlates|r : Désactivé.")

    elseif msg == "reset" then
        TomoPlates_ResetDB()

    elseif msg == "reload" or msg == "refresh" then
        if TomoPlates_NP then TomoPlates_NP.RefreshAll() end
        print("|cff8b5cf6TomoPlates|r : Rafraîchi.")

    else
        print("|cff8b5cf6TomoPlates|r commandes :")
        print("  |cffaaaaaa/tp|r                — ouvrir les options")
        print("  |cffaaaaaa/tp enable|r          — activer")
        print("  |cffaaaaaa/tp disable|r         — désactiver")
        print("  |cffaaaaaa/tp reset|r           — réinitialiser les paramètres")
        print("  |cffaaaaaa/tp refresh|r         — rafraîchir toutes les nameplates")
    end
end

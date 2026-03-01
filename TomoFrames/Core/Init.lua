-- =====================================
-- Init.lua — Initialization & Slash Commands
-- TomoFrames v1.0.0
-- =====================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "TomoFrames" then
        TomoFrames_InitDB()
        print("|cfff59e0bTomoFrames|r v1.0.0 chargé — |cffaaaaaa/tf|r pour les options.")

    elseif event == "PLAYER_LOGIN" then
        if TomoFramesDB.enabled then
            if TomoFrames_UF then TomoFrames_UF.Initialize() end
            if TomoFrames_BF then TomoFrames_BF.Initialize() end
        end
    end
end)

-- =====================================
-- SLASH COMMANDS  /tf  or  /tomoframes
-- =====================================
SLASH_TOMOFRAMES1 = "/tomoframes"
SLASH_TOMOFRAMES2 = "/tf"

SlashCmdList["TOMOFRAMES"] = function(msg)
    msg = strtrim(msg or ""):lower()

    if msg == "" or msg == "config" or msg == "options" then
        TomoFrames_OpenConfig()

    elseif msg == "enable" or msg == "on" then
        TomoFramesDB.enabled = true
        if TomoFrames_UF then TomoFrames_UF.Initialize() end
        if TomoFrames_BF then TomoFrames_BF.Initialize() end
        print("|cfff59e0bTomoFrames|r : Activé.")

    elseif msg == "disable" or msg == "off" then
        TomoFramesDB.enabled = false
        if TomoFrames_UF then TomoFrames_UF.Disable() end
        print("|cfff59e0bTomoFrames|r : Désactivé.")

    elseif msg == "lock" then
        if TomoFrames_UF then TomoFrames_UF.Lock() end
        print("|cfff59e0bTomoFrames|r : Frames verrouillées.")

    elseif msg == "unlock" or msg == "sr" then
        if TomoFrames_UF then TomoFrames_UF.Unlock() end
        print("|cfff59e0bTomoFrames|r : Frames déverrouillées — glissez pour repositionner.")

    elseif msg == "reset" then
        TomoFrames_ResetDB()

    elseif msg == "refresh" or msg == "reload" then
        if TomoFrames_UF then TomoFrames_UF.RefreshAll() end
        if TomoFrames_BF then TomoFrames_BF.RefreshAll() end
        print("|cfff59e0bTomoFrames|r : Rafraîchi.")

    else
        print("|cfff59e0bTomoFrames|r commandes :")
        print("  |cffaaaaaa/tf|r             — options")
        print("  |cffaaaaaa/tf enable|r      — activer")
        print("  |cffaaaaaa/tf disable|r     — désactiver")
        print("  |cffaaaaaa/tf unlock|r      — déverrouiller pour déplacer")
        print("  |cffaaaaaa/tf lock|r        — verrouiller")
        print("  |cffaaaaaa/tf reset|r       — réinitialiser les paramètres")
        print("  |cffaaaaaa/tf refresh|r     — rafraîchir les frames")
    end
end

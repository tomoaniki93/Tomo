-- =====================================
-- Init.lua — Initialization & Slash Commands
-- TomoCooldown v1.0.0
-- =====================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "TomoCooldown" then
        TomoCooldown_InitDB()
        print("|cff06b6d4TomoCooldown|r v1.0.0 chargé — |cffaaaaaa/tc|r pour les options.")

    elseif event == "PLAYER_LOGIN" then
        -- ResourceBars initializes itself via PLAYER_ENTERING_WORLD event
        -- CooldownManager initializes itself via PLAYER_ENTERING_WORLD event
        -- SkyRide initializes via its own Initialize() call
        if TomoCooldownDB.skyRide and TomoCooldownDB.skyRide.enabled then
            if TomoCooldown_SR then TomoCooldown_SR.Initialize() end
        end
    end
end)

-- =====================================
-- SLASH COMMANDS  /tc  or  /tomocooldown
-- =====================================
SLASH_TOMOCOOLDOWN1 = "/tomocooldown"
SLASH_TOMOCOOLDOWN2 = "/tc"

SlashCmdList["TOMOCOOLDOWN"] = function(msg)
    msg = strtrim(msg or ""):lower()

    if msg == "" or msg == "config" or msg == "options" then
        TomoCooldown_OpenConfig()

    elseif msg == "unlock" or msg == "sr" then
        if TomoCooldown_RB  and TomoCooldown_RB.ToggleLock  then TomoCooldown_RB.ToggleLock()  end
        if TomoCooldown_SR  and TomoCooldown_SR.ToggleLock  then TomoCooldown_SR.ToggleLock()  end
        print("|cff06b6d4TomoCooldown|r : Frames déverrouillées — glissez pour repositionner.")

    elseif msg == "lock" then
        if TomoCooldown_RB  and TomoCooldown_RB.ToggleLock  then TomoCooldown_RB.ToggleLock()  end
        if TomoCooldown_SR  and TomoCooldown_SR.ToggleLock  then TomoCooldown_SR.ToggleLock()  end
        print("|cff06b6d4TomoCooldown|r : Frames verrouillées.")

    elseif msg == "reset" then
        TomoCooldown_ResetDB()

    elseif msg == "sky" or msg == "skyriding" then
        local db = TomoCooldownDB.skyRide
        db.enabled = not db.enabled
        if db.enabled then
            if TomoCooldown_SR then TomoCooldown_SR.Initialize() end
            print("|cff06b6d4TomoCooldown|r : Skyriding activé.")
        else
            if TomoCooldown_SR then TomoCooldown_SR.SetEnabled(false) end
            print("|cff06b6d4TomoCooldown|r : Skyriding désactivé.")
        end

    else
        print("|cff06b6d4TomoCooldown|r commandes :")
        print("  |cffaaaaaa/tc|r             — options")
        print("  |cffaaaaaa/tc unlock|r      — déverrouiller les barres")
        print("  |cffaaaaaa/tc lock|r        — verrouiller les barres")
        print("  |cffaaaaaa/tc sky|r         — activer/désactiver Skyriding")
        print("  |cffaaaaaa/tc reset|r       — réinitialiser les paramètres")
    end
end

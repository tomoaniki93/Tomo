-- =====================================
-- Init.lua — Initialization & Slash Commands
-- TomoSkins v1.0.0
-- =====================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "TomoSkins" then
        TomoSkins_InitDB()
        print("|cfff43f5eTomoSkins|r v1.0.0 chargé — |cffaaaaaa/ts|r pour les options.")

    elseif event == "PLAYER_LOGIN" then
        local db = TomoSkinsDB

        if db.characterSkin.enabled and TomoSkins_CS then
            TomoSkins_CS.Initialize()
        end
        if db.actionBarSkin.enabled and TomoSkins_ABS then
            TomoSkins_ABS.Initialize()
        end
        if db.minimap.enabled and TomoSkins_MM then
            TomoSkins_MM.ApplySettings()
        end
        if db.infoPanel.enabled and TomoSkins_IP then
            TomoSkins_IP.Initialize()
        end
        if db.objectiveTracker.enabled and TomoSkins_OT then
            TomoSkins_OT.Initialize()
        end
    end
end)

-- =====================================
-- SLASH COMMANDS  /ts  or  /tomoskins
-- =====================================
SLASH_TOMOSKINS1 = "/tomoskins"
SLASH_TOMOSKINS2 = "/ts"

SlashCmdList["TOMOSKINS"] = function(msg)
    msg = strtrim(msg or ""):lower()

    if msg == "" or msg == "config" or msg == "options" then
        TomoSkins_OpenConfig()

    elseif msg == "reset" then
        TomoSkins_ResetDB()

    elseif msg == "refresh" then
        if TomoSkins_CS  then TomoSkins_CS.ApplySettings()  end
        if TomoSkins_ABS then TomoSkins_ABS.ApplySettings() end
        if TomoSkins_MM  then TomoSkins_MM.ApplySettings()  end
        if TomoSkins_IP  then TomoSkins_IP.Update()         end
        if TomoSkins_OT  then TomoSkins_OT.ApplySettings()  end
        print("|cfff43f5eTomoSkins|r : Rafraîchi.")

    else
        print("|cfff43f5eTomoSkins|r commandes :")
        print("  |cffaaaaaa/ts|r           — options")
        print("  |cffaaaaaa/ts refresh|r   — réappliquer tous les skins")
        print("  |cffaaaaaa/ts reset|r     — réinitialiser les paramètres")
    end
end

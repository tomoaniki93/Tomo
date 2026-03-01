-- TomoMail | Database.lua
-- Valeurs par défaut de la base de données sauvegardée

TomoMailDB_Defaults = {
    -- Données globales (partagées entre tous les personnages du compte)
    global = {
        -- Table des alts : "Nom|Royaume|Faction|Niveau|Classe"
        alts = {},
    },

    -- Données par profil (par personnage)
    profile = {
        -- 10 derniers destinataires : "Nom|Royaume|Faction"
        recent = {},

        -- Options
        showAlts        = true,
        showGuild       = true,
        showRecent      = true,
        guildOnlineOnly = false,
        useAutocomplete = true,
        maxRecent       = 10,

        -- Couleurs du thème (cyan TomoMod)
        color = { r = 0, g = 0.8, b = 1 },
    },
}

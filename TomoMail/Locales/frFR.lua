-- TomoMail | Localisation Française
if GetLocale() ~= "frFR" then return end

TomoMailLocale = {
    -- Général
    ADDON_NAME          = "TomoMail",
    CONTACTS            = "Contacts",
    MY_ALTS             = "Mes Personnages",
    GUILD_MEMBERS       = "Membres de Guilde",
    RECENT              = "Récents",
    NO_ALTS             = "Aucun autre personnage enregistré",
    NO_GUILD            = "Vous n'êtes dans aucune guilde",
    NO_GUILD_MEMBERS    = "Aucun membre en ligne",
    NO_RECENT           = "Aucun envoi récent",
    ALL_ALTS            = "Envoyer à tous mes alts",
    ALL_ALTS_CONFIRM    = "Voulez-vous envoyer ce courrier à tous vos alts ?",
    SEND_TO             = "Envoyer à %s",
    SETTINGS            = "Paramètres",
    -- Config
    CFG_TITLE           = "TomoMail — Paramètres",
    CFG_SHOW_ALTS       = "Afficher mes personnages",
    CFG_SHOW_ALTS_TT    = "Affiche vos autres personnages dans le menu déroulant.",
    CFG_SHOW_GUILD      = "Afficher les membres de guilde",
    CFG_SHOW_GUILD_TT   = "Affiche les membres de votre guilde dans le menu déroulant.",
    CFG_SHOW_RECENT     = "Afficher les envois récents",
    CFG_SHOW_RECENT_TT  = "Affiche les 10 derniers destinataires dans le menu déroulant.",
    CFG_MAX_RECENT      = "Nombre d'envois récents",
    CFG_MAX_RECENT_TT   = "Nombre maximum de destinataires récents à mémoriser.",
    CFG_GUILD_ONLINE    = "Membres de guilde en ligne uniquement",
    CFG_GUILD_ONLINE_TT = "N'affiche que les membres de guilde actuellement connectés.",
    CFG_AUTOCOMPLETE    = "Autocomplétion",
    CFG_AUTOCOMPLETE_TT = "Active l'autocomplétion des noms dans le champ Destinataire.",
    -- Notifications
    MAIL_SENT           = "Courrier envoyé à %s !",
    ALT_REGISTERED      = "Personnage enregistré : %s",
    -- QuickSend
    QS_SUBJECT_EMPTY    = "Veuillez entrer un sujet.",
    QS_BODY_EMPTY       = "Veuillez entrer un message.",
    QS_SENDING          = "Envoi en cours à tous les alts... (%d/%d)",
    QS_DONE             = "Courrier envoyé à %d personnage(s) !",
}

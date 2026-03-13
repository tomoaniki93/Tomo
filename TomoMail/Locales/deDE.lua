-- TomoMail | Localisation Allemande
if GetLocale() ~= "deDE" then return end

TomoMailLocale = {
    -- Général
    ADDON_NAME          = "TomoMail",
    CONTACTS            = "Contacts",
    MY_ALTS             = "Meine Twinks",
    GUILD_MEMBERS       = "Gildenmitglieder",
    RECENT              = "Kürzlich",
    NO_ALTS             = "Keine weiteren Charaktere registriert",
    NO_GUILD            = "Du bist in keiner Gilde",
    NO_GUILD_MEMBERS    = "Keine Mitglieder online",
    NO_RECENT           = "Keine kürzlichen Sendungen",
    ALL_ALTS            = "An alle meine Twinks senden",
    ALL_ALTS_CONFIRM    = "Möchten Sie diese Nachricht an alle Ihre Twinks senden?",
    SEND_TO             = "Senden an %s",
    SETTINGS            = "Einstellungen",
    -- Config
    CFG_TITLE           = "TomoMail — Einstellungen",
    CFG_SHOW_ALTS       = "Meine Twinks anzeigen",
    CFG_SHOW_ALTS_TT    = "Zeigt Ihre anderen Charaktere im Dropdown-Menü an.",
    CFG_SHOW_GUILD      = "Gildenmitglieder anzeigen",
    CFG_SHOW_GUILD_TT   = "Zeigt die Mitglieder Ihrer Gilde im Dropdown-Menü an.",
    CFG_SHOW_RECENT     = "Kürzliche Sendungen anzeigen",
    CFG_SHOW_RECENT_TT  = "Zeigt die 10 letzten Empfänger im Dropdown-Menü an.",
    CFG_MAX_RECENT      = "Anzahl der kürzlichen Sendungen",
    CFG_MAX_RECENT_TT   = "Maximale Anzahl der zu merkenden kürzlichen Empfänger.",
    CFG_GUILD_ONLINE    = "Nur online Gildenmitglieder",
    CFG_GUILD_ONLINE_TT = "Zeigt nur die derzeit online Gildenmitglieder an.",
    CFG_AUTOCOMPLETE    = "Autovervollständigung",
    CFG_AUTOCOMPLETE_TT = "Aktiviert die Autovervollständigung der Namen im Empfängerfeld.",
    -- Notifications
    MAIL_SENT           = "Nachricht an %s gesendet!",
    ALT_REGISTERED      = "Charakter registriert: %s",
    -- QuickSend
    QS_SUBJECT_EMPTY    = "Bitte geben Sie einen Betreff ein.",
    QS_BODY_EMPTY       = "Bitte geben Sie eine Nachricht ein.",
    QS_SENDING          = "Sende an alle Twinks... (%d/%d)",
    QS_DONE             = "Nachricht an %d Charakter(e) gesendet!",
}
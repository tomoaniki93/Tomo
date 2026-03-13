-- TomoMail | Localisation Italien
if GetLocale() ~= "itIT" then return end

TomoMailLocale = {
    -- Général
    ADDON_NAME          = "TomoMail",
    CONTACTS            = "Contatti",
    MY_ALTS             = "I miei personaggi",
    GUILD_MEMBERS       = "Membri della gilda",
    RECENT              = "Recenti",
    NO_ALTS             = "Nessun altro personaggio registrato",
    NO_GUILD            = "Non sei in nessuna gilda",
    NO_GUILD_MEMBERS    = "Nessun membro online",
    NO_RECENT           = "Nessun invio recente",
    ALL_ALTS            = "Invia a tutti i miei personaggi",
    ALL_ALTS_CONFIRM    = "Vuoi inviare questa mail a tutti i tuoi personaggi?",
    SEND_TO             = "Invia a %s",
    SETTINGS            = "Impostazioni",
    -- Config
    CFG_TITLE           = "TomoMail — Impostazioni",
    CFG_SHOW_ALTS       = "Mostra i miei personaggi",
    CFG_SHOW_ALTS_TT    = "Mostra gli altri personaggi nel menu a discesa.",
    CFG_SHOW_GUILD      = "Mostra i membri della gilda",
    CFG_SHOW_GUILD_TT   = "Mostra i membri della tua gilda nel menu a discesa.",
    CFG_SHOW_RECENT     = "Mostra gli invii recenti",
    CFG_SHOW_RECENT_TT  = "Mostra gli ultimi 10 destinatari nel menu a discesa.",
    CFG_MAX_RECENT      = "Numero di invii recenti",
    CFG_MAX_RECENT_TT   = "Numero massimo di destinatari recenti da memorizzare.",
    CFG_GUILD_ONLINE    = "Mostra solo i membri della gilda online",
    CFG_GUILD_ONLINE_TT = "Mostra solo i membri della gilda attualmente connessi.",
    CFG_AUTOCOMPLETE    = "Completamento automatico",
    CFG_AUTOCOMPLETE_TT = "Attiva il completamento automatico dei nomi nel campo Destinatario.",
    -- Notifications
    MAIL_SENT           = "Mail inviata a %s !",
    ALT_REGISTERED      = "Personaggio registrato : %s",
    -- QuickSend
    QS_SUBJECT_EMPTY    = "Per favore inserisci un oggetto.",
    QS_BODY_EMPTY       = "Per favore inserisci un messaggio.",
    QS_SENDING          = "Invio in corso a tutti i personaggi... (%d/%d)",
    QS_DONE             = "Mail inviata a %d personaggio(i) !",
}
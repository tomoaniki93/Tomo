-- TomoMail | Localisation Espagnole
if GetLocale() ~= "esES" then return end

TomoMailLocale = {
    -- Général
    ADDON_NAME          = "TomoMail",
    CONTACTS            = "Contactos",
    MY_ALTS             = "Mis Personajes",
    GUILD_MEMBERS       = "Miembros de la Hermandad",
    RECENT              = "Recientes",
    NO_ALTS             = "No hay otros personajes registrados",
    NO_GUILD            = "No estás en ninguna hermandad",
    NO_GUILD_MEMBERS    = "No hay miembros en línea",
    NO_RECENT           = "No hay envíos recientes",
    ALL_ALTS            = "Enviar a todos mis personajes",
    ALL_ALTS_CONFIRM    = "¿Deseas enviar este correo a todos tus personajes?",
    SEND_TO             = "Enviar a %s",
    SETTINGS            = "Configuración",
    -- Config
    CFG_TITLE           = "TomoMail — Configuración",
    CFG_SHOW_ALTS       = "Mostrar mis personajes",
    CFG_SHOW_ALTS_TT    = "Muestra tus otros personajes en el menú desplegable.",
    CFG_SHOW_GUILD      = "Mostrar miembros de la hermandad",
    CFG_SHOW_GUILD_TT   = "Muestra los miembros de tu hermandad en el menú desplegable.",
    CFG_SHOW_RECENT     = "Mostrar envíos recientes",
    CFG_SHOW_RECENT_TT  = "Muestra los 10 últimos destinatarios en el menú desplegable.",
    CFG_MAX_RECENT      = "Número de envíos recientes",
    CFG_MAX_RECENT_TT   = "Número máximo de destinatarios recientes a recordar.",
    CFG_GUILD_ONLINE    = "Solo miembros de la hermandad en línea",
    CFG_GUILD_ONLINE_TT = "Muestra solo los miembros de la hermandad que están actualmente en línea.",
    CFG_AUTOCOMPLETE    = "Autocompletado",
    CFG_AUTOCOMPLETE_TT = "Activa el autocompletado de nombres en el campo Destinatario.",
    -- Notifications
    MAIL_SENT           = "Correo enviado a %s !",
    ALT_REGISTERED      = "Personaje registrado : %s",
    -- QuickSend
    QS_SUBJECT_EMPTY    = "Por favor, ingresa un asunto.",
    QS_BODY_EMPTY       = "Por favor, ingresa un mensaje.",
    QS_SENDING          = "Enviando a todos los personajes... (%d/%d)",
    QS_DONE             = "Correo enviado a %d personaje(s) !",
}
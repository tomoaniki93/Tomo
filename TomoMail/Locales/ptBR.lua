-- TomoMail | Localização Portuguesa (Brasil)
if GetLocale() ~= "ptBR" then return end

TomoMailLocale = {
    -- Geral
    ADDON_NAME          = "TomoMail",
    CONTACTS            = "Contatos",
    MY_ALTS             = "Meus Personagens",
    GUILD_MEMBERS       = "Membros da Guilda",
    RECENT              = "Recentes",
    NO_ALTS             = "Nenhum outro personagem registrado",
    NO_GUILD            = "Você não está em nenhuma guilda",
    NO_GUILD_MEMBERS    = "Nenhum membro online",
    NO_RECENT           = "Nenhum envio recente",
    ALL_ALTS            = "Enviar para todos os alts",
    ALL_ALTS_CONFIRM    = "Deseja enviar este correio para todos os seus alts?",
    SEND_TO             = "Enviar para %s",
    SETTINGS            = "Configurações",
    -- Config
    CFG_TITLE           = "TomoMail — Configurações",
    CFG_SHOW_ALTS       = "Mostrar meus personagens",
    CFG_SHOW_ALTS_TT    = "Exibe seus outros personagens no menu suspenso.",
    CFG_SHOW_GUILD      = "Mostrar membros da guilda",
    CFG_SHOW_GUILD_TT   = "Exibe os membros da sua guilda no menu suspenso.",
    CFG_SHOW_RECENT     = "Mostrar envios recentes",
    CFG_SHOW_RECENT_TT  = "Exibe os 10 últimos destinatários no menu suspenso.",
    CFG_MAX_RECENT      = "Número de envios recentes",
    CFG_MAX_RECENT_TT   = "Número máximo de destinatários recentes a memorizar.",
    CFG_GUILD_ONLINE    = "Apenas membros da guilda online",
    CFG_GUILD_ONLINE_TT = "Exibe apenas os membros da guilda atualmente conectados.",
    CFG_AUTOCOMPLETE    = "Autocompletar",
    CFG_AUTOCOMPLETE_TT = "Ativa o autocompletar de nomes no campo Destinatário.",
    -- Notificações
    MAIL_SENT           = "Correio enviado para %s!",
    ALT_REGISTERED      = "Personagem registrado: %s",
    -- QuickSend
    QS_SUBJECT_EMPTY    = "Por favor, insira um assunto.",
    QS_BODY_EMPTY       = "Por favor, insira uma mensagem.",
    QS_SENDING          = "Enviando para todos os alts... (%d/%d)",
    QS_DONE             = "Correio enviado para %d personagem(ns)!",
}

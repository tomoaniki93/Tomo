-- TomoMail | Modules/QuickSend.lua
-- Autocomplétion des noms d'alts et de membres de guilde

local TM = TomoMail
local QuickSend = {}
TM:RegisterModule("QuickSend", QuickSend)

-- ============================================================
--  Variables locales
-- ============================================================

local cachedNames   = nil   -- cache de tous les noms connus
local lastCacheTime = 0
local CACHE_TTL     = 5     -- secondes avant de reconstruire le cache

-- ============================================================
--  Construction du cache de noms
-- ============================================================

local function BuildNameCache()
    cachedNames = {}
    local realm   = GetRealmName()
    local faction = UnitFactionGroup("player")
    local player  = UnitName("player")

    -- Alts
    local alts = TM.db.global.alts
    for _, entry in ipairs(alts) do
        local p, r, f = strsplit("|", entry)
        if r == realm and f == faction and p ~= player then
            cachedNames[p:lower()] = p
        end
    end

    -- Membres de guilde
    if IsInGuild() then
        local numMembers = GetNumGuildMembers()
        for i = 1, numMembers do
            local name = GetGuildRosterInfo(i)
            if name then
                local shortName = strsplit("-", name)
                if shortName ~= player then
                    cachedNames[shortName:lower()] = shortName
                end
            end
        end
    end

    lastCacheTime = GetTime()
end

local function GetNameCache()
    if not cachedNames or (GetTime() - lastCacheTime) > CACHE_TTL then
        BuildNameCache()
    end
    return cachedNames
end

-- ============================================================
--  Initialisation
-- ============================================================

function QuickSend:OnInitialize()
    -- Rien à faire avant l'ouverture de la boite
end

function QuickSend:OnMailShow()
    if TM.db.profile.useAutocomplete then
        self:EnableAutocomplete()
    end
    -- Invalide le cache à l'ouverture
    cachedNames = nil
end

function QuickSend:OnMailHide()
    self:DisableAutocomplete()
end

function QuickSend:EnableAutocomplete()
    if self._hooked then return end
    self._hooked = true

    -- Hook sur chaque frappe dans le champ destinataire
    SendMailNameEditBox:HookScript("OnTextChanged", function(editbox, userInput)
        if not userInput then return end
        QuickSend:OnRecipientChanged(editbox)
    end)

    -- Suggestion au focus
    SendMailNameEditBox:HookScript("OnEditFocusGained", function(editbox)
        QuickSend:OnRecipientChanged(editbox)
    end)
end

function QuickSend:DisableAutocomplete()
    -- Les hooks HookScript ne peuvent pas être retirés facilement;
    -- on désactive via un flag
    self._autocompleteEnabled = false
end

-- ============================================================
--  Logique d'autocomplétion
-- ============================================================

local suggestionFrame = nil
local suggestionButtons = {}
local MAX_SUGGESTIONS = 8

local function GetOrCreateSuggestionFrame()
    if suggestionFrame then return suggestionFrame end

    suggestionFrame = CreateFrame("Frame", "TomoMailSuggestions", UIParent, "BackdropTemplate")
    suggestionFrame:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    suggestionFrame:SetBackdropBorderColor(1, 0.8, 0, 0.9)
    suggestionFrame:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
    suggestionFrame:SetFrameStrata("TOOLTIP")
    suggestionFrame:Hide()

    -- Ferme au clic en dehors
    suggestionFrame:EnableMouse(true)

    for i = 1, MAX_SUGGESTIONS do
        local btn = CreateFrame("Button", nil, suggestionFrame)
        btn:SetHeight(20)
        btn:SetPoint("TOPLEFT", suggestionFrame, "TOPLEFT", 6, -4 - (i-1)*20)
        btn:SetPoint("TOPRIGHT", suggestionFrame, "TOPRIGHT", -6, -4 - (i-1)*20)

        local hl = btn:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(1, 0.8, 0, 0.15)

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", btn, "LEFT", 4, 0)
        text:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
        text:SetJustifyH("LEFT")
        btn.text = text

        btn:SetScript("OnClick", function(self)
            local name = self.suggestName
            if name then
                SendMailNameEditBox:SetText(name)
                SendMailNameEditBox:SetCursorPosition(#name)
                suggestionFrame:Hide()
            end
        end)
        btn:Hide()

        suggestionButtons[i] = btn
    end

    return suggestionFrame
end

function QuickSend:OnRecipientChanged(editbox)
    if not TM.db.profile.useAutocomplete then return end
    if self._autocompleteEnabled == false then return end

    local text = editbox:GetText()
    if not text or #text < 2 then
        local sf = GetOrCreateSuggestionFrame()
        sf:Hide()
        return
    end

    local lower   = text:lower()
    local cache   = GetNameCache()
    local matches = {}

    for k, v in pairs(cache) do
        if k:sub(1, #lower) == lower and v:lower() ~= lower then
            table.insert(matches, v)
            if #matches >= MAX_SUGGESTIONS then break end
        end
    end
    table.sort(matches)

    local sf = GetOrCreateSuggestionFrame()

    if #matches == 0 then
        sf:Hide()
        return
    end

    -- Positionne sous le champ
    sf:ClearAllPoints()
    sf:SetPoint("TOPLEFT", editbox, "BOTTOMLEFT", 0, -2)
    sf:SetWidth(editbox:GetWidth())
    sf:SetHeight(#matches * 20 + 8)

    for i, btn in ipairs(suggestionButtons) do
        if matches[i] then
            btn.text:SetText(matches[i])
            btn.suggestName = matches[i]
            btn:Show()
        else
            btn.suggestName = nil
            btn:Hide()
        end
    end
    sf:Show()
end

-- Ferme la suggestion si on appuie sur Entrée ou Escape dans le champ
hooksecurefunc("SendMailFrame_SendMail", function()
    if suggestionFrame then suggestionFrame:Hide() end
end)

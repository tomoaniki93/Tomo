-- =====================================
-- Minimap.lua
-- =====================================

TomoSkins_MM = {}
local minimapBorder

-- Masquer la forme ronde et rendre carré
function TomoSkins_MM.MakeSquare()
    Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
    Minimap:SetArchBlobRingScalar(0)
    Minimap:SetQuestBlobRingScalar(0)
    Minimap:SetSize(TomoSkinsDB.minimap.size, TomoSkinsDB.minimap.size)
    
    -- Cache les éléments ronds de Blizzard
    local framesToHide = {
        MinimapBorder,
        MinimapBorderTop,
        MinimapZoomIn,
        MinimapZoomOut,
        MiniMapTracking,
        MiniMapWorldMapButton,
        MinimapCompassTexture,
    }
    
    for _, frame in pairs(framesToHide) do
        if frame then
            frame:Hide()
            frame:SetAlpha(0)
            frame:EnableMouse(false)
        end
    end
    
    -- Sécurité supplémentaire
    if MinimapBorder then MinimapBorder:Hide() end
    if MinimapBorderTop then MinimapBorderTop:Hide() end
    if MinimapZoomIn then MinimapZoomIn:Hide() end
    if MinimapZoomOut then MinimapZoomOut:Hide() end
    
    Minimap:SetClampedToScreen(true)
end

-- Créer la bordure personnalisée
function TomoSkins_MM.CreateBorder()
    if not minimapBorder then
        minimapBorder = CreateFrame("Frame", "TomoModMinimapBorder", Minimap, "BackdropTemplate")
        minimapBorder:SetAllPoints(Minimap)
        minimapBorder:SetFrameLevel(Minimap:GetFrameLevel() + 1)
    end
    
    local r, g, b, a = 0, 0, 0, 1
    if TomoSkinsDB.minimap.borderColor == "class" then
        r, g, b, a = TomoSkins_Utils.GetClassColor()
    end
    
    minimapBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 2,
    })
    minimapBorder:SetBackdropBorderColor(r, g, b, a)

    -- Sync InfoPanel bars border color
    if TomoSkins_IP and TomoSkins_IP.UpdateAppearance then
        TomoSkins_IP.UpdateAppearance()
    end
end

-- Appliquer le scale
function TomoSkins_MM.ApplyScale()
    Minimap:SetScale(TomoSkinsDB.minimap.scale)
end

-- Rendre compatible avec Edit Mode
function TomoSkins_MM.SetupEditMode()
    if EditModeManagerFrame then
        Minimap:SetMovable(true)
        Minimap:SetUserPlaced(true)
        Minimap:SetClampedToScreen(true)
    end
end

-- Appliquer tous les paramètres
function TomoSkins_MM.ApplySettings()
    if not TomoSkinsDB.minimap.enabled then return end
    
    TomoSkins_MM.MakeSquare()
    TomoSkins_MM.CreateBorder()
    TomoSkins_MM.ApplyScale()
    TomoSkins_MM.SetupEditMode()
end

-- Initialisation du module
function TomoSkins_MM.Initialize()
    C_Timer.After(0.5, function()
        TomoSkins_MM.ApplySettings()
    end)
end
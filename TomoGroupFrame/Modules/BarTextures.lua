-- =====================================
-- Modules/BarTextures.lua
-- Bar texture helpers & StatusBar setup
-- =====================================

TGF_Bar = {}

function TGF_Bar.SetTexture(statusBar, textureKey)
    local path = TGF_GetBarTexturePath(textureKey or "Gradient")
    statusBar:SetStatusBarTexture(path)
    statusBar:GetStatusBarTexture():SetHorizTile(false)
    statusBar:GetStatusBarTexture():SetVertTile(false)
end

function TGF_Bar.SetBackgroundTexture(texture)
    local bgPath = TGF_GetBarTexturePath("Flat")
    texture:SetTexture(bgPath)
    texture:SetVertexColor(0.08, 0.08, 0.10, 0.85)
end

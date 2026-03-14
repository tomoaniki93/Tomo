-- =====================================
-- Locales/Localization.lua
-- Localization system for TomoGroupFrame
-- =====================================

TGF_L = setmetatable({}, {
    __index = function(t, key)
        return key
    end,
})

---@class Graphite.Theme
---@field normalColor Graphite.Color
---@field normalBgColor Graphite.Color
---@field normalMargin number
---@field normalFontSize number
---@field borderColor Graphite.Color
---@field borderThickness number
Theme = {}
Theme.__index = Theme

---@param normalColor Graphite.Color
---@param normalBgColor Graphite.Color
---@param normalMargin number
---@param normalFontSize number
---@param borderColor Graphite.Color
---@param borderThickness number
---@return Graphite.Theme
function Theme:new(normalColor, normalBgColor, normalMargin, normalFontSize, borderColor, borderThickness)
    return setmetatable({
        normalColor = normalColor,
        normalBgColor = normalBgColor,
        normalMargin = normalMargin,
        normalFontSize = normalFontSize,
        borderColor = borderColor,
        borderThickness = borderThickness,
    }, self)
end

---@param newProps Graphite.Theme
---@return Graphite.Theme
function Theme:copyWith(newProps)
    local t = {}

    for k, v in pairs(self) do
        t[k] = v
    end

    for k, v in pairs(newProps) do
        t[k] = v
    end

    return t
end

---@param newProps Graphite.Theme
function Theme:modifyTo(newProps)
    for k, v in pairs(newProps) do
        self[k] = v
    end
end
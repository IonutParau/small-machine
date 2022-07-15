---@class Graphite.Color
---@field r number
---@field g number
---@field b number
---@field a number
Color = {}
Color.__index = Color

function Color:new(r, g, b, a)
    return setmetatable({r=r,g=g,b=b,a=a},self)
end

function Color:apply()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setColor(self.r or 0, self.g or 0, self.b or 0, self.a or 1)
end
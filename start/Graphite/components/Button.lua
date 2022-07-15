---@class Graphite.Button
---@field x number
---@field y number
---@field width number
---@field height number
---@field callback function
---@field image string
---@field align Graphite.Align
---@field title string
---@field description string
---@field enabled function
---@field theme Graphite.Theme
Button = {}
Button.__index = Button

---@type Graphite.Button|nil
Graphite.hoveredButton = nil

---@param x number
---@param y number
---@param width number
---@param height number
---@param callback function
---@param image string
---@param align Graphite.Align
---@param title string
---@param description string
---@param enabled function
---@param theme Graphite.Theme
function Button:new(x, y, width, height, callback, image, align, title, description, enabled, theme)
    TextureManager:Cache(image, image)
    
    return setmetatable({
        x = x,
        y = y,
        width = width,
        height = height,
        callback = callback,
        image = image,
        align = align,
        title = title,
        description = description,
        enabled = enabled,
        theme = theme,
    }, self)
end

function Button:isHovered(x, y)
    local px, py = Graphite.ParseAlignment(self.x, self.y, self.align)

    
    local w, h = self.width, self.height
    
    px = px - w/2
    py = py - h/2

    if x >= px and x <= px+self.width and y >= py and y <= py+self.height then return true else return false end
end

function Button:draw()
    if not self.enabled() then return end
    
    local x, y = Graphite.ParseAlignment(self.x, self.y, self.align)
    local img, size = TextureManager:ImageFromCache(self.image), TextureManager:SizeFromCache(self.image)
    if not self:isHovered(love.mouse.getX(), love.mouse.getY()) then love.graphics.setColor(1, 1, 1, 0.5) end

    love.graphics.draw(img, x, y, 0, self.width/size.w, self.height/size.h, size.w2, size.h2)
    love.graphics.setColor(1, 1, 1, 1)

    if self:isHovered(love.mouse.getX(), love.mouse.getY()) then
        Graphite.hoveredButton = self
    end
end

function Button:click(x, y, button, istouch, presses)
    if self.enabled() and self:isHovered(x, y) then
        Graphite.PlaceCells = false
        self.callback(button)
    end
end
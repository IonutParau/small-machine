---@diagnostic disable: need-check-nil
---@alias Graphite.Align "topleft"|"topcenter"|"topright"|"centerleft"|"center"|"centerright"|"bottomleft"|"bottomcenter"|"bottomright"

---@param x number
---@param y number
---@param alignment Graphite.Align
function Graphite.ParseAlignment(x, y, alignment)
    local w, h = love.graphics.getDimensions()

    if alignment == "topleft" then return x, y end
    if alignment == "topcenter" then return x+w/2, y end
    if alignment == "topright" then return w-x, y end
    if alignment == "centerleft" then return x, y+h/2 end
    if alignment == "center" then return x+w/2, y+h/2 end
    if alignment == "centerright" then return w-x, y+h/2 end
    if alignment == "bottomleft" then return x, h-y end
    if alignment == "bottomcenter" then return x+w/2, h-y end
    if alignment == "bottomright" then return w-x, h-y end
end

---@param x number
---@param y number
---@param title string
---@param description string
---@param theme Graphite.Theme
function Graphite.RenderInfoBox(x, y, title, description, theme)
    -- Get the variables needed and the MATH
    local font = love.graphics.getFont()

    local charWidth = font:getWidth("a") * theme.normalFontSize
    local charHeight = font:getHeight() * theme.normalFontSize

    local maxCharCount = math.max(math.min(#title, #description), 14)
    
    local titleFraction = 1.2

    local titleWidth = maxCharCount*charWidth*titleFraction
    
    local descHeight = charHeight * (math.ceil(font:getWidth(description) / titleWidth)+0.5) * theme.normalFontSize

    local boxWidth = titleWidth
    local boxHeight = charHeight*titleFraction+descHeight+20
    
    local margin = 10

    x = math.min(x, love.graphics.getWidth()-boxWidth-margin*2)
    y = math.min(y, love.graphics.getHeight()-boxHeight-margin*2)

    local borderX = x-theme.borderThickness/2-margin
    local borderY = y-theme.borderThickness/2-margin
    local borderEndX = x+boxWidth+theme.borderThickness/2+margin
    local borderEndY = y+boxHeight+theme.borderThickness/2+margin
    
    -- Draw border
    
    local borderVert = {borderX, borderY, borderEndX, borderY, borderEndX, borderEndY, borderX, borderEndY}
    theme.borderColor:apply()
    love.graphics.setLineWidth(theme.borderThickness)
    love.graphics.polygon("line", borderVert)
    love.graphics.setLineWidth(1)

    -- Draw normal background
    theme.normalBgColor:apply()
    love.graphics.rectangle("fill", x-margin, y-margin, boxWidth+margin*2, boxHeight+margin*2)
    
    -- Draw text
    theme.normalColor:apply()
    love.graphics.print(title, x, y, 0, theme.normalFontSize*titleFraction, theme.normalFontSize*titleFraction)
    love.graphics.printf(description, x, y+charHeight+20, boxWidth/theme.normalFontSize, nil, 0, theme.normalFontSize, theme.normalFontSize)

    -- Reset
    love.graphics.setColor(1, 1, 1, 1)
end

---@alias Graphite.RenderData {texture: string?, title: string?, description: string?, theme: Graphite.Theme?}

---@type table<Graphite.RenderData>
Graphite.renderData = {}

---@param id string
---@param renderData Graphite.RenderData
function Graphite.BindRenderData(id, renderData)
    Graphite.renderData[id] = renderData
end

---@param id string
---@return Graphite.RenderData
function Graphite.GetRenderData(id)
    return Graphite.renderData[id]
end

---@param x number
---@param y number
---@param cell Cell
---@return boolean
function Graphite.PlaceCell(x, y, cell)
    if not Graphite.PlaceCells then return false end

    ---@type Cell
    local was = table.copy(Grid:at(x, y))

    local config = GetCellConfig(cell.id)

    if type(config.canPlace) == "function" then
        if not config.canPlace(x, y, cell, was) then return false end
    end

    local c = table.copy(cell)
    Grid:set(x, y, c)

    if type(config.whenPlaced) == "function" then
        local r = config.whenPlaced(x, y, c, was)
        if type(r) == "boolean" then return r end
        return true
    end

    return true
end

---@param x number
---@param y number
---@return number, number
function Graphite.CellToScreen(x, y)
    local offX, offY = love.graphics.getWidth()/2, love.graphics.getHeight()/2

    return (x * Graphite.Camera.zoom * Graphite.Camera.cellSize + offX + Graphite.Camera.x), (y * Graphite.Camera.zoom * Graphite.Camera.cellSize + offY + Graphite.Camera.y)
end

---@param x number
---@param y number
---@return number, number
function Graphite.ScreenToCell(x, y)
    local offX, offY = love.graphics.getWidth()/2, love.graphics.getHeight()/2

    local dx, dy = x - offX, y - offY

    dx = dx - Graphite.Camera.x + Graphite.Camera.cellSize/2
    dy = dy - Graphite.Camera.y + Graphite.Camera.cellSize/2

    dx = dx / Graphite.Camera.zoom / Graphite.Camera.cellSize
    dy = dy / Graphite.Camera.zoom / Graphite.Camera.cellSize

    return math.floor(dx), math.floor(dy)
end

---@param x number
---@param y number
---@param cell Cell?
function Graphite.DrawBackground(x, y, cell)
    if cell == nil then cell = Grid:getBackground(x, y) end

    RunCallback("pre-back-render", x, y, cell)

    local px, py = Graphite.CellToScreen(x, y)
    px = px
    py = py
    local renderInfo = Graphite.GetRenderData(cell.id)
    local img = TextureManager:Load(renderInfo.texture)
    love.graphics.draw(img, px, py, cell.rot * math.pi/2, Graphite.Camera.cellSize/img:getWidth()*Graphite.Camera.zoom, Graphite.Camera.cellSize/img:getHeight()*Graphite.Camera.zoom, img:getWidth()/2, img:getHeight()/2)

    RunCallback("post-back-render", x, y, cell)
end

---@param x number
---@param y number
---@param cell Cell?
function Graphite.DrawCell(x, y, cell)
    if cell == nil then cell = Grid:at(x, y) end

    RunCallback("pre-cell-render", x, y, cell)

    local px, py = Graphite.CellToScreen(x, y)
    px = px
    py = py
    local renderInfo = Graphite.GetRenderData(cell.id)
    local img = TextureManager:Load(renderInfo.texture)
    love.graphics.draw(img, px, py, cell.rot * math.pi/2, Graphite.Camera.cellSize/img:getWidth()*Graphite.Camera.zoom, Graphite.Camera.cellSize/img:getHeight()*Graphite.Camera.zoom, img:getWidth()/2, img:getHeight()/2)

    RunCallback("post-cell-render", x, y, cell)
end
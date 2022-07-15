local DefaultEnvironment = {}

local cellbar = {}

function DefaultEnvironment:CreateCellButton(i, id)
    local conf = Graphite.GetRenderData(id) or GetCellConfig(id)

    local title = conf.title or "Unnamed"
    local description = conf.description or "No description available"
    local theme = Graphite.StandardTheme:copyWith(conf.theme or {})
    local texture = conf.texture or "start/Graphite/images/base.png"

    local btn = Button:new(70 * i, 70, 50, 50, function()
        Graphite.Selected.id = id
    end, texture, "bottomleft", title, description, function() return true end, theme)

    table.insert(cellbar, btn)

    table.insert(Graphite.MainNavigator.routes.game, btn)
end

function DefaultEnvironment:init()
    for i = 1, #Cells do
        DefaultEnvironment:CreateCellButton(i, Cells[i])
    end
    print(#Cells)
end

function DefaultEnvironment:draw()
    local minx, miny = Graphite.ScreenToCell(0, 0)
    local maxx, maxy = Graphite.ScreenToCell(love.graphics.getDimensions())

    for x = minx - 1, maxx + 1 do
        for y = miny - 1, maxy + 1 do
            Graphite.DrawBackground(x, y)
        end
    end
    for x = minx - 1, maxx + 1 do
        for y = miny - 1, maxy + 1 do
            Graphite.DrawCell(x, y)
        end
    end

    local cx, cy = Graphite.ScreenToCell(love.mouse.getX(), love.mouse.getY())

    local cellToPlace = Cell(Graphite.Selected.id, Graphite.Selected.rot, {})
    love.graphics.setColor(1, 1, 1, 0.5)
    Graphite.DrawCell(cx, cy, cellToPlace)
    if love.mouse.isDown(1) then
        Graphite.PlaceCell(cx, cy, cellToPlace)
    end
    if love.mouse.isDown(2) then
        Graphite.PlaceCell(cx, cy, Cell("empty", 0, {}))
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function DefaultEnvironment:update(dt)
    local speed = 10

    if love.keyboard.isDown("lshift") then
        speed = speed * 2
    end

    if love.keyboard.isDown("w") then
        Graphite.Camera.y = Graphite.Camera.y + speed
    end
    if love.keyboard.isDown("s") then
        Graphite.Camera.y = Graphite.Camera.y - speed
    end
    if love.keyboard.isDown("a") then
        Graphite.Camera.x = Graphite.Camera.x + speed
    end
    if love.keyboard.isDown("d") then
        Graphite.Camera.x = Graphite.Camera.x - speed
    end
end

function DefaultEnvironment:scroll(dx, dy)
    if dy < 0 then
        Graphite.Camera.zoom = Graphite.Camera.zoom / 2
        Graphite.Camera.x = Graphite.Camera.x / 2
        Graphite.Camera.y = Graphite.Camera.y / 2
    elseif dy > 0 then
        Graphite.Camera.zoom = Graphite.Camera.zoom * 2
        Graphite.Camera.x = Graphite.Camera.x * 2
        Graphite.Camera.y = Graphite.Camera.y * 2
    end
end

function DefaultEnvironment:applySelectionRotation()
    for i = 1, #cellbar do
        local btn = cellbar[i]
        btn.rotation = Graphite.Selected.rot * math.pi / 2
    end
end

function DefaultEnvironment:keypressed(key, code, continous)
    if key == "q" then
        Graphite.Selected.rot = (Graphite.Selected.rot - 1) % 4
        self:applySelectionRotation()
    end
    if key == "e" then
        Graphite.Selected.rot = (Graphite.Selected.rot + 1) % 4
        self:applySelectionRotation()
    end
end

function DefaultEnvironment:keyreleased(key, code, continous)

end

return DefaultEnvironment

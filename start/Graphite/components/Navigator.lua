---@class Navigator
---@field routes table
---@field route string
Navigator = {}
Navigator.__index = Navigator

---@param routes table
---@param route string
function Navigator:new(routes, route)
    return setmetatable({routes = routes, route = route}, self)
end

function Navigator:draw()
    for _, c in ipairs(self.routes[self.route]) do
        if c.draw then c:draw() end     
    end
end

function Navigator:update(dt)
    for _, c in ipairs(self.routes[self.route]) do
        if c.draw then c:update(dt) end     
    end
end

function Navigator:click(x, y, button, istouch, presses)
    for _, c in ipairs(self.routes[self.route]) do
        if c.click then c:click(x, y, button, istouch, presses) end     
    end
end

function Navigator:typec(key)
    for _, c in ipairs(self.routes[self.route]) do
        if c.draw then c:typec(key) end
    end
end

function Navigator:navigate(route)
    self.route = route
end
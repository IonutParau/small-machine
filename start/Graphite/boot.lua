-- Pre-requirements

-- Graphite API as a table
Graphite = {}

-- This function is from Love2D UI, thus making this entire package based on Love2D UI lol
local function BootAsUI()
    print("Launching with Love2D...")
    if (not os.execute("love .")) and IsWindows then
        os.execute("\"C:\\Program Files\\LOVE\\love.exe\" .")
    end
    os.exit()
end

CreateQueue("love2d-init")
NewCallback("love2d-update")
NewCallback("love2d-draw")

ToggleShell()

if love then
    require("start.Graphite.components.Low")
    require("start.Graphite.components.Navigator")
    require("start.Graphite.components.Button")
    require("start.Graphite.components.Field")
    require("start.Graphite.src.color")
    require("start.Graphite.src.tex")
    require("start.Graphite.src.theme")
    require("start.Graphite.src.utility")
    require("start.Graphite.src.cell_integration")
else
    local runUI = true
    for _, param in ipairs(arg) do
        if param == "--ui" then runUI = true elseif param == "--no-ui" then runUI = false end
    end
    if runUI then BootAsUI() end
end

Graphite.StandardTheme = Theme:new(
    Color:new(1, 1, 1, 1),
    Color:new(0.5, 0.5, 0.5, 0.5),
    10,
    1,
    Color:new(0.1, 0.1, 0.1, 0.3),
    15
)

Graphite.PlaceCells = true

---@alias Graphite.Selection {id: string, rot: number, data: table}

---@type Graphite.Selection
Graphite.Selected = {
    id = "mover",
    rot = 0,
    data = {},
}

---@alias Graphite.Camera {x: number, y: number, zoom: number}

---@type Graphite.Camera
Graphite.Camera = {
    x = 0,
    y = 0,
    zoom = 1,
    cellSize = 64,
}

Graphite.Title = "ModularCM (Graphite)"
Graphite.Icon = "logo.png"

local standardBackBtn = Button:new(40, 40, 50, 50, function() Graphite.MainNavigator:navigate("main") end, "start/Graphite/images/back.png", "topleft", "Back", "Back to the main menu", function() return true end, Graphite.StandardTheme)

Graphite.MainNavigator = Navigator:new({
    main = {
        Button:new(-50, 0, 50, 50, function() Graphite.MainNavigator:navigate("play_finite") end, "start/Graphite/images/mover.png", "center", "Play Finite Mode", "Sends you to a grid size selector", function() return true end, Graphite.StandardTheme),
        Button:new(50, 0, 50, 50, function()
            Grid = DynamicGrid()
            InitialGrid = Grid:copy()
            Graphite.MainNavigator:navigate("game")
        end, "start/Graphite/images/push.png", "center", "Play Infinite Mode", "Sends you to a infinite grid", function() return true end, Graphite.StandardTheme)
    },
    play_finite = {
        standardBackBtn,
    },
    game = {
        standardBackBtn,
    },
}, "main")

love.graphics.setFont(love.graphics.newFont("start/Graphite/nokiafc22.ttf"))

local environment = require("start.Graphite.src.cell_environment")

---@alias Graphite.Environment {init: function, draw: function, update: function, mousepressed: function, mousereleased: function, scroll: function}

---@param newEnvironment Graphite.Environment
function Graphite.SetCellEnvironment(newEnvironment)
    environment = newEnvironment
end

-- Boot
for i=1,#ModularCM.packages do
    Depend(ModularCM.packages[i])
end

-- Callbacks

function love.load()
    love.window.setIcon(type(Graphite.Icon) == "string" and love.image.newImageData(Graphite.Icon) or Graphite.Icon)
    love.window.setTitle(Graphite.Title)
    love.window.setMode(800, 600, {resizable = true})
    RunQueue("love2d-init")
    environment:init()
end

function love.draw()
    Graphite.hoveredButton = nil
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", 1, 1, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
    if Graphite.MainNavigator.route == "game" then
       environment:draw()
    end
    Graphite.MainNavigator:draw()
    if Graphite.hoveredButton then
        Graphite.RenderInfoBox(love.mouse.getX(), love.mouse.getY(), Graphite.hoveredButton.title, Graphite.hoveredButton.description, Graphite.hoveredButton.theme)
    end
    RunCallback("love2d-draw")
end

function love.update(dt)
    if Graphite.MainNavigator.route == "game" then
        environment:update(dt)
    end
end

function love.mousepressed(x, y, btn, istouch, presses)
    Graphite.MainNavigator:click(x, y, btn, istouch, presses)
    if Graphite.MainNavigator.route == "game" then
        if environment.mousepressed then environment:mousepressed(x, y, btn, istouch, presses) end
    end
end

function love.mousereleased(x, y, btn, istouch, presses)
    if Graphite.MainNavigator.route == "game" then
        if environment.mousereleased then environment:mousereleased(x, y, btn, istouch, presses) end
    end
    Graphite.PlaceCells = true
end

function love.wheelmoved(x, y)
    if Graphite.MainNavigator.route == "game" then
        if environment.scroll then environment:scroll(x, y) end
    end
end

function love.keypressed(key, code, continous)
    if Graphite.MainNavigator.route == "game" then
        if environment.keypressed then environment:keypressed(key, code, continous) end
    end
end
Low = {}
Low.__index = Low

function Low:new(draw, update, typec)
    return setmetatable({draw = draw, update = update, typec = typec}, self)
end
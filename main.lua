-- this is an example file with the purpose of
-- describing how framestack can be used.

-- include core functions
require "framestack"

-- register framestack to love update
function love.update()
  framestack:update()
end

-- register framestack to love draw
function love.draw()
  framestack:draw()
end

-- create frame on layer 2
local orange = framestack:new(2, "orange")
orange.x, orange.y = 100, 100
orange.width, orange.height = 200,200
orange.draw = function(self, x, y, width, height)
  love.graphics.setColor( 1, .5, 0, 1 )
  love.graphics.rectangle("fill", 0, 0, width, height)
end

-- create frame on layer 1
local green = framestack:new(1, "green")
green.x, green.y = 25, 25
green.width, green.height = 500, 500
green.draw = function(self, x, y, width, height)
  love.graphics.setColor( 0, 1, 0, 1 )
  love.graphics.rectangle("fill", 0, 0, width, height)
end

-- create child frame on layer 3
local blue = green:new(3, "blue (child of green)")
blue.x, blue.y = 50, 50
blue.width, blue.height = 100, 100
blue.draw = function(self, x, y, width, height)
  love.graphics.setColor( 0, 0, 1, 1 )
  love.graphics.rectangle("fill", 0, 0, width, height)
end

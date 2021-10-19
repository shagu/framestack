-- this is an example file with the purpose of
-- describing how framestack can be used.

-- include core functions
require "framestack"
require "framestack/mouse"

-- widgets
require "framestack/font"

-- register framestack to love update
function love.load()
  framestack:init()
end

-- create frame on layer 2
local orange = framestack:new(2, "orange", "font")
orange.text = "Example Text"
orange.x, orange.y = 100, 100
orange.width, orange.height = 200,200
orange.draw = function(self, x, y, width, height)
  love.graphics.setColor( 1, .5, 0, 1 )
  love.graphics.rectangle("line", 0, 0, width, height)
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

-- add click to orange and blue
orange.mouse = true
orange:on("click", function()
  print("Orange")
end)

blue.mouse = true
blue:on("click", function()
  print("Blue")
end)

-- run something on mouse enter/leave
blue:on("enter", function()
  print("Enter Blue")
end)

blue:on("leave", function()
  print("Leave Blue")
end)

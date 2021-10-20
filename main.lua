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

-- create mouse-enabled font-frame on layer 2
local orange = framestack:new(2, "orange", "font")
orange.text = "Example Text"
orange.x, orange.y = 100, 100
orange.width, orange.height = 200,200
orange.mouse = true

orange:on("draw", function(self, event, x, y, width, height)
  love.graphics.setColor( 1, .5, 0, 1 )
  love.graphics.rectangle("line", 0, 0, width, height)
end)

orange:on("click", function()
  orange.text = "Click Orange"
end)

-- create frame on layer 1
local green = framestack:new(1, "green")
green.x, green.y = 25, 25
green.width, green.height = 500, 500
green:on("draw", function(self, event, x, y, width, height)
  love.graphics.setColor( 0, 1, 0, 1 )
  love.graphics.rectangle("fill", 0, 0, width, height)
end)

-- create mouse-enabled child frame on layer 3
local blue = green:new(3, "blue (child of green)")
blue.x, blue.y = 50, 50
blue.width, blue.height = 100, 100
blue.mouse = true

blue:on("draw", function(self, event, x, y, width, height)
  love.graphics.setColor( 0, 0, 1, 1 )
  love.graphics.rectangle("fill", 0, 0, width, height)
end)

blue:on("click", function()
  orange.text = "Click Blue"
end)

blue:on("enter", function()
  orange.text = "Enter Blue"
end)

blue:on("leave", function()
  orange.text = "Leave Blue"
end)

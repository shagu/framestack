F = require "framestack"

local metrics = {
  sum = 0, count = 0,
  scan = function(self, max)
    self.max = max
    self.time = love.timer.getTime()
  end,

  resolve = function(self)
    self.sum = self.sum + love.timer.getTime() - self.time
    self.count = self.count + 1

    if self.count >= self.max then
      print(string.format("%d iterations took %.4f seconds", self.count, self.sum))
      self.count, self.sum = 0, 0
    end
  end,
}

function love.update()
  F:update()
end

function love.draw()
  metrics:scan(100)
  F:draw()
  metrics:resolve()
end

local green = F:new(1, "green")
green.x, green.y = 20, 20
green.draw = function()
  love.graphics.setColor( 0, 1, 0, 1 )
  love.graphics.rectangle("fill", 0, 0, 500, 500)
end

local child = green:new(3, "green-child")
child.x, child.y = 50, 50
child.draw = function()
  love.graphics.setColor( 1, 0, 1, 1 )
  love.graphics.rectangle("fill", 0, 0, 100, 100)
end

local orange = F:new(2, "orange")
orange.x, orange.y = 0, 0
orange.draw = function()
  love.graphics.setColor( 1, .5, 0, 1 )
  love.graphics.rectangle("fill", 0, 0, 100, 100)
end

-- This module adds a basic color template.
--
-- Variables:
--  frame.color = { r, g, b, a }
--    The color of the frame.

framestack.templates["color"] = function(frame)
  -- set core variables
  frame.color = { 1, 1, 1, 1 }

  -- register a color render to draw
  frame.render["color"] = function(frame, x, y, width, height)
    love.graphics.setColor(unpack(frame.color))
    love.graphics.rectangle("fill", 0, 0, width, height)
  end
end

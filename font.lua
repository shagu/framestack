-- This module adds a basic font template.
--
-- Variables:
--  frame.text = "foo bar"
--    The text that should be written.
--
--  frame.font = love.graphics.newFont()
--    The font object that shall be used.
--
--  frame.color = { r, g, b, a }
--    The color of the font.
--
--  frame.align = "LEFT"
--    The horizontal text align inside the frame.
--    Can be "LEFT", "CENTER" or "RIGHT".
--
--  frame.valign = "TOP"
--    The vertical text align inside the frame.
--    Can be "TOP", "MIDDLE" or "BOTTOM".
--
--  frame.rotate = 0
--    The radians of the text rotation.
--
--  frame.shadow = { pos = "B", color = { 0, 0, 0, 0 } }
--    The shadow mode of the font. "pos" an one or a combination of:
--    T = top, B = bottom, L = left, R = right
--

framestack.templates["font"] = function(frame)
  -- set core variables
  frame.text = ""
  frame.font = love.graphics.newFont()
  frame.rotate = 0
  frame.color = { 1, 1, 1, 1 }
  frame.align = "CENTER"
  frame.valign = "MIDDLE"
  frame.shadow = {
    pos = "TBLR",
    color = { 0, 0, 0, .75 },
    offset = 1,
  }

  -- register a font render to draw
  frame.render["font"] = function(frame, x, y, width, height)
    local width = frame.font:getWidth(frame.text)
    local height = frame.font:getHeight(frame.text)
    local halfw, halfh = width/2, height/2
    local offx, offy = 0, 0

    if frame.align == "CENTER" then
      offx = frame.width/2 - width/2
    elseif frame.align == "RIGHT" then
      offx = frame.width - width
    end

    if frame.valign == "MIDDLE" then
      offy = frame.height/2 - height/2
    elseif frame.valign == "BOTTOM" then
      offy = frame.height - height
    end

    love.graphics.setFont(frame.font)
    love.graphics.setColor(unpack(frame.shadow.color))

    frame.shadow.pos:gsub(".", function(c)
      if c == "T" then
        love.graphics.print(frame.text, offx + halfw, offy + halfh - frame.shadow.offset, frame.rotate, nil, nil, halfw, halfh)
      elseif c == "B" then
        love.graphics.print(frame.text, offx + halfw, offy + halfh + frame.shadow.offset, frame.rotate, nil, nil, halfw, halfh)
      elseif c == "L" then
        love.graphics.print(frame.text, offx + halfw - frame.shadow.offset, offy + halfh, frame.rotate, nil, nil, halfw, halfh)
      elseif c == "R" then
        love.graphics.print(frame.text, offx + halfw + frame.shadow.offset, offy + halfh, frame.rotate, nil, nil, halfw, halfh)
      end
    end)

    love.graphics.setColor(unpack(frame.color))
    love.graphics.print(frame.text, offx + halfw, offy + halfh, frame.rotate, nil, nil, halfw, halfh)
  end
end

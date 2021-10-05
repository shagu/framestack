framestack.mouse = {}

local buttonstate = {}

-- returns the current frame with mouse focus
framestack.mouse.focus = function()
  local focus = nil
  local mx, my = love.mouse.getPosition()

  -- iterate through framestack to find mouse focus
  for layer, frames in pairs(framestack.queue) do
    for id, frame in pairs(frames) do
      if frame.mouse and frame.show then
        local x, y, width, height = framestack.geom(frame)
        if mx > x and mx < x + width and
           my > y and my < y + height
        then
          focus = frame
        end
      end
    end
  end

  return focus
end

-- register mousepressed hook
framestack.lovehooks["mousepressed"] = true
framestack.mousepressed = function(x, y, button)
  local focus = framestack.mouse.focus()
  if not focus then return end

  framestack.signal(focus, "mousedown", x, y, button)

  buttonstate[button] = focus
end

-- register mousereleased hook
framestack.lovehooks["mousereleased"] = true
framestack.mousereleased = function(x, y, button)
  local focus = framestack.mouse.focus()
  if not focus then return end

  framestack.signal(focus, "mouseup", x, y, button)

  if buttonstate[button] == focus then
    framestack.signal(focus, "click", x, y, button)
  end
end

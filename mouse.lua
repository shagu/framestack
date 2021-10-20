-- This module adds mouse support to the framestack.
--
-- Variables:
--  frame.mouse = 1
--    Enables mouse support on a frame
--
-- Functions:
--   framestack.mouse.focus()
--     Finds and returns the current mouseover frame
--
-- Events:
--   frame:on("enter", function(self, event) end)
--     Fired when the mouse enters the frame
--
--   frame:on("leave", function(self, event) end)
--     Fired when the mouse leaves the frame
--
--   frame:on("click", function(self, event, x, y, button) end)
--     Fired when a mouse click is performed on the frame
--
--   frame:on("mousedown", function(self, event, x, y, button) end)
--     Fired when the mouse button gets pressed
--
--   frame:on("mouseup", function(self, event, x, y, button) end)
--     Fired when the mouse enters the frame
--
-- Love2D Hooks:
--   update, mousepressed, mousereleased, touchpressed, touchreleased
--

-- break here if module is already loaded
if framestack.mouse then return end

-- initialize base table
framestack.mouse = {}

-- local caches
local buttonstate = {}
local lastfocus = nil
local nilfocus = nil
local focus = nil

-- returns the current frame with mouse focus
framestack.mouse.focus = function(tx, ty)
  -- return cache if available
  if focus and not tx and not ty then return focus end
  if nilfocus then return nil end

  local mx, my = love.mouse.getPosition()
  mx = tx or mx
  my = ty or my

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

  -- cache empty focus
  if not focus then
    nilfocus = true
  end

  return focus
end

-- Clear current mouse focus cache each frame update
framestack.hook("update", function()
  focus, nilfocus = nil, nil
end)

-- scan for focus frame change to run enter/leave events
framestack.hook("update", function()
  local focus = framestack.mouse.focus()

  if focus ~= lastfocus then
    if lastfocus then
      framestack.signal(lastfocus, "leave")
    end

    if focus then
      framestack.signal(focus, "enter")
    end

    lastfocus = focus
  end
end)

-- send mouse event to focused frame and cache button states
framestack.hook("touchpressed", function(id, x, y, dx, dy, pressure)
  local focus = framestack.mouse.focus(x, y)
  buttonstate["touch"] = focus

  if not focus then return end
  framestack.signal(focus, "mousedown", x, y, "touch")
end)

-- send mouse event to focused frame and also detect and send click event
framestack.hook("touchreleased", function(id, x, y, dx, dy, pressure)
  local focus = framestack.mouse.focus(x, y)

  if not focus then return end
  framestack.signal(focus, "mouseup", x, y, "touch")
  if buttonstate["touch"] == focus then
    framestack.signal(focus, "click", x, y, "touch")
  end
end)

framestack.hook("mousepressed", function(x, y, button)
  local focus = framestack.mouse.focus()
  buttonstate[button] = focus

  if not focus then return end
  framestack.signal(focus, "mousedown", x, y, button)
end)

-- send mouse event to focused frame and also detect and send click event
framestack.hook("mousereleased", function(x, y, button)
  local focus = framestack.mouse.focus()

  if not focus then return end
  framestack.signal(focus, "mouseup", x, y, button)
  if buttonstate[button] == focus then
    framestack.signal(focus, "click", x, y, button)
  end
end)

-- This is the framestack core.
-- It provides an event system and takes care of the draw order of each frame.
--
-- Variables:
--   frame.x = 0
--     The X coordinate of the frame.
--
--    frame.y = 0
--      The Y coordinate of the frame.
--
--   frame.width = 0
--     The width of the frame.
--
--   frame.height = 0
--     The height of the frame.
--
--   frame.show = true
--     Determines if the frame should be shown or not.
--
--   frame.name = "<unnamed>"
--     The frame name, mostly used for debugging.
--
--   frame.layer = 1
--     The current drawlayer of the frame.
--
--   frame.parent = nil
--     The current parent of the frame.
--
-- Methods:
--   frame:new(drawlayer, name, [template1, template2, ...])
--     Creates a child frame on the current frame. If the parent gets hidden,
--     the child will also be hidden.
--
--   frame:on(event, function)
--     Runs a function on specified events.
--
--   frame:signal(event, [arg1, arg2, ...])
--     Sends an event to the frame.
--
-- Events:
--   frame:on("update", function(self, event) end)
--     Fired each update cycle.
--
--   frame:on("draw", function(self, event) end)
--     Fired each draw cycle.
--
-- Internal:
--   frame.events = {}
--     Contains a list of all events registered on the frame.
--
--   frame.render = { ["mytemplate"] = func }
--     The internal render queue, used by templates.
--
--   framestack.templates = { ["mytemplate"] = func }
--     A table that is used to register custom template functions.
--     The supplied function is called when a template is used via `:new()`
--     and should transform the `frame` to whatever it shall be.
--
--   framestack.hook("love2d.callback", function() end)
--     Can be used to register a custom module to love2d callbacks.
--

framestack = {}
framestack.frames = {}
framestack.templates = {}
framestack.events = {}
framestack.lovehooks = {}

-- set initial size values
framestack.x, framestack.y = 0, 0
framestack.width = love.graphics.getWidth()
framestack.height = love.graphics.getHeight()

-- add local shortcuts
local frames = framestack.frames
local templates = framestack.templates
local events = framestack.events

-- iterate over all existing frames
local function iterate(frames)
  local queue = {}
  if not frames then return queue end

  -- iterate over all frame layers
  for id, frame in pairs(frames) do
    -- update frame
    if frame.update then
      frame:update()
    end

    -- queue frame draw
    if framestack.visible(frame) then
      queue[frame.layer] = queue[frame.layer] or {}
      table.insert(queue[frame.layer], frame)
    end
  end

  return queue
end

-- emit event signal to frame
framestack.signal = function(frame, event, ...)
  -- emit a global event to all registered frames
  if event and events[event] and (not frame or frame == framestack) then
    for id, current in pairs(events[event]) do
      current.events[event](current, event, ...)
    end
  elseif frame and frame ~= framestack and frame.events[event] then
    frame.events[event](frame, event, ...)
  end
end

-- basic event registry function
framestack.on = function(self, event, func)
  -- register event function to frame
  self.events[event] = func

  -- register frame to event table
  events[event] = events[event] or {}
  for id, frame in pairs(events[event]) do
    if frame == self then return end
  end

  table.insert(events[event], self)
end

-- get absolute frame geometry (x,y,width,height)
framestack.geom = function(frame)
  local x, y = 0, 0
  if frame.parent and frame.parent.x then
    x, y = framestack.geom(frame.parent)
  end

  return frame.x + x, frame.y + y, frame.width, frame.height
end

-- get boolean if a frame is visible
framestack.visible = function(frame)
  if not frame or frame == framestack then return true end
  if not frame.show then return nil end
  return framestack.visible(frame.parent)
end

-- creates and registers a new frame
framestack.new = function(parent, layer, name, ...)
  local parent = parent or framestack and nil
  local layer = layer or parent.layer or 1
  local name = name or "<unnamed>"

  -- build default frame
  local frame = {
    -- base
    parent = parent,
    layer = layer,
    name = name,

    -- defaults
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    show = true,

    -- event system
    signal = framestack.signal,
    on = framestack.on,
    events = {},

    -- core functions
    new = framestack.new,
    render = {},
  }

  -- apply templates
  for id, template in pairs({...}) do
    if not templates[template] then
      print("ERROR: Could not find template '" .. template .. "'")
    else
      templates[template](frame)
    end
  end

  -- add frame to parent layers
  table.insert(frames, frame)

  return frame
end

-- register a new love2d hook
framestack.hook = function(name, func)
  framestack.lovehooks[name] = framestack.lovehooks[name] or {}
  table.insert(framestack.lovehooks[name], func)
end

-- apply all hooks on love2d functions
framestack.init = function()
  for name, data in pairs(framestack.lovehooks) do
    for id, func in pairs(data) do
      local previous = love[name]
      if previous then
        -- hook already existing function
        love[name] = function(...)
          previous(...)
          func(...)
        end
      else
        -- add new function
        love[name] = func
      end
    end
  end
end

-- register resize hook
framestack.hook("resize", function(w, h)
  framestack.x, framestack.y = 0, 0
  framestack.width = love.graphics.getWidth()
  framestack.height = love.graphics.getHeight()
end)

-- register update hook
framestack.hook("update", function()
  -- update frames and create draw queue
  framestack.queue = iterate(frames)
  -- trigger all update events
  framestack:signal("update")
end)

-- register draw hook
framestack.hook("draw", function()
  -- draw framestack queue
  for layer, frames in pairs(framestack.queue) do
    for id, frame in pairs(frames) do
      -- save and transform coordinates
      local x, y, width, height = framestack.geom(frame)
      love.graphics.push()
      love.graphics.translate(x, y)

      -- render templates
      for template, render in pairs(frame.render) do
        render(frame, x, y, width, height)
      end

      -- trigger frame draw
      frame:signal("draw", x, y, width, height)

      -- reset coordinates
      love.graphics.pop()
    end
  end
end)

return framestack

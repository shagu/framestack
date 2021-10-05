framestack = {}
framestack.frames = {}
framestack.templates = {}

local events = {}

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

    -- core functions
    new = framestack.new,
    update = nil,
    draw = nil,

    -- event system
    signal = framestack.signal,
    on = framestack.on,
    events = {},
  }

  -- apply templates
  for id, template in pairs({...}) do
    if not framestack.templates[template] then
      print("ERROR: Could not find template '" .. template .. "'")
    else
      framestack.templates[template](frame)
    end
  end

  -- add frame to parent layers
  table.insert(framestack.frames, frame)

  return frame
end

framestack.update = function(self)
  -- update frames and create draw queue
  self.queue = iterate(self.frames)
end

framestack.draw = function(self)
  -- draw framestack queue
  for layer, frames in pairs(self.queue) do
    for id, frame in pairs(frames) do
      -- save and transform coordinates
      local x, y, width, height = framestack.geom(frame)
      love.graphics.push()
      love.graphics.translate(x, y)

      -- draw frame
      if frame.draw then
        frame:draw(x, y, width, height)
      end

      -- reset coordinates
      love.graphics.pop()
    end
  end
end

return framestack

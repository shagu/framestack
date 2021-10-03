framestack = {}
framestack.frames = {}
framestack.queue = {}

local function iterate(frames)
  if not frames then return end

  -- reset frame draw queue
  framestack.queue = {}

  -- iterate over all frame layers
  for id, frame in pairs(frames) do
    -- update frame
    if frame.update then
      frame:update()
    end

    -- queue frame draw
    if framestack.visible(frame) then
      framestack.queue[frame.layer] = framestack.queue[frame.layer] or {}
      table.insert(framestack.queue[frame.layer], frame)
    end
  end
end

-- get absolute frame geometry (x,y,width,height)
framestack.geom = function(frame)
  if not frame.parent then return 0, 0, 0, 0 end
  local x, y = framestack.geom(frame.parent)
  x, y = x or 0, y or 0
  return frame.x + x, frame.y + y, frame.width, frame.height
end

-- get boolean if a frame is visible
framestack.visible = function(frame)
  if not frame or frame == framestack then return true end
  if not frame.show then return nil end
  return framestack.visible(frame.parent)
end

-- creates and registers a new frame
framestack.new = function(parent, layer, name)
  local parent = parent or framestack and nil
  local layer = layer or parent.layer or 1
  local name = name or "<unnamed>"

  -- build default frame
  local frame = {
    parent = parent,
    layer = layer,
    name = name,

    x = 0,
    y = 0,
    width = 0,
    height = 0,
    show = true,

    new = framestack.new,
    update = nil,
    draw = nil,
  }

  -- add frame to parent layers
  table.insert(framestack.frames, frame)

  return frame
end

framestack.update = function(self)
  -- update frames and create draw queue
  iterate(self.frames)
end

framestack.draw = function(self)
  -- draw framestack queue
  for layer, frames in pairs(framestack.queue) do
    for id, frame in pairs(frames) do
      -- save and transform coordinates
      local x, y = framestack.geom(frame)
      love.graphics.push()
      love.graphics.translate(x, y)

      -- draw frame
      if frame.draw then
        frame:draw()
      end

      -- reset coordinates
      love.graphics.pop()
    end
  end
end

return framestack

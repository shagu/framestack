framestack = {}
framestack.layers = {}

local function draw(layers)
  if not layers then return end

  -- iterate over all frame layers
  for layer, frames in pairs(layers) do
    for id, frame in pairs(frames) do
      if frame.show then
        -- save and transform coordinates
        love.graphics.push()
        love.graphics.translate(frame.x, frame.y)

        -- update frame
        if frame.update then
          frame:update()
        end

        -- draw frame
        if frame.draw then
          frame:draw()
        end

        -- process frame layers
        draw(frame.layers)

        -- reset coordinates
        love.graphics.pop()
      end
    end
  end
end

framestack.draw = function(self)
  draw(self.layers)
end

framestack.new = function(parent, layer, name)
  local parent = parent or framestack
  local layer = layer or 1
  local name = name or "<unnamed>"

  -- build default frame
  local frame = {
    name = name,
    parent = parent,
    show = true,

    x = 0,
    y = 0,
    width = 0,
    height = 0,

    layers = {},
    new = framestack.new,
    update = nil,
    draw = nil,
  }

  -- add frame to parent layers
  parent.layers[layer] = parent.layers[layer] or {}
  table.insert(parent.layers[layer], frame)

  return frame
end

return framestack

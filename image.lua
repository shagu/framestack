-- This module adds a basic image template.
--
-- Variables:
--  frame.image = "path/to/image.png"
--    The image path that should be loaded
--
--  frame.blob = { imageblob, path }
--    An internal variable containing the current
--    imagedata and the image path of it.
--
--  frame.color = { r, g, b, a }
--    The color tint of the image.
--
--  frame.rotate = 0
--    The radians of the image rotation.
--
--  frame.fit = true
--    Fits the image into the frame, otherwise the
--    original image size will be used.
--
--  frame.align = "LEFT"
--    The horizontal image alignment inside the frame.
--    Can be "LEFT", "CENTER" or "RIGHT".
--
--  frame.valign = "TOP"
--    The vertical image alignment inside the frame.
--    Can be "TOP", "MIDDLE" or "BOTTOM".
--

framestack.templates["image"] = function(frame)
  -- set core variables
  frame.image = nil
  frame.blob = { }
  frame.color = { 1, 1, 1, 1 }
  frame.rotate = 0
  frame.fit = true
  frame.align = "CENTER"
  frame.valign = "MIDDLE"

  -- register the image render function
  frame.render["image"] = function(frame, x, y, width, height)
    -- refresh image blob if required
    if not frame.blob[2] or ( frame.blob[2] and frame.blob[2] ~= frame.image ) then
      frame.blob[1] = love.graphics.newImage(frame.image)
      frame.blob[2] = frame.image
    end

    -- return when no image is loaded
    if not frame.blob[1] then return end

    -- read image
    local width = frame.blob[1]:getWidth()
    local height = frame.blob[1]:getHeight()
    local scale = 1

    -- calculate scale to fit image into frame
    if frame.fit then
      local x = frame.width > 0 and frame.width/width or 1
      local y = frame.height > 0 and frame.height/height or 1
      scale = math.min(x, y)
    end

    -- calculate image position
    local halfw, halfh = width/2, height/2
    local offx, offy = 0, 0

    if frame.align == "CENTER" then
      offx = frame.width/2 - halfw*scale
    elseif frame.align == "RIGHT" then
      offx = frame.width - width*scale
    end

    if frame.valign == "MIDDLE" then
      offy = frame.height/2 - halfh*scale
    elseif frame.valign == "BOTTOM" then
      offy = frame.height - height*scale
    end

    -- draw image
    love.graphics.setColor(unpack(frame.color))
    love.graphics.draw(frame.blob[1], offx + halfw*scale, offy + halfh*scale, frame.rotate, scale, scale, halfw, halfh)
  end
end

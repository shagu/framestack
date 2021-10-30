-- This module auto aligns the frame to its parent.
--
-- Variables:
--  frame.offset = { top, right, bottom, left }
--    The frame offset position to its parent.
--    Values below 1 will be read as percentage to the parent.

framestack.templates["resize"] = function(frame)
  -- set core variables
  frame.offset = { 0, 0, 0, 0 }

  -- register a resize handler
  local top, right, bottom, left
  frame.render["resize"] = function(frame, x, y, width, height)
    if not frame.parent then return end

    -- detect percentage values
    top = frame.offset[1] < 1 and frame.parent.height * frame.offset[1] or frame.offset[1]
    right = frame.offset[2] < 1 and frame.parent.width * frame.offset[2] or frame.offset[2]
    bottom = frame.offset[3] < 1 and frame.parent.height * frame.offset[3] or frame.offset[3]
    left = frame.offset[4] < 1 and frame.parent.width * frame.offset[4] or frame.offset[4]

    -- set frame sizes
    frame.x, frame.y = left, top
    frame.width = frame.parent.width - left - right
    frame.height = frame.parent.height - top - bottom
  end
end

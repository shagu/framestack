# Framestack

**Warning:This project does not yet provide a stable API and things can change a lot.**

A simple toolkit for [Love2D](love2d.org/) featuring draw-layers, an event system, widget templates and mouse & touchpad support.
The **Framestack** aims to be a universal toolkit that assists to get things done.

## Getting Started

### Includes

Assuming the framestack has been cloned into your project directory, you can include the modules you require:

```lua
-- include core functions
require "framestack"
require "framestack/mouse"

-- widgets
require "framestack/font"
```

The example above will include the `framestack` itself, which takes care of draw layers and the event system. The `mouse` enables support for mouse down, mouse up and click events (also touchpad). Mouse interactions are sent to the frame via events. The `font` is an example widget that makes it easy to transform a frame to a text string.

### Creating a Frame

Frames can be created by calling `:new()` on the framestack to create a base frame or on another frame to create a child.
In the following example, a frame is created on drawlayer 2 with the name "orange". The `x`, `y`, `width` and `height` attributes define the size of a frame:

```lua
local orange = framestack:new(2, "orange")
orange.width, orange.height = 200, 200
orange.x, orange.y = 100, 100
```

It is also possible to create frames that inherit from a template class, such as "font":

```lua
local orange = framestack:new(2, "orange", "font")
orange.width, orange.height = 200, 200
orange.x, orange.y = 100, 100
orange.text = "Example Text"
```

In this case, the font template is used which provides basic text drawing functionality and additional attributes such as `.text`.

### Event System

Each frame can listen to events. Those can either be global events or events specific for the frame. If something should be drawn inside the frame, it's common to use the frame's `draw` event:

```lua
orange:on("draw", function(self, event, x, y, width, height)
  love.graphics.setColor(1, .5, 0, 1)
  love.graphics.rectangle("line", 0, 0, width, height)
end)
```

Note that everything drawn inside the "draw" event function is aligned to the frame. In other words, the x and y values are 0, 0 at the top-left of the frame. However, the draw event also supplies the function with the absolute coordinates and size of the frame.


### Mouse Handler

To enable mouse/touchpad support on a frame, it is required to have the `framestack/mouse` module included and to set the `mouse` attribute of the frame to `true`. Framestack will then start to emit mouse events to the frame, such as `enter`, `leave`, `click` and others.

```lua
orange.mouse = true

orange:on("click", function()
  orange.text = "Click Orange"
end)
```

### What's Next?

Make sure to read through the comments of the framestack source files. I do my best to document the attributes, events and functions of each module at the top of each file.

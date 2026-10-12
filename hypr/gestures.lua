hl.gesture({
  fingers = 3,
  mods = "CTRL + SUPER",
  direction = "horizontal",
  action = "workspace"
})

hl.gesture({
  fingers = 3,
  mods = "SUPER",
  direction = "horizontal",
  action = "scroll_move"
})

hl.gesture({
  fingers = 3,
  mods = "SUPER + SHIFT",
  direction = "left",
  action = function()
    hl.dispatch(hl.dsp.window.move({ direction = "left" }))
  end
})

hl.gesture({
  fingers = 3,
  mods = "SUPER + SHIFT",
  direction = "right",
  action = function()
    hl.dispatch(hl.dsp.window.move({ direction = "right" }))
  end
})

hl.gesture({
  fingers = 3,
  mods = "SUPER + SHIFT",
  direction = "up",
  action = function()
    hl.dispatch(hl.dsp.window.move({ direction = "up" }))
  end
})

hl.gesture({
  fingers = 3,
  mods = "SUPER + SHIFT",
  direction = "down",
  action = function()
    hl.dispatch(hl.dsp.window.move({ direction = "down" }))
  end
})

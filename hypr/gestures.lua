hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace"
})

hl.gesture({
  fingers = 3,
  mods = "ALT",
  direction = "left",
  action = function()
    hl.dispatch(hl.dsp.window.move({ direction = "left" }))
  end
})

hl.gesture({
  fingers = 3,
  mods = "ALT",
  direction = "right",
  action = function()
    hl.dispatch(hl.dsp.window.move({ direction = "right" }))
  end
})

hl.gesture({
  fingers = 3,
  mods = "ALT",
  direction = "up",
  action = function()
    hl.dispatch(hl.dsp.window.move({ direction = "up" }))
  end
})

hl.gesture({
  fingers = 3,
  mods = "ALT",
  direction = "down",
  action = function()
    hl.dispatch(hl.dsp.window.move({ direction = "down" }))
  end
})

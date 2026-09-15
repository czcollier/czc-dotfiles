-- beziers: https://easings.net/

--hl.curve( "czc_bezier", { type = "bezier", points = { {0.34, 1.56}, {0.64, 1} } })
hl.curve( "ease_out_quart", { type = "bezier", points = { {0.25, 1}, {0.5, 1} } })
hl.curve( "czc_spring", { type = "spring", mass = 1, stiffness = 99, dampening = 15 })
hl.curve( "overshoot", { type = "bezier", points = { {0.5, 0.9}, {0.1, 1.1} } } )
hl.curve( "rubber", { type = "spring", mass = 1, stiffness = 70, dampening = 10 } )

hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 6,
  style = "slidefade 10%",
  bezier = "ease_out_quart", 
})

hl.animation({
  leaf = "windowsMove",
  enabled = true,
  speed = 1,
  style = "slidefade",
  bezier = "ease_out_quart"
})

hl.animation({
  leaf = "fadeSwitch",
  enabled = true,
  speed = 3,
  bezier = "default"
})

hl.animation({
  leaf = "borderangle",
  enabled = false,
  speed = 100,
  style = "loop",
  bezier = "default"
})


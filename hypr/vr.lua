hl.monitor({ output = "VR-1", mode = "5760x4320@60", position = "auto", scale = 1.5 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1200@60", position = "auto", scale = 1.5 })
 Release the HTC Vive's port for DRM leasing
 Explicitly configure the Vive to bypass the 'non-desktop' flag


hl.monitor({
    output = "HDMI-A-1",
    mode = "2160x1200@90",
    position = "auto",
    scale = 1
})

hl.device({
  name= "SpatialProductivityKeyboard",
  enabled = false
})

-- Suppress the VR keyboard bridge on the physical desktop.
-- Events from this device go to headless sway (wayland-2) → foot in VR only.
hl.device({
  name = "virtual-vr-keyboard",
  enabled = false
})

hl.workspace_rule({ workspace = "10", monitor = "HDMI-A-1", persistent = true })

hl.window_rule({
    name = "sandbox-monado-title",
    match = { title = "^(Monado.*)$" },
    monitor = "HDMI-A-1",
    fullscreen = true,
    workspace = "10 silent",
})

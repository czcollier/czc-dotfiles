hl.workspace_rule({
  workspace = "special:hidden",
  layout = "scrolling",
  gaps_in = "15",
  gaps_out = "300",
})

hl.workspace_rule({ workspace = "1", persistent = true })
hl.workspace_rule({ workspace = "2", persistent = true })
hl.workspace_rule({ workspace = "3", persistent = true })
hl.workspace_rule({ workspace = "4", persistent = true })
hl.workspace_rule({ workspace = "10", monitor = "VR-1", persistent = true })

hl.window_rule {
    name = "magic_home",
    match = { 
      class = "magic_home"
    },
    opacity = 0.85,
    rounding = 2,
    --no_anim = true,
    border_color = { colors = {"rgba(cc6699ee)", "rgba(cc9966ee)"}, angle = 45 },
}

hl.window_rule {
    name = "magic_work",
    match = { 
      class = "magic_work"
    },
    opacity = 0.85,
    rounding = 2,
    --no_anim = true,
    border_color = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 }
}

hl.window_rule {
    name = "system_dialogs",
    match = { 
      class = "^xdg-desktop-portal-gtk$"
    },
    float = true,
    size = "900 700"
}

hl.window_rule {
    name = "image_viewer",
    match = {
      class = "org.gnome.Loupe"
    },
    float = true,
    size = "900 700"
}

hl.window_rule {
    name = "file_browser",
    match = {
      class = "org.gnome.Nautilus"
    },
    float = true,
    size = "900 700"
}

hl.window_rule {
    name = "upload_auth",
    match = {
      class = "chrome-pmhkaepabdniocnppdkfgifgonahhpdi-Profile_2"
    },
    float = true,
    fullscreen = false,
    size = "600 670"
}

hl.layer_rule {
  name = "noctalia",
  match = {
    namespace = "noctalia-bar-default"
  },
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true
}

hl.layer_rule {
  name = "noctalia-widgets",
  match = {
    namespace = "noctalia-desktop-widget"
  },
  blur = true,
  blur_popups = true,
  above_lock = 1
}

local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    name = "sandbox-monado-title",
    match = { title = "^(Monado.*)$" },
    monitor = "VR-1",
    fullscreen = true,
    workspace = "10 silent",
})

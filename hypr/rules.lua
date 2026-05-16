hl.workspace_rule({
  workspace = "special:hidden",
  layout = "scrolling",
  gaps_in = "5",
  gaps_out = "300"
})

hl.workspace_rule({
  workspace = "special:term",
  layout = "scrolling",
  gaps_in = "0",
  gaps_out = "300",
  on_created_empty = "foot"
})

hl.workspace_rule({ workspace = "1", persistent = true })
hl.workspace_rule({ workspace = "2", persistent = true })
hl.workspace_rule({ workspace = "3", persistent = true })
hl.workspace_rule({ workspace = "4", persistent = true })

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
    --suppress_event = "fullscreen maximize",
    --fullscreen_state = "0 0",
    --maximize = false,
    size = "600 670"
}

hl.layer_rule {
  name = "noctalia",
  match = {
    namespace = "noctalia-background-.*$"
  },
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true
}

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(true)

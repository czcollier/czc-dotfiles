local active_border_color = { colors = {"rgba(33cc99ee)", "rgba(00ff99ee)"}, angle = 45 }
--active_border_color = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 }
local inactive_border_color = { colors = { "rgba(272727bb)" } }

hl.monitor({
    output = "eDP-1",
    mode = "preferred",
    position = "auto",
    scale = 1
})


hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        follow_mouse_shrink = 30,
        natural_scroll = true,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true
        },
    },
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
          active_border = active_border_color,
          inactive_border = inactive_border_color
        },
        layout = "dwindle",
        resize_on_border = true
    },
    layout = {
      single_window_aspect_ratio = { 4, 3 }
    },
    cursor = {
      zoom_factor = 1.0,
      hide_on_key_press = true,
      zoom_factor = 1.0
    },
    decoration = {
        rounding = 12,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        dim_around = 1.0,
        shadow = {
            enabled = true,
            range = 16,
            offset = { 8, 8 },
            render_power = 1,
            color = "rgba(1a1a1a99)"
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
            new_optimizations = true,
            brightness = 0.95
        },
        glow = {
          enabled = false, 
          render_power = 4,
          range = 30,
        }
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
        split_bias = 1,
    },

    master = {
        orientation = "left",
        new_status = "slave",
        always_keep_position = true
    },
    scrolling = {
        column_width = 0.7,
        wrap_focus = true,
        --follow_focus = true,
        focus_fit_method = 0,
        follow_min_visible = 1.0
    },
   group = {
        col = {
            border_active = active_border_color,
            border_inactive = inactive_border_color,
            border_locked_active = { colors = { "rgba(dd9999ee)", "rgba(dd6699ee)", angle = 45 } },
            border_locked_inactive = inactive_border_color,

        },
        drag_into_group = 0,
        insert_after_current = true,
        groupbar = {
            enabled = true,
            blur = true,
            rounding = 8,
            render_titles = true,
            gradients = true,
            gradient_rounding = 8,
            font_family = "Cousine Nerd Font Mono",
            indicator_gap = 2,
            height = 24,
            indicator_height = 0,
            gradient_round_only_edges = true,
            font_size = 12,
            text_color = "rgba(eeeeeeff)",
            text_color_inactive = "rgba(777777ff)",
            col = {
                active = { colors = { "rgba(aaaaee60)" } },
                inactive = { colors = { "rgba(12121666)" } },
                locked_active = { colors = { "rgba(ffcc6633)" } },
                locked_inactive = { colors = { "rgba(40301025)" } },
            },
        }
    },
    misc = {
        focus_on_activate = true,
        animate_mouse_windowdragging = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        allow_session_lock_restore = true
    },
    binds = {
      hide_special_on_workspace_change = true
    },
    render = {
        direct_scanout = 1,
        cm_auto_hdr = 1,
        cm_enabled = true
    },
    debug = {
      -- disable_logs = false
    }
    --  plugin = {
    --    hyprfocus = {
    --      mode = "shrink",
    --      fade_opacity = 0.91,
    --    }
    --  },
})

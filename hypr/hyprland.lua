-- ~/.config/hypr/hyprland.lua


local function get_lid_state()
    local f = io.open("/proc/acpi/button/lid/LID/state", "r")
    if not f then return "unknown" end
    local content = f:read("*all")
    f:close()
    
    if content:find("closed") then
        return "closed"
    else
        return "open"
    end
end

-- Monitor configuration
local lid_state = get_lid_state()

-- External monitor (always on)
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = 1 })

-- Laptop panel (conditional)
if lid_state == "closed" then
  hl.notification.create({ text = "lid closed", timeout = 1000, icon = "ok" })
  hl.monitor({ output = "eDP-1", disabled = true })
else
  hl.notification.create({ text = "lid open", timeout = 1000, icon = "ok" })
  hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
end

-- Add this to your Lua config to handle closing the lid dynamically
hl.bind("switch:on:Lid Switch", function()
  hl.notification.create({ text = "lid closed", timeout = 1000, icon = "ok" })
  hl.monitor({ output = "eDP-1", disabled = true })
end)

hl.bind("switch:off:Lid Switch", function()
  hl.notification.create({ text = "lid open", timeout = 1000, icon = "ok" })
  os.execute("sleep 1.0")
  hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
end)

local terminal = "foot"
local fileManager = "nautilus"

-- ==========================================
-- Environment Variables
-- ==========================================
-- Explicitly define XDG specs so portals don't crash
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("PROTOCOL_TIMEOUT", "1")
hl.env("PATH", os.getenv("HOME") .. "/.nix-profile/bin:" .. os.getenv("PATH"))
hl.env("SSH_AUTH_SOCK", "/home/czcollier/.tmp/.czcollier.ssh_auth_sock")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")


-- ==========================================
-- Startup
-- ==========================================
hl.on("hyprland.start", function ()
  -- 1. Push the XDG state into systemd so the portals actually boot
  hl.exec_cmd("dbus-update-activation-environment --systemd SSH_AUTH_SOCK WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP")
  
  -- 2. Boot the portals and agents
  hl.exec_cmd("/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1")
  hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("awww-daemon")
  
  -- 3. Boot noctalia with inline XDG_DATA_DIRS exactly like the .conf
  hl.exec_cmd("PATH=$HOME/.config/noctalia/bin:$PATH XDG_DATA_DIRS=/usr/local/share:/usr/share:$HOME/.local/state/nix/profiles/profile/share:$XDG_DATA_DIRS noctalia-shell")
  
  hl.exec_cmd("wl-paste --watch cliphist store")
  --hl.exec_cmd("/home/czcollier/.config/hypr/scripts/handle_monitors.sh")
end)

hl.config({
    -- ==========================================
    -- Workspaces
    -- ==========================================
    workspace = {
        "special:hidden, layout:scrolling, gapsin:20, gapsout:200, layoutopt:orientation:center"
    },

    -- ==========================================
    -- Input & Devices
    -- ==========================================
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        follow_mouse_shrink = 30,
        natural_scroll = true,
        touchpad = {
            natural_scroll = true
        }
    },
    
    device = {
    },

    -- ==========================================
    -- General Look & Feel
    -- ==========================================
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 1,
        col = {
            active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            --active_border = "rgba(ff33ccee) rgba(ffccffdd) 45deg",
            inactive_border = "rgba(595959aa)"
        },
        layout = "dwindle",
        resize_on_border = true
    },

    decoration = {
        rounding = 12,
        rounding_power = 2,
        active_opacity = 1,
        dim_around = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)"
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            vibrancy = 0.1696,
            new_optimizations = true,
            brightness = 1.0
        }
    },

    animations = {
        enabled = true,
        animation = {
            "windows, 1, 7, default, gnomed",
            "windowsIn, 1, 1, default, gnomed",
            "windowsOut, 1, 10, default, gnomed",
            "windowsMove, 1, 1, default, gnomed",
            "workspaces, 1, 5, default, fade",
            "specialWorkspace, 1, 5, default, fade"
        }
    },

    -- ==========================================
    -- Layouts
    -- ==========================================
    dwindle = {
        preserve_split = true
    },

    master = {
        orientation = "left",
        new_status = "slave",
        always_keep_position = true
    },

    scrolling = {
        column_width = 0.5
    },

   group = {
        col = {
            border_active = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" } },
            border_inactive = { colors = { "rgba(595959aa)" } }
        },
        insert_after_current = true,
        groupbar = {
            enabled = true,
            rounding = 8,
            render_titles = true,
            gradients = true,
            gradient_rounding = 8,
            font_family = "Consolas",
            indicator_gap = 2,
            height = 24,
            indicator_height = 0,
            gradient_round_only_edges = true,
            font_size = 12,
            col = {
                inactive = { colors = { "rgba(595959aa)", "rgba(595959aa)", "rgba(595959aa)" } },
                active = { colors = { "rgba(bbbb44cc)" } },
                locked_active = { colors = { "rgba(44444477)", "rgba(44444477)", "rgba(2266FF77)" } },
                locked_inactive = { colors = { "rgba(595959aa)", "rgba(595959aa)", "rgba(595959aa)" } }
            },
        }
    },

    -- ==========================================
    -- Misc & Render
    -- ==========================================
    misc = {
        focus_on_activate = true,
        animate_mouse_windowdragging = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        force_default_wallpaper = 0,
        disable_hyprland_logo   = false 
    },

    render = {
        direct_scanout = 1,
        cm_auto_hdr = 1,
        cm_enabled = true
    }
})

hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 5,
  style = "slidefade",
  bezier = "default"
})

-- ==========================================
-- Workspace Rules
-- ==========================================
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

hl.window_rule {
    name = "system_dialogs",
    match = { 
      class = "^xdg-desktop-portal-gtk$"
    },
    float = true,
    size = "{900, 700}"
}

hl.window_rule {
    name = "image_viewer",
    match = {
      class = "org.gnome.Loupe"
    },
    float = true,
    size = "{900, 700}"
}

hl.window_rule {
    name = "file_browser",
    match = {
      class = "org.gnome.Nautilus"
    },
    float = true,
    size = "{900, 700}"
}

-- ==========================================
-- Bindings
-- ==========================================
local mainMod = "SUPER"
local ipc = "noctalia-shell ipc call"

--- utilities ---
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " +SHIFT + Q", hl.dsp.window.kill())
hl.bind("CONTROL + SHIFT + M", hl.dsp.exec_cmd("/usr/bin/hyprlock"))
hl.bind(mainMod .. " + ALT + T", hl.dsp.exec_cmd("~/.config/hypr/scripts/hdrop.sh foot -a foot_drop"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))

hl.bind(mainMod .. " + CTRL + ALT + M",
  hl.dsp.exec_cmd(
    "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"),
    { long_press = true })

hl.bind(mainMod .. " + SHIFT + CTRL + P", hl.dsp.exec_cmd("~/scripts/panelctl.sh toggle"))

-- Move/resize windows with mainMod + LMB, mainMod + SHIFT + LMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Focus --
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd( "foot" ))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd( "gedit" ))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(ipc .. " launcher toggle"))

--- float and center active window ---
hl.bind(mainMod .. " + SHIFT + Space", function()
  hl.dispatch(hl.dsp.window.float())
  hl.dispatch(hl.dsp.window.resize({
    x = hl.get_active_monitor().width * 0.4,
    y = hl.get_active_monitor().height * 0.9,
    relative = false
  }))
  hl.dispatch(hl.dsp.window.center())
end)

--- Focus ---
hl.bind(mainMod .. " + CTRL + H", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = "1" }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = "2" }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = "3" }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "4" }))

hl.bind(mainMod .. " + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())    -- Change focus to another window
    hl.dispatch(hl.dsp.window.bring_to_top()) -- Bring it to the top
end)

--- Move windows ---
hl.bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ workspace = "+1" }))

hl.bind(mainMod .. " + CTRL + SHIFT + 7", hl.dsp.window.move({ workspace = "1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + 8", hl.dsp.window.move({ workspace = "2" }))
hl.bind(mainMod .. " + CTRL + SHIFT + 9", hl.dsp.window.move({ workspace = "3" }))
hl.bind(mainMod .. " + CTRL + SHIFT + 0", hl.dsp.window.move({ workspace = "4" }))

-- Media ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 1%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 1%-"))

--- Groups ---
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + I", hl.dsp.submap("group"))
hl.bind(mainMod .. " + O", hl.dsp.window.move({ out_of_group = true }))
hl.bind(mainMod .. " + N", hl.dsp.group.next())
hl.bind(mainMod .. " + P", hl.dsp.group.prev())
hl.bind(mainMod .. " + U", hl.dsp.group.lock_active())

hl.define_submap("group", "reset", function()
  hl.bind("H", hl.dsp.window.move({ into_group = "left" }))
  hl.bind("J", hl.dsp.window.move({ into_group = "down" })) -- Bring it to the top
  hl.bind("K", hl.dsp.window.move({ into_group = "up" })) -- Bring it to the top
  hl.bind("L", hl.dsp.window.move({ into_group = "right" })) -- Bring it to the top
  hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Special Hidden Workspace ---
hl.bind("ALT + TAB", function()
  sws = hl.get_workspace("special:hidden")
  if sws and not sws.active then
    hl.dispatch(hl.dsp.workspace.toggle_special("hidden"))
    hl.dispatch(hl.dsp.submap("hdn2"))
  end
end)

hl.define_submap("hdn2", function()
  hl.bind("ESCAPE", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("hidden"))
    hl.dispatch(hl.dsp.submap("reset"))
  end)

  hl.bind("ALT + TAB", hl.dsp.focus({ direction = "right" }))
  hl.bind("ALT + SHIFT + TAB", hl.dsp.focus({ direction = "left" }))

  hl.bind(mainMod .. " + RETURN", function()
    sws = hl.get_workspace("special:hidden")
    if not sws or not sws.windows then
      hl.dispatch(hl.dsp.workspace.toggle_special("hidden"))
    elseif sws.active then
      hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
    end
    hl.dispatch(hl.dsp.submap("reset"))
  end)
end)

-- Special Hidden Workspace ---
hl.bind(mainMod .. " + ALT + T", function()
  --sws = hl.get_workspace("special:term")
  --if sws and not sws.active then
    hl.dispatch(hl.dsp.workspace.toggle_special("term"))
    hl.dispatch(hl.dsp.submap("hdn_term"))
  --end
end)

hl.define_submap("hdn_term", function()
  hl.bind(mainMod .. " + ESCAPE", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("term"))
    hl.dispatch(hl.dsp.submap("reset"))
  end)
end)

hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + CTRL + X", hl.dsp.window.move({
  workspace = "special:hidden", follow = false }))

--- Window Resizing ---
hl.bind("CTRL + SHIFT + L", hl.dsp.window.resize({
  x = "+20",
  y = "0",
  relative = true,
  repeating = true
}))

hl.bind("CTRL + SHIFT + H", hl.dsp.window.resize({
  x = "-20",
  y = "0",
  relative = true,
  repeating = true
}))

hl.bind("CTRL + SHIFT + K", hl.dsp.window.resize({
  x = "0",
  y = "-20",
  relative = true,
  repeating = true
}))

hl.bind("CTRL + SHIFT + J", hl.dsp.window.resize({
  x = "0",
  y = "+20",
  relative = true,
  repeating = true
}))

--- Window Opacity
hl.bind(mainMod .. " + BRACKETLEFT", hl.dsp.window.set_prop({
  prop = "opacity",
  value = "0.7",
  relative = true
})) 

hl.bind(mainMod .. " + BRACKETRIGHT", hl.dsp.window.set_prop({
  prop = "opacity",
  value = "1.0",
  relative = true
})) 

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(true)

hl.on("config.reloaded", function(w)
  hl.notification.create({ text = "config reloaded: ", timeout = 1000, icon = "ok" })
end)

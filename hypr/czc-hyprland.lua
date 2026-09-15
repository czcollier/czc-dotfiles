local brightness = require("brightness")
local lid = require("lid3")
local general = require("general_config")
local binds = require("binds")
local rules = require("rules")
local animation = require("animation")
local gestures = require("gestures")
local power_profile = require("power_profile")
local layouts = require("layouts")

-- Monitor configuration
--local lid_state = lid.get_lid_state()
-- check the lid state on reconfiguration/startup
--lid.handle_switch(lid_state)


--local cursor_theme = "Bibata-Modern-Classic" 
local cursor_theme = "RosePine-Hypr"
local cursor_size = "32"
local home_dir = os.getenv("HOME")

-- ==========================================
-- Environment Variables
-- ==========================================
-- Explicitly define XDG specs so portals don't crash
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("PROTOCOL_TIMEOUT", "1")
hl.env("PATH", home_dir .. "/.nix-profile/bin:" .. os.getenv("PATH"))
hl.env("SSH_AUTH_SOCK", home_dir .. "/.tmp/.czcollier.ssh_auth_sock")

hl.env("HYPRCURSOR_THEME", cursor_theme)
hl.env("HYPRCURSOR_SIZE", cursor_size)

hl.env("XCURSOR_THEME", cursor_theme)
hl.env("XCURSOR_SIZE", cursor_size)

hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

-- 1. Declare XDG_DATA_DIRS globally BEFORE the startup hook
-- This ensures Hyprland, DBus, systemd, and Noctalia all inherit the exact same string
hl.env("XDG_DATA_DIRS", home_dir .. "/.local/share:" .. home_dir .. "/.local/state/nix/profiles/profile/share:/usr/local/share:/usr/share")

hl.on("hyprland.start", function ()
  -- 2. Sync DBus/Systemd and restart portals sequentially
  -- Wrapping this in 'bash -c' with '&&' guarantees the DBus environment updates 
  -- entirely BEFORE the portals are told to restart.
  hl.exec_cmd("bash -c 'dbus-update-activation-environment --systemd SSH_AUTH_SOCK WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_DATA_DIRS XDG_SESSION_TYPE XDG_SESSION_DESKTOP && systemctl --user restart xdg-desktop-portal-hyprland xdg-desktop-portal'")

  -- 3. Boot agents
  hl.exec_cmd("/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1")
  
  -- 4. Boot background services
  hl.exec_cmd("hypridle")
  hl.exec_cmd("wl-paste --watch cliphist store")
  
  -- 5. Boot Noctalia
  -- Because XDG_DATA_DIRS was set globally via hl.env, we don't need the inline override.
  -- We just need to inject your custom bin path.
  hl.exec_cmd("PATH=$HOME/.config/noctalia/bin:$PATH noctalia")
  hl.exec_cmd("hyprswitch init --show-title")
end)


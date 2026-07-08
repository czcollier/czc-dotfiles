local brightness = require("brightness")
local lid = require("lid")
local general = require("general_config")
local binds = require("binds")
local rules = require("rules")
local animation = require("animation")
local gestures = require("gestures")
local power_profile = require("power_profile")
local layouts = require("layouts")

-- Monitor configuration
local lid_state = lid.get_lid_state()
-- check the lid state on reconfiguration/startup
lid.handle_switch(lid_state)


--local cursor_theme = "Bibata-Modern-Classic" 
local cursor_theme = "RosePine-Hypr"
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

hl.env("HYPRCURSOR_THEME", cursor_theme)
hl.env("HYPRCURSOR_SIZE", "32")

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")

hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

-- ==========================================
-- Startup
-- ==========================================
hl.on("hyprland.start", function ()

  -- Clear any dead portal states and import variables
  hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_DATA_DIRS")

  -- Force-restart the portals so they register the ScreenCast interface
  hl.exec_cmd("systemctl --user stop xdg-desktop-portal xdg-desktop-portal-hyprland")
  hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland xdg-desktop-portal")

  -- 1. Push the XDG state into systemd so the portals actually boot
  hl.exec_cmd("dbus-update-activation-environment --systemd SSH_AUTH_SOCK WAYLAND_DISPLAY XDG_RUNTIME_DIR XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP")
  
  -- 2. Boot the portals and agents
  hl.exec_cmd("/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1")
  hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
  hl.exec_cmd("hypridle")
  --hl.exec_cmd("awww-daemon")
  
  -- 3. Boot noctalia with inline XDG_DATA_DIRS exactly like the .conf
  hl.exec_cmd("PATH=$HOME/.config/noctalia/bin:$PATH XDG_DATA_DIRS=/usr/local/share" ..
  ":/usr/share:$HOME/.local/state/nix/profiles/profile/share:$XDG_DATA_DIRS noctalia")
  hl.exec_cmd("wl-paste --watch cliphist store")
end)


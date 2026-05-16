-- ~/.config/hypr/hyprland.lua

local brightness = require("brightness")
local lid = require("lid")
local general = require("general_config")
local binds = require("binds")
local rules = require("rules")
local animation = require("animation")

-- Monitor configuration
local lid_state = lid.get_lid_state()
lid.handle_switch(lid_state)

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
  hl.exec_cmd("PATH=$HOME/.config/noctalia/bin:$PATH XDG_DATA_DIRS=/usr/local/share" ..
  ":/usr/share:$HOME/.local/state/nix/profiles/profile/share:$XDG_DATA_DIRS noctalia-shell")
  
  hl.exec_cmd("wl-paste --watch cliphist store")
end)


hl.on("config.reloaded", function(w)
  hl.notification.create({ text = "config reloaded: ", timeout = 1000, icon = "ok" })
end)

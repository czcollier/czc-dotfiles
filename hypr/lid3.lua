-- ======================================================================
-- ~/.config/hypr/hyprland.lua (Clean Clamshell Handler)
-- ======================================================================
local utils = require("utils")
local M = {}

local logfile = "/tmp/lid.log"

-- Read physical lid state directly from ACPI
function M.is_lid_closed()
    local file = io.open("/proc/acpi/button/lid/LID/state", "r")
    if not file then file = io.open("/proc/acpi/button/lid/LID0/state", "r") end
    if file then
        local state = file:read("*a")
        file:close()
        return state:match("closed") ~= nil
    end
    return false
end

-- Track if the external display is physically present
function M.is_external_active()
    for _, mon in ipairs(hl.get_monitors()) do
        if mon.name == "DP-1" then return true end
    end
    return false
end

function M.is_internal_active()
    for _, mon in ipairs(hl.get_monitors()) do
        if mon.name == "eDP-1" then return true end
    end
    return false
end

-- Determine initial state immediately to avoid enable/disable flicker on reload.
-- NOTE: eDP-1 requires a priori state handling because the built-in panel is 
-- physically present even when the lid is closed, requiring software suppression 
-- to prevent phantom rendering. External ports like DP-1 do not need this 
-- because Hyprland natively ignores configured rules when no hardware is attached.
local should_disable_edp1 = M.is_lid_closed() and M.is_external_active()

-- Define monitors with correct initial state
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1, disabled = should_disable_edp1 })
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto-right", scale = 1 })

-- Universal state enforcement function (guarantees at least one monitor is always active)
function M.enforce_display_state(event_name)
    local lid_closed = M.is_lid_closed()
    local external_active = M.is_external_active() 
    local internal_active = M.is_internal_active() 

    utils.append_to_file("event=" .. tostring(event_name) .. ", lid_closed=" .. tostring(lid_closed) .. ", external_active=" .. tostring(external_active) .. ", internal_active=" .. tostring(internal_active) .. "\n", logfile)
    if M.is_lid_closed() and M.is_external_active() then
        hl.exec_cmd("hyprctl eval 'hl.monitor({output=\"eDP-1\", disabled=true})'")
    else
        -- Always keep eDP-1 enabled if no external monitor is present, preventing 0-monitor crashes
        hl.exec_cmd("hyprctl eval 'hl.monitor({output=\"eDP-1\", disabled=false})'")
    end
end

-- ─── EVENT HANDLERS ──────────────────────────────────────

-- 1. Handle physical lid switches
hl.bind("switch:on:Lid Switch", function() M.enforce_display_state("lid_closed") end, { locked = true })
hl.bind("switch:off:Lid Switch", function() M.enforce_display_state("lid_open") end, { locked = true })

hl.on("monitor.added", function()
  M.enforce_display_state("monitor_added")
end)

hl.on("monitor.removed", function()
  M.enforce_display_state("monitor_removed")
end)

hl.on("config.reloaded", function()
  hl.timer(function()
    M.enforce_display_state("config_reloaded")
  end, { timeout = 500, type = "oneshot" })
end)

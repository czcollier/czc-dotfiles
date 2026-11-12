-- ======================================================================
-- ~/.config/hypr/hyprland.lua (ThinkPad X1 Carbon Gen 12 Clamshell Handler)
-- ======================================================================
local utils = require("utils")
local M = {}

local logfile = "/tmp/lid.log"
local is_enforcing = false


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


-- Track if the external display (DP-1) is physically present and active
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


-- Determine initial state immediately on load to avoid enable/disable flicker.
local should_disable_edp1 = M.is_lid_closed() and M.is_external_active()


-- Define monitors with correct initial state
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1, disabled = should_disable_edp1 })
hl.monitor({ output = "DP-1", mode = "preferred", position = "-1024x-2160", scale = 1 })


-- Explicitly assign workspaces to monitors to prevent auto-spawning ghost workspaces
hl.workspace_rule({ workspace = "1", monitor = "DP-1" })
hl.workspace_rule({ workspace = "2", monitor = "DP-1" })
hl.workspace_rule({ workspace = "3", monitor = "DP-1" })
hl.workspace_rule({ workspace = "4", monitor = "DP-1" })


-- Universal state enforcement function (guarantees at least one monitor is always active)
function M.enforce_display_state(event_name)
    if is_enforcing then return end
    is_enforcing = true

    hl.timer(function()
        local lid_closed = M.is_lid_closed()
        local external_active = M.is_external_active()  
        local internal_active = M.is_internal_active()  

        utils.append_to_file(string.format("event=%s, lid_closed=%s, external_active=%s, internal_active=%s\n", 
            tostring(event_name), tostring(lid_closed), tostring(external_active), tostring(internal_active)), logfile)

        if lid_closed and external_active then
            -- Shut off eDP-1 in software when running closed-clamshell with external display
            hl.monitor({ output = "eDP-1", disabled = true })
        else
            -- Always keep eDP-1 enabled if lid is open OR no external monitor is present (prevents 0-monitor crashes)
            hl.monitor({ output = "eDP-1", disabled = false })
        end

        is_enforcing = false
    end, { timeout = 250, type = "oneshot" })
end

-- ─── EVENT HANDLERS ──────────────────────────────────────

-- 1. Handle physical lid switches securely (locked context for pre-sleep/wakeup)
hl.bind("switch:on:Lid Switch", function() M.enforce_display_state("lid_closed") end, { locked = true })
hl.bind("switch:off:Lid Switch", function() M.enforce_display_state("lid_open") end, { locked = true })


-- 2. Handle configuration reloads and wake-up synchronization safely
hl.on("config.reloaded", function()
    hl.timer(function()
        M.enforce_display_state("config_reloaded")
    end, { timeout = 400, type = "oneshot" })
end)


-- 2. Handle external monitor hotplugging dynamically (Fixes plugging in while closed)
hl.on("monitor.added", function()
    M.enforce_display_state("monitor_added")
end)


hl.on("monitor.removed", function()
    M.enforce_display_state("monitor_removed")
end)


return M

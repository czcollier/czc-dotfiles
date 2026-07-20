-- ==========================================
-- CONFIGURATION & STATE INITIALIZATION
-- ==========================================
local internal = "eDP-1"
local external = "DP-1" -- Change this to match your monitor name (e.g. HDMI-A-1)

-- Global variable tracking the physical lid state
local lid_is_closed = false 

-- Disable automatic DPMS wakes from trackpad vibration or physical lid slamming
hl.config({ misc = { key_press_enables_dpms = false }})
hl.config({ misc = { mouse_move_enables_dpms = false }})

-- Helper function to check if the external monitor is currently attached
local function is_external_connected()
    for _, monitor in ipairs(hl.get_monitors()) do
        if monitor.name == external then
            return true
        end
    end
    return false
end

local function migrate_all_workspaces(target_monitor)
    local workspaces = hl.get_workspaces()
    if not workspaces then return end

    for _, ws in ipairs(workspaces) do
        -- Hyprland workspace names can be strings or integers depending on creation;
        -- passing the name/id directly to the workspace move dispatcher works cleanly.
        hl.dispatch(hl.dsp.workspace.move({ 
            workspace = tostring(ws.id or ws.name), 
            monitor = target_monitor 
        }))
    end
end

-- ==========================================
-- THE CENTRAL STATE MACHINE (Dynamic Iteration)
-- ==========================================
local function update_layout()
    local ext_connected = is_external_connected()
    -- ─── CASE 3 & 6: Laptop Closed WITH External Monitor ──────────────────
    if lid_is_closed and ext_connected then
        -- 1. FORCE THE EXTERNAL MONITOR ALIVE FIRST
        -- Ensure Hyprland explicitly keeps the viewport open on the external display
        hl.monitor({ output = external, disabled = false, mode = "preferred", position = "0x0", scale = 1 })
        hl.dispatch(hl.dsp.dpms({ action = "enable", monitor = external }))

        -- 2. EVACUATE WORKSPACES
        migrate_all_workspaces(external)

        -- 3. STAGGERED LAYOUT TEARDOWN
        -- Introduce a slight 150ms delay to let the workspaces settle on the external 
        -- monitor before cleanly disabling the internal panel's spatial mapping.
        hl.timer(function()
            hl.monitor({ output = internal, disabled = true })
            hl.dispatch(hl.dsp.dpms({ action = "disable", monitor = internal }))
        end, { timeout = 150, type = "oneshot" })
    -- ─── CASE 4 & 8: Laptop Closed WITHOUT External Monitor ───────────────
    elseif lid_is_closed and not ext_connected then
        hl.dsp.exec_cmd("hyprlock & systemctl suspend")

    -- ─── CASE 2 & 5: Laptop Opened WITH External Monitor ──────────────────
    elseif not lid_is_closed and ext_connected then
        -- Re-enable layout bounds first, then re-awaken panel hardware
        hl.monitor({ output = internal, disabled = false, mode = "preferred", position = "0x0", scale = 1 })
        hl.monitor({ output = external, mode = "preferred", position = "auto-right", scale = 1 })
        hl.dispatch(hl.dsp.dpms({ action = "enable", monitor = internal }))
        
        -- Optional: You can choose to leave your workspaces pooled on the external 
        -- monitor when opening the lid, or call a redistribution strategy here.
        hl.dispatch(hl.dsp.workspace.move({ workspace = "1", monitor = internal }))
        hl.dispatch(hl.dsp.workspace.move({ workspace = "2", monitor = external }))

    -- ─── CASE 1 & 7: Laptop Opened WITHOUT External Monitor ──────────────
    elseif not lid_is_closed and not ext_connected then
        hl.monitor({ output = internal, disabled = false, mode = "preferred", position = "0x0", scale = 1 })
        hl.dispatch(hl.dsp.dpms({ action = "enable", monitor = internal }))
        
        -- Everything collapses back to the internal display safely
        migrate_all_workspaces(internal)
    end
end
-- ==========================================
-- EVENT BINDINGS & SUBSCRIPTIONS
-- ==========================================

-- Trigger when the laptop lid physically closes
hl.bind("switch:on:Lid Switch", function()
    lid_is_closed = true
    update_layout()
end, { locked = true })

-- Trigger when the laptop lid physically opens
hl.bind("switch:off:Lid Switch", function()
    lid_is_closed = false
    -- Add a minor delay for hardware firmware stabilization upon waking up
    hl.timer(function()
        update_layout()
    end, { timeout = 200, type = "oneshot" })
end, { locked = true })

-- Dynamic Udev / Hotplug Subscriptions (Handles Cases 5, 6, 7, 8)
hl.on("monitor.added", function()
    update_layout()
end)

hl.on("monitor.removed", function()
    update_layout()
end)

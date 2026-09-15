-- ======================================================================
-- ~/.config/hypr/hyprland.lua (Clean Clamshell Handler)
-- ======================================================================

-- Define standard native monitors
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-1", mode = "preferred", position = "auto-right", scale = 1 })

-- Track if the external display is physically present
local function is_external_active()
    for _, mon in ipairs(hl.get_monitors()) do
        if mon.name == "DP-1" then return true end
    end
    return false
end

-- ─── CLAMSHELL DOCKING HANDLERS ──────────────────────────────────────

-- Lid Closed Event
hl.bind("switch:on:Lid Switch", function()
    -- Only alter the canvas if we are docked. If the monitor is unplugged,
    -- we let logind step in natively and suspend the system.
    if is_external_active() then
        -- 1. Kill the backlight power instantly
        -- os.execute("brightnessctl --save && brightnessctl set 0%")
        -- 2. Pull eDP-1 off the compositor canvas to stop phantom mouse movement
        hl.exec_cmd("hyprctl eval 'hl.monitor({output=\"eDP-1\", disabled=true})'")
    end
end, { locked = true })

-- Lid Opened Event
hl.bind("switch:off:Lid Switch", function()
    hl.timer(function()
      -- 1. Restore eDP-1 back into the active geometry layout
      hl.exec_cmd("hyprctl eval 'hl.monitor({output=\"eDP-1\", disabled=false})'")
      -- 2. Kick the backlight back to its previous state
      -- os.execute("brightnessctl --restore")

      if not is_external_active() then
        hl.exec_cmd("hyprctl reload")
      end
  end, { timeout = 1000, type = "oneshot" })
end, { locked = true })

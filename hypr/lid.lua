local utils = require("utils")

local M = {}

function M.get_panel_active()
  local mons = hl.get_monitors()
  local panel_active = false
  for key, m in pairs(mons) do
    if m.name == "eDP-1" then
      panel_active = true
    end
  end
  return panel_active
end

function M.get_lid_state()
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


function M.handle_switch(lid_state, panel_active)
  if lid_state == "closed" and panel_active == true then
    hl.monitor({ output = "eDP-1", disabled = true })
    os.execute("hyprctl reload")
  elseif lid_state == "open" and panel_active == false then
    hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto" })
    os.execute("hyprctl reload")
  else
    local cmd = string.format("notify-send " .. [[no panel action]])
    hl.exec_cmd(cmd)
  end
end

--  local lid_timer = hl.timer(function()
--    local lid_state = M.get_lid_state()
--    local panel_active = M.get_panel_active()
--    --local cmd = string.format("notify-send " .. [[panel: %s]], panel_active)
--    --hl.exec_cmd(cmd)
--    M.handle_switch(lid_state, panel_active)
--  end, { timeout = 2000, type = "repeat" })
--  
--  lid_timer:set_enabled(true)
--
--
function M.handle_lid(state)
  if state == "closed" then
    -- 1. Safely migrate open workspaces first
    hl.dispatch(hl.dsp.workspace.move({ workspace = "1", monitor = "DP-1" }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = "2", monitor = "DP-1" }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = "3", monitor = "DP-1" }))
    hl.dispatch(hl.dsp.workspace.move({ workspace = "4", monitor = "DP-1" }))
    
    -- 2. Trick Chrome by zeroing out boundaries using native configs
    -- hl.monitor({ output = "eDP-1", mode = "0x0", position = "0x0", scale = 1 })
    
    -- 3. The Official Wiki Fix: Use an asynchronous timer delay (500ms)
    -- This swallows the switch interrupt BEFORE cutting the physical panel voltage.
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "disable", monitor = "eDP-1" }))
    end, { timeout = 500, type = "oneshot" })
  else    
    -- Immediate physical wake up on lid open
    hl.dispatch(hl.dsp.dpms({ action = "enable", monitor = "eDP-1" }))
    hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
  end
end

hl.bind("switch:on:Lid Switch", function()
  --hl.monitor({ output = "eDP-1", disabled = true })
  M.handle_lid("closed")
end, { locked = true })

hl.bind("switch:off:Lid Switch", function()
  M.handle_lid("open")
  --hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto" })
  --os.execute("hyprctl reload")
end, { locked = true })

hl.on("monitor.added", function()
  local lid_state = M.get_lid_state()
  if lid_state == "closed" then
    hl.monitor({ output = "eDP-1", disabled = true })
  end
end)

return M

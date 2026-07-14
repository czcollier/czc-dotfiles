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

hl.bind("switch:on:Lid Switch", function()
  hl.monitor({ output = "eDP-1", disabled = true })
end)

hl.bind("switch:off:Lid Switch", function()
  hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto" })
  os.execute("hyprctl reload")
end, { locked = true })

--  local lid_timer = hl.timer(function()
--    local lid_state = M.get_lid_state()
--    local panel_active = M.get_panel_active()
--    --local cmd = string.format("notify-send " .. [[panel: %s]], panel_active)
--    --hl.exec_cmd(cmd)
--    M.handle_switch(lid_state, panel_active)
--  end, { timeout = 2000, type = "repeat" })
--  
--  lid_timer:set_enabled(true)

return M

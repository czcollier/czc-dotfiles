local M = {}

hl.bind("switch:on:Lid Switch", function()
  hl.monitor({ output = "eDP-1", disabled = true })
  local notify_cmd = string.format( [[noctalia-shell ipc call toast send '{"title": "Lid", "body": "Closed", "duration": 800}']])
  hl.exec_cmd(notify_cmd)
end)

hl.bind("switch:off:Lid Switch", function()
  hl.monitor({ output = "eDP-1", disabled = false, mode = "preferred", scale = 1.0, position = "1920x0" })
  os.execute("hyprctl reload")
  local notify_cmd = string.format( [[noctalia-shell ipc call toast send '{"title": "Lid", "body": "Open", "duration": 800}']])
  hl.exec_cmd(notify_cmd)
end, { locked = true })


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

function M.handle_switch(lid_state)
  -- Laptop panel (conditional)
  if lid_state == "closed" then
    hl.monitor({ output = "eDP-1", disabled = true })
  else
    hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
  end

end

return M

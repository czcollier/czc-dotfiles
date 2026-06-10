local M = {}

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
  if lid_state == "closed" then
    hl.monitor({ output = "eDP-1", disabled = true })
  else
    hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
  end

end

hl.bind("switch:on:Lid Switch", function()
  hl.monitor({ output = "eDP-1", disabled = true })
end)

hl.bind("switch:off:Lid Switch", function()
  hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
  os.execute("hyprctl reload")
end, { locked = true })

return M

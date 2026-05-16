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
  -- Laptop panel (conditional)
  if lid_state == "closed" then
    hl.notification.create({ text = "lid closed", timeout = 1000, icon = "ok" })
    hl.monitor({ output = "eDP-1", disabled = true })
  else
    hl.notification.create({ text = "lid open", timeout = 1000, icon = "ok" })
    hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
  end

  -- Add this to your Lua config to handle closing the lid dynamically
  hl.bind("switch:on:Lid Switch", function()
    hl.notification.create({ text = "lid closed", timeout = 1000, icon = "ok" })
    hl.monitor({ output = "eDP-1", disabled = true })
  end)

  hl.bind("switch:off:Lid Switch", function()
    hl.notification.create({ text = "lid open", timeout = 1000, icon = "ok" })
    hl.monitor({ output = "eDP-1", mode = "preferred", scale = 1, position = "1920x0", scale = 2 })
    os.execute("hyprctl reload")
  end, { locked = true })
end

return M

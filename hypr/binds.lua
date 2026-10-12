local brightness = require("brightness")
local saturation = require("lib/saturation")
local google_pwas = require("google_pwas")

-- ==========================================
-- Bindings
--
-- In general, but not strictly:
-- focus: SUPER + <key>
-- workspace related: add CTRL + <key>
-- window movement: add SHIFT + <key>
-- utilitiy: SUPER + ALT + <key>
-- ==========================================
local noctalia_ipc = "noctalia msg "
local windowResizeIncrement = 60
local windowOpacityIncrement = 0.05
local saturationIncrement = 10

--- utilities - typically SUPER + ALT .. ---
hl.bind("SUPER + SLASH", hl.dsp.exec_cmd(noctalia_ipc .. " plugin:keybind-cheatsheet toggle"), { description = "toggle the keybind cheatsheet" })
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(noctalia_ipc .. "panel-toggle launcher"), { description = "toggle noctalia app launcher" })
hl.bind("ALT + TAB", hl.dsp.exec_cmd(noctalia_ipc .. "window-switcher"))
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "close the current window" })

hl.bind("SUPER + ALT + M",
  hl.dsp.exec_cmd(
    "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"),
    { long_press = true, description = "shutdown system or exit compositor" })

hl.bind("SUPER + ALT + Q", hl.dsp.window.kill(), { description = "kill the current window" })
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("/usr/bin/hyprlock"), { description = "lock the screen" })
hl.bind("SUPER + ALT + S", hl.dsp.exec_cmd(noctalia_ipc .. 'screenshot-region'), { description = "take an interactive screenshot" })
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd(noctalia_ipc .. " panel-toggle clipboard"), { description = "open clipboard manager" })
hl.bind( "SUPER + ALT + P", function() google_pwas.launch_or_focus_pwas() end)

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "drag window" })
hl.bind("SUPER + ALT + mouse:272", hl.dsp.window.resize(), { mouse = true, description = "resize window" })

-- window focus --
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }), { description = "focus window up" })
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }), { description = "focus window down" })

local function horiz_focus(direction)
    local current_layout = hl.get_active_workspace().tiled_layout
    if current_layout == "scrolling" then 
        hl.dispatch(hl.dsp.layout("focus " .. direction))
    elseif current_layout == "monocle" then
        if direction == "right" then
          hl.dispatch(hl.dsp.layout("cyclenext")) 
        else
          hl.dispatch(hl.dsp.layout("cycleprev")) 
        end
    else
      hl.dispatch(hl.dsp.focus({ direction = direction }))
    end
end

hl.bind("SUPER + H", function() horiz_focus("left") end, { description = "focus window left" })
hl.bind("SUPER + L", function() horiz_focus("right") end, { description = "focus window right" })

-- hl.bind("ALT + mouse:272", function() horiz_focus("left") end, { release = true, description = "focus window left via mouse" })
--hl.bind("ALT + mouse:273", function() horiz_focus("right") end, { release = true, description = "focus window right via mouse" })

--- move windows ---
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "left" }), { description = "move window left" })
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "right" }), { description = "move window right" })
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "down" }), { description = "move window down" })
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "up" }), { description = "move window up" })

hl.bind("SUPER + SHIFT + mouse:272", hl.dsp.window.move({ direction = "left" }), { description = "move window left via mouse" })
hl.bind("SUPER + SHIFT + mouse:273", hl.dsp.window.move({ direction = "right" }), { description = "move window right via mouse" })
hl.bind("SUPER + SHIFT + mouse_down", hl.dsp.window.move({ direction = "down" }), { description = "move window down via scroll" })
hl.bind("SUPER + SHIFT + mouse_up", hl.dsp.window.move({ direction = "up" }), { description = "move window up via scroll" })

--- misc window operations ---

--- float and center active window ---
hl.bind("SUPER + SHIFT + Space", function()
  hl.dispatch(hl.dsp.window.float())
  hl.dispatch(hl.dsp.window.resize({
    x = hl.get_active_monitor().width * 0.4,
    y = hl.get_active_monitor().height * 0.9,
    relative = false
  }))
  hl.dispatch(hl.dsp.window.center())
end, { description = "float and center active window" })

hl.bind("SUPER + SHIFT + I", hl.dsp.window.pin())

hl.bind("SUPER + SHIFT + P", hl.dsp.window.pseudo({ action = "toggle" }), { description = "toggle pseudo layout" })
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ action= "toggle", mode = "fullscreen" }), { description = "toggle fullscreen" })
hl.bind("SUPER + SHIFT + ALT + F", hl.dsp.window.fullscreen_state({ client = 3, internal = 3, action = "set" }))

--- alt-tab approximation ---
-- hl.bind("ALT + Tab", function()
--     hl.dispatch(hl.dsp.window.cycle_next())    -- Change focus to another window
--     hl.dispatch(hl.dsp.window.bring_to_top()) -- Bring it to the top
-- end, { description = "cycle to next window" })

--- workspace focus ---
hl.bind("SUPER + CTRL + H", hl.dsp.focus({ workspace = "e-1" }), { description = "focus previous workspace" })
hl.bind("SUPER + CTRL + L", hl.dsp.focus({ workspace = "e+1" }), { description = "focus next workspace" })

hl.bind("SUPER + CTRL + mouse:272", hl.dsp.focus({ workspace = "e-1" }), { description = "focus previous workspace via mouse" })
hl.bind("SUPER + CTRL + mouse:273", hl.dsp.focus({ workspace = "e+1" }), { description = "focus next workspace via mouse" })

for i = 1, 4 do
  hl.bind("SUPER + CTRL + " .. tostring((i + 6) % 10), function()
    hl.animation({ leaf = "workspaces", enabled = false })
    hl.dispatch(hl.dsp.focus({workspace = tostring(i) }))
    hl.timer(function()
      hl.animation({
        leaf = "workspaces",
        enabled = true,
        speed = 6,
        style = "slidefade 10%",
        bezier = "ease_out_quart", 
      })
    end, { timeout = 100, type = "oneshot" })
  end)
end

function bind_workspace_jump(key, workspace)
  hl.bind("CTRL + ALT + " .. key, function()
    hl.animation({ leaf = "workspaces", enabled = false })
    hl.dispatch(hl.dsp.focus({workspace = workspace }))
    hl.timer(function()
      hl.animation({
        leaf = "workspaces",
        enabled = true,
        speed = 6,
        style = "slidefade 10%",
        bezier = "ease_out_quart", 
      })
    end, { timeout = 100, type = "oneshot" })
  end)
end


bind_workspace_jump("J", "1")
bind_workspace_jump("K", "2")
bind_workspace_jump("L", "3")
bind_workspace_jump("semicolon", "4")
--hl.bind("SUPER + CTRL + 7", hl.dsp.focus({ workspace = "1" }), { description = "focus workspace 1" })
--hl.bind("SUPER + CTRL + 8", hl.dsp.focus({ workspace = "2" }), { description = "focus workspace 2" })
--hl.bind("SUPER + CTRL + 9", hl.dsp.focus({ workspace = "3" }), { description = "focus workspace 3" })
--hl.bind("SUPER + CTRL + 0", hl.dsp.focus({ workspace = "4" }), { description = "focus workspace 4" })
--hl.bind("SUPER + CTRL + MINUS", hl.dsp.focus({ workspace = "5" }), { description = "focus workspace 5" })

--- monitor focus ---
hl.bind("CTRL + ALT + H", hl.dsp.focus({ monitor = "-1" }), { description = "focus previous monitor" })
hl.bind("CTRL + ALT + L", hl.dsp.focus({ monitor = "+1" }), { description = "focus next monitor" })


--- move windows between workspaces ---
hl.bind("SUPER + CTRL + SHIFT + H", hl.dsp.window.move({ workspace = "-1" }), { description = "move window to previous workspace" })
hl.bind("SUPER + CTRL + SHIFT + L", hl.dsp.window.move({ workspace = "+1" }), { description = "move window to next workspace" })
hl.bind("SUPER + CTRL + SHIFT + mouse:272", hl.dsp.window.move({ workspace = "-1" }), { description = "move window to previous workspace via mouse" })
hl.bind("SUPER + CTRL + SHIFT + mouse:273", hl.dsp.window.move({ workspace = "+1" }), { description = "move window to next workspace via mouse" })

-- jump window directly to workspace - do not follow --
hl.bind("SUPER + CTRL + SHIFT + 7", hl.dsp.window.move({ workspace = "1", follow = false }), { description = "move window to workspace 1" })
hl.bind("SUPER + CTRL + SHIFT + 8", hl.dsp.window.move({ workspace = "2", follow = false }), { description = "move window to workspace 2" })
hl.bind("SUPER + CTRL + SHIFT + 9", hl.dsp.window.move({ workspace = "3", follow = false }), { description = "move window to workspace 3" })
hl.bind("SUPER + CTRL + SHIFT + 0", hl.dsp.window.move({ workspace = "4", follow = false }), { description = "move window to workspace 4" })
hl.bind("SUPER + CTRL + SHIFT + v", hl.dsp.window.move({ workspace = "10", follow = false }), { description = "move window to workspace 10" })



hl.bind("CTRL + SHIFT + ALT + L", hl.dsp.workspace.move({ monitor = "+1"}), { description = "move workspace to the next monitor" })
hl.bind("CTRL + SHIFT + ALT + H", hl.dsp.workspace.move({ monitor = "-1"}), { description = "move workspace to the previous monitorleft" })
hl.bind("CTRL + SHIFT + ALT + M", hl.dsp.workspace.swap_monitors({monitor1 = "eDP-1", monitor2 = "DP-1"}), { description = "swap" })

--- dwindle layout bindings ---
hl.bind("SUPER + S", hl.dsp.layout("togglesplit"), { description = "toggle layout split" })
hl.bind("SUPER + comma", hl.dsp.layout("rotatesplit"), { angle = "90", description = "toggle layout split" })

--- scrolling layout bindings ---
hl.bind("SUPER + F", hl.dsp.layout("fit visible"), { description = "fit visible windows" })
hl.bind("SUPER + MINUS", hl.dsp.layout("colresize -conf"), { description = "decrease column size" })
hl.bind("SUPER + EQUAL", hl.dsp.layout("colresize +conf"), { description = "increase column size" })

--- Groups ---
hl.bind("SUPER + G", hl.dsp.group.toggle(), { description = "toggle window group" })
hl.bind("SUPER + I", hl.dsp.submap("group"), { description = "enter group submap" })
hl.bind("SUPER + O", hl.dsp.window.move({ out_of_group = true }), { description = "move window out of group" })
-- hl.bind("SUPER + N", hl.dsp.group.next(), { description = "focus next window in group" })
--hl.bind("SUPER + P", hl.dsp.group.prev(), { description = "focus previous window in group" })
hl.bind("SUPER + U", hl.dsp.group.lock_active(), { description = "lock active group" })

hl.define_submap("group", "reset", function()
  hl.bind("H", hl.dsp.window.move({ into_group = "left" }), { description = "move into group left" })
  hl.bind("J", hl.dsp.window.move({ into_group = "down" }), { description = "move into group down" }) -- Bring it to the top
  hl.bind("K", hl.dsp.window.move({ into_group = "up" }), { description = "move into group up" }) -- Bring it to the top
  hl.bind("L", hl.dsp.window.move({ into_group = "right" }), { description = "move into group right" }) -- Bring it to the top
  hl.bind("escape", hl.dsp.submap("reset"), { description = "exit group submap" })
end)


hl.define_submap("movewindow", function()
  hl.bind("ESCAPE", function()
    hl.dispatch(hl.dsp.submap("reset"))
  end, { description = "exit hidden move window" })
  hl.bind("L", function()
    awn = hl.get_active_window()
    if awn.floating then
      hl.dispatch(hl.dsp.window.move({ window = awn, x = 60, y = 0, relative = true }))
    end
  end, { repeating = true, description = "move window right"})
  hl.bind("H", function()
    awn = hl.get_active_window()
    if awn.floating then
      hl.dispatch(hl.dsp.window.move({ window = awn, x = -60, y = 0, relative = true }))
    end
  end, { repeating = true, description = "move window right"})
  hl.bind("K", function()
    awn = hl.get_active_window()
    if awn.floating then
      hl.dispatch(hl.dsp.window.move({ window = awn, x = 0, y = -60, relative = true }))
    end
  end, { repeating = true, description = "move window down"})
  hl.bind("J", function()
    awn = hl.get_active_window()
    if awn.floating then
      hl.dispatch(hl.dsp.window.move({ window = awn, x = 0, y = 60, relative = true }))
    end
  end, { repeating = true, description = "move window up"})
end)


hl.bind("CTRL + SHIFT + M", function() 
  hl.dispatch(hl.dsp.submap("movewindow"))
end)

--- Window Resizing ---
hl.bind("CTRL + SHIFT + L", hl.dsp.window.resize({
  x = "+".. windowResizeIncrement,
  y = "0",
  relative = true
}), { repeating = true, description = "resize window right" })

hl.bind("CTRL + SHIFT + H", hl.dsp.window.resize({
  x = "-" .. windowResizeIncrement,
  y = "0",
  relative = true
}), { repeating = true, description = "resize window left" })

hl.bind("CTRL + SHIFT + K", hl.dsp.window.resize({
  x = "0",
  y = "-" .. windowResizeIncrement,
  relative = true
}), { repeating = true, description = "resize window up" })

hl.bind("CTRL + SHIFT + J", hl.dsp.window.resize({
  x = "0",
  y = "+" .. windowResizeIncrement,
  relative = true
}), { repeating = true, description = "resize window down" })

-- center the layout -- only works on dwindle layout
hl.bind("CTRL + SHIFT + I", hl.dsp.layout("splitratio 1.0 exact"),
  { description = "center the split" })

--- window opacity ---
local window_opacities = {}

local function adjust_active_opacity(amount)
    local win = hl.get_active_window()
    if not win or not win.address then return end

    -- Fetch recorded opacity or default to 1.0
    local current = window_opacities[win.address] or 1.0
    local new_opacity = math.max(0.1, math.min(1.0, current + amount))
    
    -- Save the state
    window_opacities[win.address] = new_opacity

    hl.dispatch(hl.dsp.window.set_prop({ 
        window = "address:" .. win.address, 
        prop = "opacity", 
        value = tostring(new_opacity) 
    }))
    hl.dispatch(hl.dsp.window.set_prop({ 
        window = "address:" .. win.address, 
        prop = "opacity_inactive", 
        value = tostring(new_opacity) 
    }))
end

hl.bind("CTRL + SHIFT + BRACKETLEFT", function()
  adjust_active_opacity(-windowOpacityIncrement)
end, { repeating = true, description = "decrease window opacity" })

hl.bind("CTRL + SHIFT + BRACKETRIGHT", function()
  adjust_active_opacity(windowOpacityIncrement)
end, { repeating = true, description = "increase window opacity" })


--- temporarily make window transparent ---
hl.bind("CTRL + SHIFT + O", function()
  hl.dispatch(hl.dsp.window.set_prop({prop = "opacity", value = 0.5}))
  hl.dispatch(hl.dsp.window.set_prop({prop = "no_blur", value = 1 }))
end, { description = "make window temporarily transparent" })

hl.bind("CTRL + SHIFT + O", function()
  adjust_active_opacity(0)
  hl.dispatch(hl.dsp.window.set_prop({prop = "no_blur", value = 0 }))
end, { release = true, description = "restore window opacity" })

--- saturation adjustment ---
local memory_saturation = 100
local function step_saturation(direction)

    -- Calculate increments natively using our memory pointer
    if direction == "up" then
        memory_saturation = memory_saturation + saturationIncrement
    elseif direction == "down" then
        memory_saturation = memory_saturation - saturationIncrement
    end

    -- Keep values bounded between 0% and 100%
    if memory_saturation > 100 then 
        memory_saturation = 100 
    elseif memory_saturation < 0 then 
        memory_saturation = 0 
    end
    saturation.set_saturation(memory_saturation)
end
--- Night time and sunlight monochrome modes ---
hl.bind("SUPER + SHIFT + N", function() saturation.toggle_night_mode() end, { description = "toggle night mode" })
hl.bind("SUPER + SHIFT + S", function() saturation.toggle_sunlight_mode() end, { description = "toggle sunlight mode" })
--- end saturation ---

-- media ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { description = "raise audio volume" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { description = "lower audio volume" })
hl.bind("XF86MonBrightnessUp", function() brightness.adjust("+") end, { description = "increase screen brightness" })
hl.bind("XF86MonBrightnessDown", function() brightness.adjust("-") end, { description = "decrease screen brightness" })
hl.bind("SUPER + XF86MonBrightnessUp", function() step_saturation("up") end, { repeating = true, description = "increase color saturation" })
hl.bind("SUPER + XF86MonBrightnessDown", function() step_saturation("down") end, { repeating = true, description = "decrease color saturation" })


-- Special Hidden Workspace ---
local pinned_history = {}
local float_history = {}

hl.bind("SUPER + X", function()
  local active_window = hl.get_active_window()
  if active_window.pinned then
    pinned_history[active_window.address] = true
    hl.dispatch(hl.dsp.window.pin({ window = active_window, action = "toggle" }))
  end
  if active_window.floating then
    float_history[active_window.address] = true
    hl.dispatch(hl.dsp.window.float({ window = active_window, action = "toggle" }))
  end
  hl.dispatch(hl.dsp.window.move({ workspace = "special:hidden", follow = false }))
end, { description = "move window to hidden workspace" })

hl.bind("SUPER + TAB", function()
  local sws = hl.get_workspace("special:hidden")
  if sws and not sws.active then
    hl.dispatch(hl.dsp.workspace.toggle_special("hidden"))
    hl.dispatch(hl.dsp.submap("hdn2"))
  end
end, { description = "toggle hidden workspace submap" })

local select_from_hidden = (function(ws_name)
  local sws = hl.get_workspace("special:" .. ws_name)
  if not sws or not sws.windows then
    hl.dispatch(hl.dsp.workspace.toggle_special(ws_name))
  elseif sws.active then
    active_window = hl.get_active_window()
    if pinned_history[active_window.address] then
      hl.dispatch(hl.dsp.window.pin({ window = active_window, action = "toggle" }))
    end
    if float_history[active_window.address] then
      hl.dispatch(hl.dsp.window.float({ window = active_window, action = "toggle" }))
    end
    hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
  end
  hl.dispatch(hl.dsp.submap("reset"))
end)

hl.bind("SUPER + RETURN", function()
  select_from_hidden("hidden")
end, { description = "select window from hidden workspace" })


local function is_cursor_in_window(window)
  local cursor = hl.get_cursor_pos()
  local at = window.at
  local size = window.size

  local inside_x = cursor.x >= at.x and cursor.x <= (at.x + size.x)
  local inside_y = cursor.y >= at.y and cursor.y <= (at.y + size.y)

  return inside_x and inside_y
end

hl.define_submap("hdn2", function()
  hl.bind("ESCAPE", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("hidden"))
    hl.dispatch(hl.dsp.submap("reset"))
  end, { description = "exit hidden workspace submap" })

  hl.bind("SUPER + TAB", hl.dsp.layout("focus right"), { description = "focus next hidden window" })
  hl.bind("SUPER + SHIFT + TAB", hl.dsp.layout("focus left"), { description = "focus previous hidden window" })
  
  hl.bind("SUPER + RETURN", function()
    select_from_hidden("hidden")
  end, { description = "restore selected hidden window" })

  hl.bind("mouse:272", function()
    local active_win = hl.get_active_window()
    if is_cursor_in_window(active_win) then
      select_from_hidden("hidden")
    end
  end, {
    mouse = true,
    click = true,
    description = "restore selected hidden window via mouse" })
end)

hl.define_submap("hdn_select", function()
  hl.bind("SUPER + SUPER_L", function()
    select_from_hidden("hidden")
  end, { release = true, description = "select window from hidden workspace" })
end)

--- special magic terminals ---

local function toggle_special_magic(magic_name)
  local windows = hl.get_windows()
  local magic_win = nil
  for _, win in ipairs(windows) do
        if win.class == "magic_" .. magic_name then
          magic_win = win
          break
        end
    end
    local active_workspace = hl.get_active_workspace()

    if magic_win then
        if magic_win.workspace ~= active_workspace then
            hl.dispatch(hl.dsp.window.move({ window = magic_win, workspace = "e+0", follow = true }))
            hl.dispatch(hl.dsp.focus({ window = magic_win }))
            -- move it to the bottom-right of the dwindle layout
            --hl.dispatch(hl.dsp.window.move({ window = magic_win, direction = "d" }))
            --hl.dispatch(hl.dsp.window.move({ window = magic_win, direction = "r" }))

            hl.dispatch(hl.dsp.layout("splitratio 0.3"))
        else
            hl.dispatch(hl.dsp.window.move({ window = magic_win, workspace = "special:magic_" .. magic_name, follow = false }))
        end
    else
        local tmux_cmd = "tmx2 new-session -A -s " .. magic_name
        hl.exec_cmd("foot -a magic_" .. magic_name .. " " .. tmux_cmd)
    end
end

hl.define_submap("terms", function()
  hl.bind("H", function()
    toggle_special_magic("home")
    hl.dispatch(hl.dsp.submap("reset"))
  end, { release = true, description = "toggle special magic terminal 'home'" })
  hl.bind("W", function()
    toggle_special_magic("work")
    hl.dispatch(hl.dsp.submap("reset"))
  end, { release = true, description = "toggle special magic terminal 'work'" })
end)

hl.bind("SUPER + T", function()
  hl.dispatch(hl.dsp.submap("terms"))
end)

    
--- layout switcher ---

local function exec_with_stdout(cmd)
  local handle = io.popen(cmd)
  if handle ~= nil then
      local ret = handle:read("*a"):gsub("\n$", "")
      handle:close()
      return ret
  end
  return ""
end

local last_layout_msg_id = ""

local layouts = { "dwindle", "master", "scrolling", "monocle" }
hl.bind("SUPER + W", function()
    local wa = hl.get_active_workspace()
    if not wa then return end
    local idx = 0
    for i, v in ipairs(layouts) do
        if v == wa.tiled_layout then
            idx = i
            break
        end
    end
    local next_idx = (idx % #layouts) + 1
    hl.workspace_rule({ 
        workspace = tostring(wa.id), 
        layout = layouts[next_idx] 
    })
    
    --local replace_str = "foo "
    --if last_layout_msg_id == "" then
    --else
    --  local replace_str = "-r " .. last_layout_msg_id .. " "
    --end

    --local cmd = string.format("notify-send " .. replace_str .. [[-p "Layout" "%s %s"]], replace_str, layouts[next_idx])
    --last_layout_msg_id = exec_with_stdout(cmd)
    --hl.exec_cmd('notify-send "' .. cmd .. '"')
end, { description = "Cycle workspace layout" })


-- 1. Trigger the passthrough submap entry
hl.bind("SUPER + ALT + ESCAPE", function()
    hl.dispatch(hl.dsp.submap("passthrough"))
end, { description = "Enter total keyboard passthrough mode" })

-- 2. Define the empty isolation box
hl.define_submap("passthrough", function()
    -- The ONLY keys captured by Hyprland in this state is escaping back to normal
    hl.bind("ESCAPE", function()
        hl.dispatch(hl.dsp.submap("reset"))
    end, { description = "Exit passthrough mode and restore window manager shortcuts" })
end)

-- Moves all windows from the current workspace to a target workspace
local function move_current_windows_to(target)
    local active_ws = hl.get_active_workspace()
    if not active_ws then return end
    
    local current_ws_id = tostring(active_ws.id)
    
    local windows = hl.get_windows()
    if not windows then return end

    for _, win in ipairs(windows) do
        if win.workspace and tostring(win.workspace.id) == current_ws_id then
            hl.dispatch(hl.dsp.window.move({
                follow = false,
                window = win,
                workspace = target
            }))
        end
    end
end

hl.bind("CTRL + SHIFT + ALT + 1", function()
    move_current_windows_to(1)
end, { description = "Move all windows from current workspace to workspace 1" })
hl.bind("CTRL + SHIFT + ALT + 2", function()
    move_current_windows_to(2)
end, { description = "Move all windows from current workspace to workspace 2" })
hl.bind("CTRL + SHIFT + ALT + 3", function()
    move_current_windows_to(3)
end, { description = "Move all windows from current workspace to workspace 3" })
hl.bind("CTRL + SHIFT + ALT + 4", function()
    move_current_windows_to(4)
end, { description = "Move all windows from current workspace to workspace 4" })

-- Safely swap the current workspace to the alternative monitor
hl.bind("CTRL + SHIFT + ALT + M", function()
    local active_ws = hl.get_active_workspace()
    if not active_ws then return end
    local current_mon = active_ws.monitor.name
    -- Determine the target monitor based on where you are currently looking
    -- If you are on the laptop screen (eDP-1), target the external monitor (DP-1), and vice-versa.
    -- TODO: don't hard code to DP-1 external. Look for a non-eDP-1 monitor dynamically
    local target_monitor = (current_mon == "eDP-1") and "DP-1" or "eDP-1"

      local notify_cmd = string.format(
        [[notify-send "current: %s"]], target_monitor)
      hl.exec_cmd(notify_cmd)
    -- Move the active workspace to the other monitor output
    hl.dispatch(hl.dsp.workspace.move({ 
        monitor = target_monitor
    }))
end, { description = "Swap active workspace to the other monitor" })


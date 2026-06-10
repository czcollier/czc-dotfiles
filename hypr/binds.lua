local brightness = require("brightness")
local saturation = require("lib/saturation")

-- ==========================================
-- Bindings
--
-- In general, but not strictly:
-- focus: SUPER + <key>
-- workspace related: add CTRL + <key>
-- window movement: add SHIFT + <key>
-- utilitiy: SUPER + ALT + <key>
-- ==========================================
local noctalia_ipc = "noctalia-shell ipc call"
local windowResizeIncrement = 60
local windowOpacityIncrement = 0.05
local saturationIncrement = 10

--- utilities - typically SUPER + ALT .. ---
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill())
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("/usr/bin/hyprlock"))
--hl.bind("SUPER + ALT + T", hl.dsp.exec_cmd("~/.config/hypr/scripts/hdrop.sh foot -a foot_drop"))
hl.bind("SUPER + ALT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd(noctalia_ipc .. " plugin openPanel clipboard"))

hl.bind("SUPER + ALT + M",
  hl.dsp.exec_cmd(
    "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"),
    { long_press = true })

--- mouse ---
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + CTRL + mouse:272", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + mouse:273", hl.dsp.focus({ workspace = "e+1" }))

hl.bind("SUPER + SHIFT + mouse:272", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + mouse:273", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + mouse_down", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + SHIFT + mouse_up", hl.dsp.window.move({ direction = "up" }))
-- window focus --
hl.bind("SUPER + CTRL + SHIFT + mouse:272", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER + CTRL + SHIFT + mouse:273", hl.dsp.window.move({ workspace = "+1" }))

hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))

function horiz_focus(direction)
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

hl.bind("SUPER + L", function() horiz_focus("right") end)
hl.bind("SUPER + H", function() horiz_focus("left") end)

--- alt-tab approximation ---
hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())    -- Change focus to another window
    hl.dispatch(hl.dsp.window.bring_to_top()) -- Bring it to the top
end)

--- workspace focus ---
hl.bind("SUPER + CTRL + H", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + L", hl.dsp.focus({ workspace = "e+1" }))

hl.bind("SUPER + CTRL + 7", hl.dsp.focus({ workspace = "1" }))
hl.bind("SUPER + CTRL + 8", hl.dsp.focus({ workspace = "2" }))
hl.bind("SUPER + CTRL + 9", hl.dsp.focus({ workspace = "3" }))
hl.bind("SUPER + CTRL + 0", hl.dsp.focus({ workspace = "4" }))

--- move windows within workspace ---
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "up" }))

hl.bind("SUPER + T", hl.dsp.exec_cmd( "foot" ))
hl.bind("SUPER + D", hl.dsp.exec_cmd( "gedit" ))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(noctalia_ipc .. " launcher toggle"))

--- move windows between workspaces ---
hl.bind("SUPER + CTRL + SHIFT + H", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER + CTRL + SHIFT + L", hl.dsp.window.move({ workspace = "+1" }))

hl.bind("SUPER + CTRL + SHIFT + 7", hl.dsp.window.move({ workspace = "1" }))
hl.bind("SUPER + CTRL + SHIFT + 8", hl.dsp.window.move({ workspace = "2" }))
hl.bind("SUPER + CTRL + SHIFT + 9", hl.dsp.window.move({ workspace = "3" }))
hl.bind("SUPER + CTRL + SHIFT + 0", hl.dsp.window.move({ workspace = "4" }))

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
end)
hl.bind("SUPER + SHIFT + P", hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ action= "toggle", mode = "fullscreen" }))

--- dwindle layout bindings ---
hl.bind("SUPER + S", hl.dsp.layout("togglesplit"))

--- scrolling layout bindings ---
hl.bind("SUPER + F", hl.dsp.layout("fit visible"))
hl.bind("SUPER + MINUS", hl.dsp.layout("colresize -conf"))
hl.bind("SUPER + EQUAL", hl.dsp.layout("colresize +conf"))

--- Groups ---
hl.bind("SUPER + G", hl.dsp.group.toggle())
hl.bind("SUPER + I", hl.dsp.submap("group"))
hl.bind("SUPER + O", hl.dsp.window.move({ out_of_group = true }))
hl.bind("SUPER + N", hl.dsp.group.next())
hl.bind("SUPER + P", hl.dsp.group.prev())
hl.bind("SUPER + U", hl.dsp.group.lock_active())

hl.define_submap("group", "reset", function()
  hl.bind("H", hl.dsp.window.move({ into_group = "left" }))
  hl.bind("J", hl.dsp.window.move({ into_group = "down" })) -- Bring it to the top
  hl.bind("K", hl.dsp.window.move({ into_group = "up" })) -- Bring it to the top
  hl.bind("L", hl.dsp.window.move({ into_group = "right" })) -- Bring it to the top
  hl.bind("escape", hl.dsp.submap("reset"))
end)

--- Window Resizing ---
hl.bind("CTRL + SHIFT + L", hl.dsp.window.resize({
  x = "+".. windowResizeIncrement,
  y = "0",
  relative = true
}), { repeating = true })

hl.bind("CTRL + SHIFT + H", hl.dsp.window.resize({
  x = "-" .. windowResizeIncrement,
  y = "0",
  relative = true
}), { repeating = true })

hl.bind("CTRL + SHIFT + K", hl.dsp.window.resize({
  x = "0",
  y = "-" .. windowResizeIncrement,
  relative = true
}), { repeating = true })

hl.bind("CTRL + SHIFT + J", hl.dsp.window.resize({
  x = "0",
  y = "+" .. windowResizeIncrement,
  relative = true
}), { repeating = true })

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
end, { repeating = true })

hl.bind("CTRL + SHIFT + BRACKETRIGHT", function()
  adjust_active_opacity(windowOpacityIncrement)
end, { repeating = true })


--- temporarily make window transparent ---
hl.bind("CTRL + SHIFT + O", function()
  hl.dispatch(hl.dsp.window.set_prop({prop = "opacity", value = 0.5}))
  hl.dispatch(hl.dsp.window.set_prop({prop = "no_blur", value = 1 }))
end)

hl.bind("CTRL + SHIFT + O", function()
  adjust_active_opacity(0)
  hl.dispatch(hl.dsp.window.set_prop({prop = "no_blur", value = 0 }))
end, { release = true })

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


-- Media ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86MonBrightnessUp", function() brightness.adjust("+") end)
hl.bind("XF86MonBrightnessDown", function() brightness.adjust("-") end)
hl.bind("SUPER + XF86MonBrightnessUp", function() step_saturation("up") end, { repeating = true })
hl.bind("SUPER + XF86MonBrightnessDown", function() step_saturation("down") end, { repeating = true })
--- end saturation ---

--- Night time monochrome mode ---
hl.bind("SUPER + SHIFT + N", function() saturation.toggle_night_mode() end)

-- Special Hidden Workspace ---
hl.bind("SUPER + CTRL + X", hl.dsp.window.move({
  workspace = "special:hidden", follow = false }))

hl.bind("SUPER + TAB", function()
  sws = hl.get_workspace("special:hidden")
  if sws and not sws.active then
    hl.dispatch(hl.dsp.workspace.toggle_special("hidden"))
    hl.dispatch(hl.dsp.submap("hdn2"))
  end
end)

local select_from_hidden = (function(ws_name)
  sws = hl.get_workspace("special:" .. ws_name)
  if not sws or not sws.windows then
    hl.dispatch(hl.dsp.workspace.toggle_special(ws_name))
  elseif sws.active then
    hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
  end
  hl.dispatch(hl.dsp.submap("reset"))
end)
hl.bind("SUPER + RETURN", function()
  select_from_hidden("hidden")
end)

hl.define_submap("hdn2", function()
  hl.bind("SUPER + ESCAPE", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("hidden"))
    hl.dispatch(hl.dsp.submap("reset"))
  end)

  hl.bind("SUPER + TAB", hl.dsp.layout("focus right"))
  hl.bind("SUPER + SHIFT + TAB", hl.dsp.layout("focus left"))
  
  --hl.bind("SUPER + TAB", function()
  --  local cmd = string.format(noctalia_ipc .. [[ toast send '{"title": "Foo", "body": "bar", "duration": 1000}']])
  --  hl.exec_cmd(cmd)
  --end, { release = true })

  hl.bind("SUPER + RETURN", function()
    select_from_hidden("hidden")
  end)

  hl.bind("SUPER + SHIFT + mouse:272", function()
    select_from_hidden("hidden")
  end)
end)

hl.define_submap("hdn_select", function()
  hl.bind("SUPER + SUPER_L", function()
    select_from_hidden("hidden")
  end, { release = true })
end)

--- special magic terminal ---
function toggle_special_magic(magic_name)
  windows = hl.get_windows()
  magic_win = nil
  for _, win in ipairs(windows) do
        if win.class == "magic_" .. magic_name then
          magic_win = win
          break
        end
    end
    if magic_win then
        if magic_win.workspace ~= hl.get_active_workspace() then
            hl.dispatch(hl.dsp.window.move({ window = magic_win, workspace = "e+0", follow = true }))
            hl.dispatch(hl.dsp.focus({ window = magic_win }))
            hl.dispatch(hl.dsp.layout("splitratio 0.3"))
        else
            hl.dispatch(hl.dsp.window.move({ window = magic_win, workspace = "special:magic_" .. magic_name, follow = false }))
        end
    else
        --hl.dispatch(hl.dsp.workspace.toggle_special("magic" .. magic_name))
        --hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
        --hl.dispatch(hl.dsp.window.move({ workspace = "e+0", follow = true }))
        --hl.dispatch(hl.dsp.focus({ window = magic_win }))
        local tmux_cmd = "tmux new-session -A -s " .. magic_name
        hl.exec_cmd("foot -a magic_" .. magic_name .. " " .. tmux_cmd)
        --hl.dispatch(hl.dsp.layout("splitratio 0.7"))
    end
end


hl.bind("SUPER + ALT + Y", function() toggle_special_magic("home") end)
hl.bind("SUPER + ALT + T", function() toggle_special_magic("work") end)


--- layout switcher ---
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
    local cmd = string.format(noctalia_ipc .. [[ toast send '{"title": "Layout", "body": "%s", "duration": 1000}']], layouts[next_idx])
    hl.exec_cmd(cmd)
end, { description = "Cycle workspace layout" })

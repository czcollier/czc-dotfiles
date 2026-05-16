-- ==========================================
-- Bindings
-- ==========================================
local mainMod = "SUPER"
local ipc = "noctalia-shell ipc call"

--- utilities ---
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " +SHIFT + Q", hl.dsp.window.kill())
hl.bind("CONTROL + SHIFT + M", hl.dsp.exec_cmd("/usr/bin/hyprlock"))
hl.bind(mainMod .. " + ALT + T", hl.dsp.exec_cmd("~/.config/hypr/scripts/hdrop.sh foot -a foot_drop"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))

hl.bind(mainMod .. " + CTRL + ALT + M",
  hl.dsp.exec_cmd(
    "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"),
    { long_press = true })

hl.bind(mainMod .. " + SHIFT + CTRL + P", hl.dsp.exec_cmd("~/scripts/panelctl.sh toggle"))

-- Move/resize windows with mainMod + LMB, mainMod + SHIFT + LMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Focus --
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd( "foot" ))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd( "gedit" ))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(ipc .. " launcher toggle"))

--- float and center active window ---
hl.bind(mainMod .. " + SHIFT + Space", function()
  hl.dispatch(hl.dsp.window.float())
  hl.dispatch(hl.dsp.window.resize({
    x = hl.get_active_monitor().width * 0.4,
    y = hl.get_active_monitor().height * 0.9,
    relative = false
  }))
  hl.dispatch(hl.dsp.window.center())
end)

--- Focus ---
hl.bind(mainMod .. " + CTRL + H", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = "1" }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = "2" }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = "3" }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "4" }))

hl.bind(mainMod .. " + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())    -- Change focus to another window
    hl.dispatch(hl.dsp.window.bring_to_top()) -- Bring it to the top
end)

--- Move windows ---
hl.bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ workspace = "+1" }))

hl.bind(mainMod .. " + CTRL + SHIFT + 7", hl.dsp.window.move({ workspace = "1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + 8", hl.dsp.window.move({ workspace = "2" }))
hl.bind(mainMod .. " + CTRL + SHIFT + 9", hl.dsp.window.move({ workspace = "3" }))
hl.bind(mainMod .. " + CTRL + SHIFT + 0", hl.dsp.window.move({ workspace = "4" }))

-- Media ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86MonBrightnessUp", function() brightness.adjust("+") end)
hl.bind("XF86MonBrightnessDown", function() brightness.adjust("-") end)

--- Groups ---
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + I", hl.dsp.submap("group"))
hl.bind(mainMod .. " + O", hl.dsp.window.move({ out_of_group = true }))
hl.bind(mainMod .. " + N", hl.dsp.group.next())
hl.bind(mainMod .. " + P", hl.dsp.group.prev())
hl.bind(mainMod .. " + U", hl.dsp.group.lock_active())

hl.define_submap("group", "reset", function()
  hl.bind("H", hl.dsp.window.move({ into_group = "left" }))
  hl.bind("J", hl.dsp.window.move({ into_group = "down" })) -- Bring it to the top
  hl.bind("K", hl.dsp.window.move({ into_group = "up" })) -- Bring it to the top
  hl.bind("L", hl.dsp.window.move({ into_group = "right" })) -- Bring it to the top
  hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Special Hidden Workspace ---
hl.bind("ALT + TAB", function()
  sws = hl.get_workspace("special:hidden")
  if sws and not sws.active then
    hl.dispatch(hl.dsp.workspace.toggle_special("hidden"))
    hl.dispatch(hl.dsp.submap("hdn2"))
  end
end)

hl.define_submap("hdn2", function()
  hl.bind("ESCAPE", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("hidden"))
    hl.dispatch(hl.dsp.submap("reset"))
  end)

  hl.bind("ALT + TAB", hl.dsp.focus({ direction = "right" }))
  hl.bind("ALT + SHIFT + TAB", hl.dsp.focus({ direction = "left" }))

  hl.bind(mainMod .. " + RETURN", function()
    sws = hl.get_workspace("special:hidden")
    if not sws or not sws.windows then
      hl.dispatch(hl.dsp.workspace.toggle_special("hidden"))
    elseif sws.active then
      hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
    end
    hl.dispatch(hl.dsp.submap("reset"))
  end)
end)

-- Special Hidden Workspace ---
hl.bind(mainMod .. " + ALT + T", function()
  --sws = hl.get_workspace("special:term")
  --if sws and not sws.active then
    hl.dispatch(hl.dsp.workspace.toggle_special("term"))
    hl.dispatch(hl.dsp.submap("hdn_term"))
  --end
end)

hl.define_submap("hdn_term", function()
  hl.bind(mainMod .. " + ESCAPE", function()
    hl.dispatch(hl.dsp.workspace.toggle_special("term"))
    hl.dispatch(hl.dsp.submap("reset"))
  end)
end)

hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + CTRL + X", hl.dsp.window.move({
  workspace = "special:hidden", follow = false }))

--- Window Resizing ---
hl.bind("CTRL + SHIFT + L", hl.dsp.window.resize({
  x = "+20",
  y = "0",
  relative = true,
  repeating = true
}))

hl.bind("CTRL + SHIFT + H", hl.dsp.window.resize({
  x = "-20",
  y = "0",
  relative = true,
  repeating = true
}))

hl.bind("CTRL + SHIFT + K", hl.dsp.window.resize({
  x = "0",
  y = "-20",
  relative = true,
  repeating = true
}))

hl.bind("CTRL + SHIFT + J", hl.dsp.window.resize({
  x = "0",
  y = "+20",
  relative = true,
  repeating = true
}))

--- Window Opacity
hl.bind(mainMod .. " + BRACKETLEFT", hl.dsp.window.set_prop({
  prop = "opacity",
  value = "0.7",
  relative = true
})) 

hl.bind(mainMod .. " + BRACKETRIGHT", hl.dsp.window.set_prop({
  prop = "opacity",
  value = "1.0",
  relative = true
})) 

hl.workspace_rule({
  workspace = "special:hidden",
  layout = "scrolling",
  gaps_in = "15",
  gaps_out = "300",
})

hl.workspace_rule({
  workspace = "special:term",
  -- layout = "scrolling",
  -- gaps_in = "0",
  -- gaps_out = "300",
  on_created_empty = "foot"
})

hl.workspace_rule({ workspace = "1", persistent = true })
hl.workspace_rule({ workspace = "2", persistent = true })
hl.workspace_rule({ workspace = "3", persistent = true })
hl.workspace_rule({ workspace = "4", persistent = true, layout = "scrolling" })

hl.window_rule {
    name = "magic_home",
    match = { 
      class = "magic_home"
    },
    opacity = 0.85,
    rounding = 2,
    no_anim = true,
    border_color = { colors = {"rgba(cc6699ee)", "rgba(cc9966ee)"}, angle = 45 },
}

hl.window_rule {
    name = "magic_work",
    match = { 
      class = "magic_work"
    },
    opacity = 0.85,
    rounding = 2,
    no_anim = true,
    border_color = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 }
}

hl.window_rule {
    name = "system_dialogs",
    match = { 
      class = "^xdg-desktop-portal-gtk$"
    },
    float = true,
    size = "900 700"
}

hl.window_rule {
    name = "image_viewer",
    match = {
      class = "org.gnome.Loupe"
    },
    float = true,
    size = "900 700"
}

hl.window_rule {
    name = "file_browser",
    match = {
      class = "org.gnome.Nautilus"
    },
    float = true,
    size = "900 700"
}

hl.window_rule {
    name = "upload_auth",
    match = {
      class = "chrome-pmhkaepabdniocnppdkfgifgonahhpdi-Profile_2"
    },
    float = true,
    fullscreen = false,
    size = "600 670"
}

hl.layer_rule {
  name = "noctalia",
  match = {
    namespace = "noctalia-background-.*$"
  },
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true
}

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.layout.register("columns", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 then
            return
        end

        for i, target in ipairs(ctx.targets) do
            target:place(ctx:column(i, n))
        end
    end,
})

hl.layout.register("work", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 then return end

        -- Identify our windows
        local chrome, cider, magic_foot = nil, nil, nil
        for _, target in ipairs(ctx.targets) do
            local win = target.window
            if win then
                if win.class == "google-chrome" then
                  chrome = target 
                elseif win.title and string.find(win.title, "^Cider") then
                  cider = target
                elseif win.class == "magic_foot" then
                  magic_foot = target
                end
            end
        end

        -- Define logic for splitting the space
        -- 1. Split the screen into Left (Chrome) and Right (Everything else)
        local left, right = ctx:split(ctx.area, 0.5)

        if chrome then chrome:place(left) end

        if cider then
            if magic_foot then
                -- 2. Split the Right side into Top (Cider) and Bottom (Magic Foot)
                local cider_area, foot_area = ctx:split(right, 0.7, "vertical")
                cider:place(cider_area)
                magic_foot:place(foot_area)
            else
                -- Just Cider
                cider:place(right)
            end
        end
    end,
})

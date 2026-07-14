
-- experimental custom layouts --

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
        local left, right = ctx:split(ctx.area, 'left', 0.5)

        if chrome then chrome:place(left) end

        if cider then
            if magic_foot then
                -- 2. Split the Right side into Top (Cider) and Bottom (Magic Foot)
                local cider_area, foot_area = ctx:split(ctx.area, 'right', 0.7)
                cider:place(cider_area)
                magic_foot:place(foot_area)
            else
                -- Just Cider
                cider:place(right)
            end
        end
    end,
})

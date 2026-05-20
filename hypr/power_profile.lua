-- Track state to avoid redundant reloads
local last_profile = ""

local shader_path = os.getenv("HOME") .. "/.config/hypr/shaders/grayscale.frag"

local profile_timer = hl.timer(function()
    -- Read the ThinkPad platform profile directly
    local file = io.open("/sys/firmware/acpi/platform_profile", "r")
    if not file then return end
    
    local current_profile = file:read("*l")
    file:close()
    
    -- Trim whitespace
    current_profile = current_profile and current_profile:match("^%s*(.-)%s*$")

    if current_profile ~= last_profile then
        last_profile = current_profile
        hl.notification.create({
          text = current_profile:gsub("^%l", string.upper) .. " mode active",
          timeout = 400,
          icon = "hint" })
        
        if current_profile == "low-power" then
            hl.config({
                decoration = {
                    shadow = { enabled = false },
                    -- glow = { enabled = false },
                    blur = { enabled = false },
                    -- screen_shader = shader_path
                },
                misc = { vrr = 0 },
                animations = { enabled = false }
            })
        else
            hl.config({
                decoration = {
                    shadow = { enabled = true },
                    -- glow = { enabled = false },
                    blur = { enabled = true },
                    --screen_shader = "" 
                },
                misc = { vrr = 1 },
                animations = { enabled = true }
            })
        end
    end
end, { timeout = 2000, type = "repeat" })

profile_timer:set_enabled(true)

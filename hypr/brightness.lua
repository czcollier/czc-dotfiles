local M = {}

function M.adjust(direction)
    -- We use concatenation to keep the shell command string clean and predictable
    local cmd = "FOCUS=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'); " ..
                "if [[ \"$FOCUS\" == \"eDP-1\" ]]; then " ..
                "brightnessctl set 5%" .. direction .. "; " ..
                "else " ..
                "ddcutil --bus 13 setvcp 10 " .. direction .. " 5 --noverify; " ..
                "fi"
    
    hl.exec(cmd)
end

return M

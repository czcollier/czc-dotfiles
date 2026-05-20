-- ~/.config/hypr/libs/saturation.lua
local M = {}
local shader_path = os.getenv("HOME") .. "/.config/hypr/shaders/dynamic_muted.frag"

-- Core implementation function that actually alters the system state
function M.set(pct)
    local active_shader = ""
    local message = ""

    if not pct or pct == 100 then
        active_shader = ""
        message = "Full Color"
    else
        if pct < 0 then pct = 0 elseif pct > 100 then pct = 100 end
        local saturation = pct / 100

        -- Generate the GLSL file on the fly
        local file = io.open(shader_path, "w")
        if file then
            file:write(string.format([[#version 300 es
precision mediump float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;
void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    float gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    // SAT_VALUE: %.2f
    vec3 mixedColor = mix(vec3(gray), pixColor.rgb, %.2f);
    fragColor = vec4(mixedColor, pixColor.a);
}]], saturation, saturation))
            file:close()
        end

        active_shader = shader_path
        message = (pct == 0) and "Monochrome" or string.format("Sat %d%%", pct)
    end

    -- Apply changes natively using whatever environment is calling it
    if hl and hl.config then
        -- We are running INSIDE Hyprland's resident memory loop
        hl.config({ decoration = { screen_shader = active_shader } })
        hl.notification.create({ text = message, timeout = 400, icon = "hint" })
        hl.exec_cmd("hyprctl dispatch damage")
        hl.exec_cmd("hyprctl dispatch workspace +0")
    else
        -- We are running OUTSIDE in a terminal shell; serialize a string payload back to hyprctl
        local payload = string.format([[
            hl.config({ decoration = { screen_shader = "%s" } })
            hl.notification.create({ text = "%s", timeout = 1500, icon = "hint" })
            hl.exec_cmd("hyprctl dispatch damage")
            hl.exec_cmd("hyprctl dispatch workspace +0")
        ]], active_shader, message)
        os.execute(string.format("hyprctl eval %q", payload))
    end
end

return M

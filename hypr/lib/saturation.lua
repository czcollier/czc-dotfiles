local M = {}

local noctalia_ipc = "noctalia msg "
local dynamic_shader = os.getenv("HOME") .. "/.config/hypr/shaders/dynamic_muted.frag"
local night_shader   = os.getenv("HOME") .. "/.config/hypr/shaders/night_mode.frag"
local sunlight_shader = os.getenv("HOME") .. "/.config/hypr/shaders/sunlight.frag"

-- Global tracking variable for our active mode state
M.mode = "color" -- "color", "muted", "night"
M.current_pct = 100

function M.apply_state(active_shader, message)
  if hl and hl.config then
    hl.config({ decoration = { screen_shader = active_shader } })

    -- Send a fast 500ms toast directly to Noctalia Shell's IPC framework
    --hl.dsp.exec_cmd(noctalia_ipc .. string.format([[noctalia-shell ipc call toast send '{"title": "Saturation", "body": "%s", "duration": 500}']], message))
    --hl.exec_cmd(cmd)
    hl.dsp.force_renderer_reload()
    hl.dsp.focus({ workspace = "+0" } )
  end
end

function M.set_saturation(pct)
  if pct < 0 then pct = 0 elseif pct > 100 then pct = 100 end
  M.current_pct = pct

  if pct == 100 then
    M.mode = "color"
    M.apply_state("", "Full Color (100%)")
  else
    M.mode = "muted"
    local saturation = pct / 100
    local file = io.open(dynamic_shader, "w")
    if file then
      file:write(string.format([[#version 300 es
      precision mediump float;
      in vec2 v_texcoord;
      layout(location = 0) out vec4 fragColor;
      uniform sampler2D tex;
      void main() {
        vec4 pixColor = texture(tex, v_texcoord);
        float gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
        vec3 mixedColor = mix(vec3(gray), pixColor.rgb, %.2f);
        fragColor = vec4(mixedColor, pixColor.a);
      }]], saturation))
      file:close()
    end
    M.apply_state(dynamic_shader, string.format("%d%%", pct))
  end
end


function M.toggle_night_mode()
  if M.mode == "night" then
    -- If already in night mode, restore whatever our previous slider percentage was
    M.set_saturation(M.current_pct)
  else
    M.mode = "night"
    M.apply_state(night_shader, "Night Reading Mode (Sepia)")
  end
end

function M.toggle_sunlight_mode()
  if M.mode == "sunlight" then
    M.set_saturation(M.current_pct)
  else
    M.mode = "sunlight"
    M.apply_state(sunlight_shader, "Sunlight High-Contrast Mode")
  end
end

return M



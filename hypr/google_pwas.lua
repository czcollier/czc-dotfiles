local M = {}

local work_profile = "Default"
local chrome_cmd = "/opt/google/chrome/google-chrome"

local pwa = {
    gmail = "fmgjjmmmlfnkbppncabfkddbjimcfncm",
    chat = "pommaclcbfghclhalboakcipcmmndhcj",
    calendar = "kjbdgfilnfhdoflbpgamdcdgpehopbep"
}

local pwa_regex = string.format("^chrome-(%s|%s|%s)-%s$", pwa.gmail, pwa.chat, pwa.calendar, work_profile)

hl.window_rule({
    match = {
        class = string.format("^chrome-(%s|%s|%s)-Default$", pwa.gmail, pwa.chat, pwa.calendar)
    },
    group = "set always lock invade"
})

-- Launch Google Apps
function M.launch_or_focus_pwas()
  hl.dispatch(hl.dsp.focus({window = string.format("class:%s", pwa_regex) }))
  local function launch_if_missing(app_id)
    local target_class = string.format("chrome-%s-Default", app_id)
    local shell_cmd = string.format(
        "sh -c 'if ! hyprctl clients | grep -q \"class: %s\"; then google-chrome --profile-directory=\"%s\" --app-id=%s; fi'", 
        target_class, work_profile, app_id
    )
    hl.dispatch(hl.dsp.exec_cmd(shell_cmd))
  end

  launch_if_missing(pwa.gmail)
  launch_if_missing(pwa.chat)
  launch_if_missing(pwa.calendar)
end

return M

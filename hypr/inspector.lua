
-- ~/.config/hypr/inspector.lua

-- Define the module table
local M = {}

-- Change the function to accept 'target_table' as an explicit parameter
local function dump_table(tbl, file_handle, indent)
    indent = indent or ""
    if tbl == nil then
        file_handle:write(indent .. "[Inspector] This table is nil or empty!\n")
        return
    end
    
    for k, v in pairs(tbl) do
        local type_str = type(v)
        if type_str == "table" then
            file_handle:write(indent .. k .. " (table):\n")
            dump_table(v, file_handle, indent .. "  ")
        else
            file_handle:write(indent .. k .. " (" .. type_str .. ")\n")
        end
    end
end

-- Wrap the execution inside an exported setup function
function M.inspect_plugin(target_table)
    local output_path = os.getenv("HOME") .. "/.config/hypr/plugin_dump.txt"

    -- Official Hyprland Lua timer structure
    hl.timer(function()
        local f = io.open(output_path, "w")
        if f then
            f:write("--- [START] HYPRSPACE PLUGIN TABLE DUMP ---\n")
            dump_table(target_table, f)
            f:write("--- [END] HYPRSPACE PLUGIN TABLE DUMP ---\n")
            f:close()
            
            hl.notification.create({ 
                text = "Hyprspace keys successfully dumped to plugin_dump.txt!", 
                timeout = 4000 
            })
        else
            hl.notification.create({ text = "Failed to write dump!", timeout = 4000 })
        end
    end, { timeout = 2000, type = "oneshot" })
end

return M

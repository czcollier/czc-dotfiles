local M = {}

function M.write_to_file(str, filename)
  local f = io.open(filename, "w")
  if f ~= nil then
      f:write(str)
      f:close()
  end
end

function M.inspectTable(tbl, indent)
    indent = indent or ""
    if type(tbl) ~= "table" then return tostring(tbl) end
    
    local result = "{\n"
    for k, v in pairs(tbl) do
        local formatting = indent .. "  [" .. tostring(k) .. "] = "
        if type(v) == "table" then
            result = result .. formatting .. M.inspectTable(v, indent .. "  ") .. ",\n"
        elseif type(v) == "string" then
            result = result .. formatting .. string.format("%q", v) .. ",\n"
        else
            result = result .. formatting .. tostring(v) .. ",\n"
        end
    end
    return result .. indent .. "}"
end

return M

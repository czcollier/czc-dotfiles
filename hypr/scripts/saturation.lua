#!/usr/bin/env lua5.4

-- Add our custom libs folder to the package path check
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/hypr/lib/?.lua"
local saturation = require("saturation")

local val = arg[1]
if not val then
    print("Usage: saturation.lua [0-100 | color]")
    os.exit(1)
end

if val == "color" then
    saturation.set(100)
else
    local target_num = tonumber(val)
    if not target_num then
        print("Error: Argument must be a numeric value.")
        os.exit(1)
    end
    saturation.set(target_num)
end

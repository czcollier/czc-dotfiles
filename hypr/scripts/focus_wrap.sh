#!/bin/bash

# Usage: ./focus_wrap.sh [l|r]
dir=$1
# Map direction to group movement: 'f' (forward/right), 'b' (backward/left)
[[ "$dir" == "r" ]] && group_dir="f" || group_dir="b"

# 1. Get the address of the window before moving
old_addr=$(hyprctl activewindow -j | jq -r '.address')

# 2. Attempt to move within the group
hyprctl dispatch changegroupactive "$group_dir"

# 3. Get the address after the attempt
new_addr=$(hyprctl activewindow -j | jq -r '.address')

# 4. If the address is the same, we've hit the end of the group (or it's not a group)
if [ "$old_addr" == "$new_addr" ]; then
    hyprctl dispatch movefocus "$dir"
fi

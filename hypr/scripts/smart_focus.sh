#!/bin/bash

# Usage: ./smart_focus.sh [l|r]
DIR=$1

# Get window data in JSON
WIN_DATA=$(hyprctl activewindow -j)
IS_GROUPED=$(echo "$WIN_DATA" | jq '.grouped | length > 0')

if [ "$IS_GROUPED" = "false" ]; then
    hyprctl dispatch movefocus "$DIR"
    exit 0
fi

# Get the list of windows in the current group
GROUP_LIST=$(echo "$WIN_DATA" | jq -r '.grouped[]')
# Get the address of the current active window
CURRENT_ADDR=$(echo "$WIN_DATA" | jq -r '.address')

# Convert group list to an array to check boundaries
readarray -t ADDR_ARRAY <<< "$GROUP_LIST"
LEN=${#ADDR_ARRAY[@]}

# Find the index of the current window
for i in "${!ADDR_ARRAY[@]}"; do
   if [[ "${ADDR_ARRAY[$i]}" == "$CURRENT_ADDR" ]]; then
       INDEX=$i
       break
   fi
done

if [[ "$DIR" == "r" ]]; then
    if [[ $INDEX -eq $((LEN - 1)) ]]; then
        # At the last tab, move out to the right
        hyprctl dispatch movefocus r
    else
        # Not at the end, move to next tab
        hyprctl dispatch changegroupactive f
    fi
elif [[ "$DIR" == "l" ]]; then
    if [[ $INDEX -eq 0 ]]; then
        # At the first tab, move out to the left
        hyprctl dispatch movefocus l
    else
        # Not at the start, move to previous tab
        hyprctl dispatch changegroupactive b
    fi
fi

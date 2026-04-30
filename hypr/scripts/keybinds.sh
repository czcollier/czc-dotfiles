#!/bin/bash

CONFIG="$HOME/.config/hypr/hyprland.conf"

# The AWK script below handles the heavy lifting
BINDS=$(grep -E '^bind' "$CONFIG" | \
    sed -e 's/^bind[m]*\s*=\s*//g' | \
    awk -F, 'BEGIN {
        # --- DEFINE YOUR ALIASES HERE ---
        map["wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"] = "Volume Up"
        map["wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"] = "Volume Down"
        map["swaylock"] = "Lock Screen"
        map["hyprshot -m output"] = "Screenshot"
        map["kitty"] = "Terminal"
        # --------------------------------
    }
    {
        # 1. Clean up columns
        gsub(/^[ \t]+|[ \t]+$/, "", $1); # Mod
        gsub(/^[ \t]+|[ \t]+$/, "", $2); # Key
        gsub(/^[ \t]+|[ \t]+$/, "", $3); # Dispatcher
        
        # 2. Rebuild the command/argument string
        cmd = $3;
        for(i=4; i<=NF; i++) cmd = cmd " " $i;
        gsub(/^[ \t]+|[ \t]+$/, "", cmd);
        
        # 3. Clean "exec" out of the command for cleaner mapping/display
        display_cmd = cmd;
        gsub(/^exec\s+/, "", display_cmd);
        
        # 4. Check if we have an alias, otherwise use the cleaned command
        final_label = (map[display_cmd] != "") ? map[display_cmd] : display_cmd;
        
        # 5. Format: Label (Left), Binding (Right)
        # Using 30 chars for label padding
        printf "<b>%-30s</b> %s+%s\\n", final_label, $1, $2
    }' | \
    sed 's/\"/\\\"/g')

echo "{\"text\": \"⌨️\", \"tooltip\": \"<tt>$BINDS</tt>\"}"

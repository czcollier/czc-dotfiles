#!/usr/bin/env bash

# CONFIGURATION: Check if your path is LID or LID0
LID_PATH="/proc/acpi/button/lid/LID/state"
INTERNAL_SCREEN="eDP-1"

# Function to ensure we are communicating with the active Hyprland instance
refresh_signature() {
    local latest_dir
    latest_dir=$(ls -t "$XDG_RUNTIME_DIR/hypr" | head -n 1)
    if [ -n "$latest_dir" ]; then
        export HYPRLAND_INSTANCE_SIGNATURE="$latest_dir"
    fi
}

# Moves all active workspaces to the target monitor
move_workspaces_to() {
    local target=$1
    refresh_signature
    
    local ws_json
    ws_json=$(hyprctl workspaces -j)
    
    if echo "$ws_json" | jq -e . >/dev/null 2>&1; then
        echo "$ws_json" | jq -r '.[].id' | while read -r ws; do
            # Only move numeric workspaces
            if [[ "$ws" =~ ^-?[0-9]+$ ]]; then
                hyprctl dispatch moveworkspacetomonitor "$ws" "$target"
            fi
        done
    fi
}

# Main Clamshell Logic
clamshell_logic() {
    refresh_signature
    
    # Check if an external monitor is connected
    local ext_mon
    ext_mon=$(hyprctl monitors -j | jq -r '.[] | select(.name != "'$INTERNAL_SCREEN'") | .name' | head -n 1)

    if grep -q "closed" "$LID_PATH"; then
        # If lid is closed AND an external monitor exists, disable internal
        if [ -n "$ext_mon" ] && [ "$ext_mon" != "null" ]; then
            hyprctl keyword monitor "$INTERNAL_SCREEN, disable"
        fi
    else
        # If lid is open, ensure internal screen is enabled
        hyprctl keyword monitor "$INTERNAL_SCREEN, preferred, auto, 1"
    fi
}

# Listener handle for socket events
handle() {
    case $1 in
        monitoradded*)
            sleep 1 # Wait for hardware handshake
            clamshell_logic # Check if we should disable eDP-1 immediately
            
            # Move workspaces to the new monitor
            local new_mon
            new_mon=$(hyprctl monitors -j | jq -r '.[] | select(.name != "'$INTERNAL_SCREEN'") | .name' | head -n 1)
            if [ -n "$new_mon" ]; then
                move_workspaces_to "$new_mon"
            fi
            ;;
        monitorremoved*)
            # If external monitor leaves, always restore the internal one
            hyprctl keyword monitor "$INTERNAL_SCREEN, preferred, auto, 1"
            move_workspaces_to "$INTERNAL_SCREEN"
            ;;
    esac
}

# --- Execution Logic ---

# 1. Handle direct trigger from bindl (Lid Switch)
if [[ "$1" == "--clamshell" ]]; then
    clamshell_logic
    exit 0
fi

# 2. Startup/Reload logic
# This ensures that when you save your config, the screen turns back off if the lid is closed
clamshell_logic

# 3. Start Event Listener
SOCKET_PATH=$(find "$XDG_RUNTIME_DIR/hypr" -name ".socket2.sock" | head -n 1)

if [ -z "$SOCKET_PATH" ]; then
    echo "Error: Hyprland socket not found."
    exit 1
fi

# Listen for monitor changes indefinitely
#socat -u UNIX-CONNECT:"$SOCKET_PATH",cloexec STDOUT | while IFS= read -r line; do
#    handle "$line"
#done

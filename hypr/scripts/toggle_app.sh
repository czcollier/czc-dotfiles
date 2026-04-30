#!/bin/bash

# Usage: ./toggle_app.sh <app_command> <window_class> <workspace_name>
# Example: ./toggle_app.sh "pavucontrol" "org.pulseaudio.pavucontrol" "audio"

APP_CMD=$1
CLASS=$2
WORKSPACE=$3

# Check if the app is already running by looking for its window class
# We use jq to parse hyprctl's JSON output for reliability
#RUNNING=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$CLASS\") | .address")

#if [ -z "$RUNNING" ]; then
    # App is not running: launch it
#    hyprctl dispatch exec "[workspace special:$WORKSPACE] $APP_CMD"
#else
    # App is running: toggle the special workspace it lives in
#    hyprctl dispatch togglespecialworkspace "$WORKSPACE"
#fi


if [[ -z $(hyprctl workspaces | grep special:$WORKSPACE) ]]; then
    hyprctl dispatch movetoworkspacesilent special:$WORKSPACE
else
    hyprctl --batch "dispatch togglespecialworkspace $WORKSPACE;dispatch movetoworkspace +0"
fi

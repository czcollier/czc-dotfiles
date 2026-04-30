#!/usr/bin/env bash

# This listens to the Hyprland event socket for switch events
handle() {
  case $1 in
    "switch>>Lid Switch,1") hyprctl keyword monitor "eDP-1, preferred, auto, 1" ;;
    "switch>>Lid Switch,0") hyprctl keyword monitor "eDP-1, disable" ;;
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done

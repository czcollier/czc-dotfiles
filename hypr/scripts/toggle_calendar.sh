#!/bin/bash

# The class we found earlier for GNOME Calendar
IFACE="org.gnome.Calendar"

# Check if the process is running at all
if ! pgrep -x "gnome-calendar" > /dev/null; then
    gnome-calendar &
    exit 0
fi

# If it is running, toggle the special workspace
hyprctl dispatch togglespecialworkspace calendar

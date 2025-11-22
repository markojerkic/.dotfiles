#!/bin/bash

# Get battery info from solaar
output=$(solaar show 2>/dev/null)

# Extract device names and battery percentages
mouse_battery=$(echo "$output" | grep -A20 "MX Master 3S" | grep "Battery:" | head -1 | grep -oP '\d+(?=%)')
keyboard_battery=$(echo "$output" | grep -A20 "MX Mechanical Mini" | grep "Battery:" | head -1 | grep -oP '\d+(?=%)')

# Default icons
mouse_icon="󰍽"
keyboard_icon="󰌌"

# Generate output
text=""
tooltip=""

if [ -n "$keyboard_battery" ]; then
    text="$keyboard_icon $keyboard_battery%"
    tooltip="Keyboard: $keyboard_battery%"
fi

if [ -n "$mouse_battery" ]; then
    if [ -n "$text" ]; then
        text="$text  $mouse_icon $mouse_battery%"
        tooltip="$tooltip\nMouse: $mouse_battery%"
    else
        text="$mouse_icon $mouse_battery%"
        tooltip="Mouse: $mouse_battery%"
    fi
fi

# Determine CSS class based on lowest battery
lowest_battery=$keyboard_battery
if [ -n "$mouse_battery" ] && [ -z "$keyboard_battery" ]; then
    lowest_battery=$mouse_battery
elif [ -n "$mouse_battery" ] && [ -n "$keyboard_battery" ]; then
    lowest_battery=$(( mouse_battery < keyboard_battery ? mouse_battery : keyboard_battery ))
fi

class="normal"
if [ -n "$lowest_battery" ]; then
    if [ "$lowest_battery" -le 10 ]; then
        class="critical"
    elif [ "$lowest_battery" -le 20 ]; then
        class="warning"
    fi
fi

# Output JSON for Waybar
if [ -n "$text" ]; then
    echo "{\"text\":\"$text\",\"tooltip\":\"$tooltip\",\"class\":\"$class\"}"
else
    echo "{\"text\":\"\",\"tooltip\":\"No Logitech devices found\",\"class\":\"hidden\"}"
fi

#!/usr/bin/env bash

STATE_FILE="/tmp/polybar_battery_state"
[ ! -f "$STATE_FILE" ] && echo "short" > "$STATE_FILE"

# Toggle display mode on click
if [ "$1" = "toggle" ]; then
    if [ "$(cat "$STATE_FILE")" = "short" ]; then
        echo "full" > "$STATE_FILE"
    else
        echo "short" > "$STATE_FILE"
    fi
fi

# Detect battery and AC adapter dynamically
BAT=$(ls /sys/class/power_supply/ | grep -E '^BAT' | head -n 1)
AC=$(ls /sys/class/power_supply/ | grep -E '^AC|^ADP' | head -n 1)

[ -z "$BAT" ] && exit 0

CAPACITY=$(cat /sys/class/power_supply/$BAT/capacity 2>/dev/null || echo "0")
STATUS=$(cat /sys/class/power_supply/$BAT/status 2>/dev/null || echo "Discharging")

AC_ONLINE=0
if [ -n "$AC" ] && [ -f "/sys/class/power_supply/$AC/online" ]; then
    AC_ONLINE=$(cat /sys/class/power_supply/$AC/online)
fi

# Get remaining time from acpi
TIME=""
if command -v acpi &>/dev/null; then
    TIME=$(acpi -b 2>/dev/null | grep -oP '\d\d:\d\d:\d\d' | head -n 1 | cut -d: -f1,2)
fi

# Select capacity icon
if [ "$CAPACITY" -le 20 ]; then RAMP="▁"
elif [ "$CAPACITY" -le 40 ]; then RAMP="▂"
elif [ "$CAPACITY" -le 60 ]; then RAMP="▃"
elif [ "$CAPACITY" -le 80 ]; then RAMP="▅"
else RAMP="█"; fi

# Update icon immediately if charging
if [ "$STATUS" = "Charging" ] || [ "$AC_ONLINE" -eq 1 ]; then
    ICON="⚡ "
else
    ICON="$RAMP "
fi

# Output string
if [ "$(cat "$STATE_FILE")" = "full" ] && [ -n "$TIME" ]; then
    echo "${ICON}${CAPACITY}% - ${TIME}"
else
    echo "${ICON}${CAPACITY}%"
fi

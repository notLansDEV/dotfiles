#!/usr/bin/env bash

# Listen for ac_adapter and battery status events from the kernel
acpi_listen | while read -r event; do
    if echo "$event" | grep -qE "ac_adapter|battery"; then
        # Force Polybar to trigger hook-0 immediately
        polybar-msg action "#battery.hook.0" >/dev/null 2>&1
    fi
done

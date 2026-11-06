#!/bin/bash
# Toggle Hypridle
if pgrep -x "hypridle" > /dev/null; then
    killall hypridle
    notify-send "Hypridle" "❌ Disabled"
else
    hypridle &
    notify-send "Hypridle" "✅ Enabled"
fi

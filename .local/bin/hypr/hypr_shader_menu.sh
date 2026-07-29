#!/usr/bin/env bash
set -euo pipefail

command -v fuzzel >/dev/null || { echo "fuzzel not found"; exit 1; }

SHADER_DIR="$HOME/.config/hypr/shaders"

# List shader files (without .glsl)
mapfile -t SHADERS < <(find "$SHADER_DIR" -maxdepth 1 -name "*.glsl" -exec basename {} .glsl \; | sort)

# If no shaders found, show error
if [ ${#SHADERS[@]} -eq 0 ]; then
    notify-send "Shader Menu" "No shaders found in $SHADER_DIR" 2>/dev/null
    exit 1
fi

# Add "off" at top
SHADERS=("off" "${SHADERS[@]}")

# Show menu
CHOICE=$(printf "%s\n" "${SHADERS[@]}" | fuzzel --dmenu --prompt "Shader: ")

[[ -z "$CHOICE" ]] && exit 0

# Apply using hyprctl directly
if [[ "$CHOICE" == "off" ]]; then
    hyprctl keyword decoration:screen_shader ""
else
    hyprctl keyword decoration:screen_shader "$SHADER_DIR/$CHOICE.glsl"
fi

notify-send "Shader Menu" "Applied: $CHOICE" 2>/dev/null

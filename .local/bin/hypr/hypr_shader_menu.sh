#!/usr/bin/env bash
set -uo pipefail

command -v fuzzel >/dev/null || { echo "fuzzel not found"; exit 1; }

SHADER_DIR="$HOME/.config/hypr/shaders"
REAL_SHADER_DIR="/home/me/.dotfiles/.config/hypr/shaders"   # resolved symlink target

mapfile -t SHADERS < <(find -L "$SHADER_DIR" -maxdepth 1 -name "*.glsl" -exec basename {} .glsl \; | sort)

if [ ${#SHADERS[@]} -eq 0 ]; then
    notify-send "Shader Menu" "No shaders found in $SHADER_DIR" 2>/dev/null
    exit 1
fi

SHADERS=("off" "${SHADERS[@]}")

CHOICE=$(printf "%s\n" "${SHADERS[@]}" | fuzzel --dmenu --prompt "Shader: ") || exit 0
[[ -z "$CHOICE" ]] && exit 0

if [[ "$CHOICE" == "off" ]]; then
    hyprctl eval 'hl.config({ decoration = { screen_shader = "" } })'
else
    hyprctl eval "hl.config({ decoration = { screen_shader = \"$REAL_SHADER_DIR/$CHOICE.glsl\" } })"
fi

notify-send "Shader Menu" "Applied: $CHOICE" 2>/dev/null

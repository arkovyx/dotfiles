#!/bin/sh

case "$(printf "a selected area (copy)\ncurrent window (copy)\nfull screen (copy)\na selected area (ss)\na selected area (kl)\ncurrent window (ss)\ncurrent window (mpv)\na selected area (mpv)" | fuzzel -d -l 8 -i -p "Screenshot which area?")" in
    "a selected area (copy)") hyprshot -m region --clipboard-only ;;
    "current window (copy)") hyprshot -m window --clipboard-only ;;
    "full screen (copy)") hyprshot -m output --clipboard-only ;;

    "a selected area (ss)") mkdir -p ~/pix/ss && hyprshot -m region -o ~/pix/ss -f "pic-selected-$(uuidgen | awk -F- '{printf $2}')-$(date '+%y-%m-%d').png" ;;
    "a selected area (kl)") mkdir -p ~/pix/ss/kl && hyprshot -m region -o ~/pix/ss/kl -f "pic-selected-$(uuidgen | awk -F- '{printf $2}')-$(date '+%y-%m-%d').png" ;;
    "current window (ss)") mkdir -p ~/pix/ss && hyprshot -m window -o ~/pix/ss -f "pic-window-$(uuidgen | awk -F- '{printf $2}')-$(date '+%y-%m-%d').png" ;;
    "current window (mpv)") mkdir -p ~/pix/ss/mpv && hyprshot -m window -o ~/pix/ss/mpv -f "pic-window-$(uuidgen | awk -F- '{printf $2}')-$(date '+%y-%m-%d').png" ;;
    "a selected area (mpv)") mkdir -p ~/pix/ss/mpv && hyprshot -m region -o ~/pix/ss/mpv -f "pic-selected-$(uuidgen | awk -F- '{printf $2}')-$(date '+%y-%m-%d').png" ;;
esac

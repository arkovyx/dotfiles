#!/usr/bin/env bash

trap 'echo -e "\n[ERROR] Interrupted"; exit 130' INT

INSTALL_STATUS="none"
AUTO_YES=0
DRY_RUN=0
START_TIME=$(date +%s)
START_DATE=$(date '+%Y-%m-%d %H:%M:%S')

for arg in "$@"; do
    case "$arg" in
        --yes|--ci|--non-interactive)
            AUTO_YES=1
            ;;
        --dry-run|--test|--dry)
            DRY_RUN=1
            echo -e "\033[0;33m⚠ DRY RUN MODE — No changes will be made\033[0m"
            echo ""
            ;;
    esac
done

# Colors
GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Banner
clear
echo -e "${BRIGHT_GREEN}"
cat << "EOF"
    █████╗ ██████╗  ██████╗██╗  ██╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗
   ██╔══██╗██╔══██╗██╔════╝██║  ██║    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║
   ███████║██████╔╝██║     ███████║    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║
   ██╔══██║██╔══██╗██║     ██╔══██║    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║
   ██║  ██║██║  ██║╚██████╗██║  ██║    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗████████╗
   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═══════╝
EOF
echo -e "${RESET}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${CYAN}  🚀 Arch Linux Dotfiles Installer  |  ${START_DATE}${RESET}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

if [[ $DRY_RUN -eq 1 ]]; then
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${YELLOW}║  🔍 DRY RUN MODE — This is a simulation. No changes will be made. ║${RESET}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
fi

log() {
    local level="$1"; shift
    case "$level" in
        INFO)    color="$CYAN" ;;
        WARN)    color="$YELLOW" ;;
        ERROR)   color="$RED" ;;
        SUCCESS) color="$BRIGHT_GREEN" ;;
        *)       color="$RESET" ;;
    esac
    echo -e "${color}[${level}]${RESET} $*"
}

confirm() {
    local msg="$1"
    if [[ $AUTO_YES -eq 1 ]]; then
        log INFO "[auto] $msg → yes"
        return 0
    fi
    if [[ $DRY_RUN -eq 1 ]]; then
        log INFO "[dry-run] $msg → simulating yes"
        return 0
    fi
    gum confirm --default=false "$msg"
}

if [[ "$EUID" -eq 0 ]]; then
    log ERROR "This script must NOT be run as root."
    exit 1
fi

DISCLAIMER=$(gum style \
  --border double \
  --border-foreground 46 \
  --padding "1 2" \
  --bold \
"⚠️  DISCLAIMER

This script modifies system files and may overwrite or delete existing configs.
Backup ~/.config and ~/.local before proceeding.

Proceed at your OWN RISK."
)

confirm "$DISCLAIMER

Do you understand the risks and want to continue?" || exit 1

log INFO "Installing prerequisites: "
if [[ $DRY_RUN -eq 1 ]]; then
    log INFO "[dry-run] Would install: stow gum git zsh"
else
    sudo pacman -S --needed --noconfirm stow gum git zsh
fi

currentDir="$(dirname "$(readlink -f "$0")")"
cd "$currentDir" || exit 1

source "$currentDir/packages/pkg_utils.sh" 2>/dev/null || log WARN "pkg_utils.sh not found"
source "$currentDir/packages/pkg_dev_tools.sh" 2>/dev/null || log WARN "pkg_dev_tools.sh not found"
source "$currentDir/packages/pkg_optional.sh" 2>/dev/null || log WARN "pkg_optional.sh not found"
source "$currentDir/packages/pkg_gpu.sh" 2>/dev/null || log WARN "pkg_gpu.sh not found"
source "$currentDir/packages/pkg_aur.sh" 2>/dev/null || log WARN "pkg_aur.sh not found"
source "$currentDir/packages/pkg_desktop.sh" 2>/dev/null || log WARN "pkg_desktop.sh not found"

if confirm "Proceed with system configuration (stow, shell)?"; then
    if [[ $DRY_RUN -eq 1 ]]; then
        log INFO "[dry-run] Would stow dotfiles with --no-folding"
    else
        log INFO "Detecting conflicts..."
        conflicts=$(stow . --no-folding -nv 2>&1 | sed -n 's/.*existing target \(.*\) since neither.*/\1/p')
        if [[ -z "$conflicts" ]]; then
            log INFO "No conflicts. Running stow..."
            stow . --no-folding && log SUCCESS "Dotfiles stowed successfully" || log ERROR "Stow failed"
        else
            log WARN "These paths conflict and will be removed:"
            printf '  %s\n' $conflicts
            read -rp "Proceed with deleting these files? (y/N): " ok
            if [[ "$ok" =~ ^[Yy]$ ]]; then
                for path in $conflicts; do
                    [[ -n "$path" && "$path" != "/" ]] && rm -rf "$HOME/$path" && log INFO "Deleted $path"
                done
                stow . --no-folding && log INFO "Dotfiles stowed with overwrite." || log ERROR "Stow failed"
            else
                log WARN "Aborted."
                exit 1
            fi
        fi
    fi

    log INFO "Changing default shell to ZSH"
    if [[ $DRY_RUN -eq 1 ]]; then
        log INFO "[dry-run] Would change shell to zsh"
    elif [[ "$SHELL" != "$(command -v zsh)" ]]; then
        chsh -s "$(which zsh)" && log SUCCESS "Shell set to zsh" || log ERROR "Could not set shell"
    else
        log INFO "zsh is already the default shell"
    fi
else
    log ERROR "Aborted stow. Exiting."
    exit 1
fi

ALL_PKGS=(
    "${DEV_PKGS[@]}"
    "${OPTIONAL_PKGS[@]}"
    "${GPU_PKGS[@]}"
    "${UTILITY_PKGS[@]}"
    "${AUR_PKGS[@]}"
    "${pkg_desktop[@]}"
)

if [[ ${#ALL_PKGS[@]} -gt 0 ]]; then
    if confirm "Install all the selected packages?"; then
        log INFO "Installing selected packages..."
        if [[ $DRY_RUN -eq 1 ]]; then
            log INFO "[dry-run] Would install: ${ALL_PKGS[*]}"
        else
            if ! command -v paru >/dev/null 2>&1; then
                log INFO "Installing Paru (AUR helper)"
                git clone https://aur.archlinux.org/paru.git
                (cd paru && makepkg -sri)
                rm -rf paru
            fi
            if paru -Syu --needed "${ALL_PKGS[@]}"; then
                INSTALL_STATUS="complete"
            else
                INSTALL_STATUS="failed"
            fi
        fi
    else
        log WARN "Package installation skipped"
        INSTALL_STATUS="partial"
    fi
else
    log WARN "No packages selected"
    INSTALL_STATUS="partial"
fi

if command -v keyd >/dev/null 2>&1; then
    if confirm "Configure and enable keyd?"; then
        if [[ $DRY_RUN -eq 1 ]]; then
            log INFO "[dry-run] Would setup keyd"
        else
            log INFO "Setting up keyd..."
            sudo cp "$currentDir/system/etc/keyd/default.conf" /etc/keyd/
            sudo systemctl enable --now keyd.service && log SUCCESS "keyd enabled" || log ERROR "keyd setup failed"
        fi
    fi
fi

# Timer
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
HOURS=$((ELAPSED / 3600))
MINUTES=$(((ELAPSED % 3600) / 60))
SECONDS=$((ELAPSED % 60))

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${RESET}"
echo -e "${BRIGHT_GREEN}  ✅ COMPLETED IN: ${HOURS}h ${MINUTES}m ${SECONDS}s${RESET}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${RESET}"
echo ""

if [[ $DRY_RUN -eq 1 ]]; then
    echo -e "${YELLOW}⚠ This was a DRY RUN. No changes were made.${RESET}"
    echo -e "${YELLOW}  Remove --dry-run flag to execute for real.${RESET}"
    echo ""
fi

case "$INSTALL_STATUS" in
    complete)
        gum style --border rounded --border-foreground 46 --padding "1 2" --bold \
        "✔ Installation Complete!
All selected packages were installed successfully.
You may now reboot the system for all the changes to apply."
        ;;
    partial)
        gum style --border rounded --border-foreground 220 --padding "1 2" --bold \
        "⚠ Setup Finished (Partial)
Some steps were skipped."
        ;;
    failed)
        gum style --border rounded --border-foreground 196 --padding "1 2" --bold \
        "❌ Installation Failed
Check the logs above."
        ;;
    *)
        gum style --bold "Finished."
        ;;
esac

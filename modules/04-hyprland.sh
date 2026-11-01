#!/usr/bin/env bash
# Module: 04-hyprland - Hyprland completo con keybindings Omarchy-style

log_step "Installing Hyprland + ecosystem"

HYPRLAND_PKGS=(
    hyprland
    hyprland-protocols
    hyprcursor
    hyprgraphics
    hypridle
    hyprlock
    hyprpicker
    hyprpolkitagent
    hyprshot
    hyprsunset
    hyprwayland-scanner
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
)

pacman_install "${HYPRLAND_PKGS[@]}"

# ─── Dotfiles Hyprland (stow) ──────────────────────────────────
log_step "Deploying Hyprland dotfiles"
stow_dotfiles hypr

# ─── Configuración dinámica desde kalaos.conf ───────────────────
# Se genera en 07-theming.sh junto con colors
# Aquí solo aseguramos que el directorio existe
run_cmd "mkdir -p \$HOME/.config/hypr" "Hyprland config dir"

log_ok "Hyprland module completed"
#!/usr/bin/env bash
# Module: 06-bar - Waybar + rofi/wofi + swaync + theming

log_step "Installing bar & launcher stack"

BAR_PKGS=(
    waybar
    rofi-wayland
    wofi
    swaync
    swayosd
    grim
    slurp
    swappy
    cliphist
    wl-clipboard
    brightnessctl
    playerctl
    pamixer
    network-manager-applet
    blueman
    power-profiles-daemon
    upower
)

pacman_install "${BAR_PKGS[@]}"

# ─── Dotfiles Waybar + Rofi + Wofi + SwayNC ────────────────────
log_step "Deploying bar/launcher configs"
stow_dotfiles waybar
stow_dotfiles rofi
stow_dotfiles wofi
stow_dotfiles swaync

# ─── Waybar config base (colores dinámicos en 07-theming) ──────
run_cmd "mkdir -p \$HOME/.config/waybar" "Waybar config dir"

cat > /home/jairo/kalaos/dotfiles/waybar/config.jsonc <<'WAYBAR_CONFIG_EOF'
{
    "layer": "top",
    "position": "top",
    "height": 32,
    "spacing": 4,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "bluetooth", "battery", "tray", "power"],

    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{icon}",
        "format-icons": {
            "1": "1", "2": "2", "3": "3", "4": "4", "5": "5",
            "6": "6", "7": "7", "8": "8", "9": "9", "10": "10",
            "active": "●", "inactive": "○", "urgent": "◎"
        }
    },

    "hyprland/window": {
        "format": "{}",
        "max-length": 50
    },

    "clock": {
        "format": "{}",
        "format-alt": "🐱 %H:%M",
        "tooltip-format": "%A, %d %B %Y",
        "interval": 1
    },

    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-bluetooth": "{volume}% 🎧",
        "format-muted": "🔇",
        "format-icons": {
            "headphone": "🎧",
            "hands-free": "🎧",
            "headset": "🎧",
            "phone": "📱",
            "portable": "🎧",
            "car": "🚗",
            "default": ["🔈", "🔉", "🔊"]
        },
        "on-click": "pavucontrol"
    },

    "network": {
        "format": "{icon}",
        "format-wifi": "📶 {signalStrength}%",
        "format-ethernet": "🌐",
        "format-disconnected": "❌",
        "tooltip-format": "{ifname}: {ipaddr}"
    },

    "bluetooth": {
        "format": "{icon}",
        "format-on": "🔵",
        "format-off": "⚫",
        "format-connected": "🟢 {name}"
    },

    "battery": {
        "format": "{capacity}% {icon}",
        "format-charging": "⚡ {capacity}%",
        "format-plugged": "🔌 {capacity}%",
        "format-icons": ["🔋", "🔋", "🔋", "🔋", "🔋"],
        "threshold": 20
    },

    "tray": {
        "icon-size": 16,
        "spacing": 4
    },

    "power": {
        "format": "⏻",
        "on-click": "wlogout"
    }
}
WAYBAR_CONFIG_EOF

cat > /home/jairo/kalaos/dotfiles/waybar/style.css <<'WAYBAR_STYLE_EOF'
/* KalaOS Waybar Style - Colors injected by theming module */
@import "colors-waybar.css";

* {
    border: none;
    border-radius: 0;
    font-family: "SF Pro Display", "JetBrains Mono Nerd Font";
    font-size: 12px;
    min-height: 0;
}

window#waybar {
    background: @background;
    color: @foreground;
    border-bottom: 1px solid @border;
}

#workspaces button {
    padding: 0 8px;
    color: @foreground-muted;
    transition: all 0.2s;
}

#workspaces button.active {
    color: @accent-red;
    background: @surface;
    border-radius: 6px;
}

#workspaces button:hover {
    background: @surface-hover;
    color: @foreground;
}

#clock {
    padding: 0 12px;
    color: @accent-purple;
    font-weight: 600;
}

#pulseaudio, #network, #bluetooth, #battery, #tray, #power {
    padding: 0 10px;
    color: @foreground;
}

#pulseaudio:hover, #network:hover, #bluetooth:hover, #battery:hover {
    background: @surface-hover;
    border-radius: 6px;
}

#power {
    color: @accent-red;
    font-size: 16px;
}

#power:hover {
    background: @accent-red;
    color: @background;
    border-radius: 6px;
}

#tray menu * {
    background: @background;
    color: @foreground;
}
WAYBAR_STYLE_EOF

# ─── Rofi config ──────────────────────────────────────────────
cat > /home/jairo/kalaos/dotfiles/rofi/config.rasi <<'ROFI_CONFIG_EOF'
/* KalaOS Rofi Config - Theme injected by theming module */
@theme "kalaos-theme"

configuration {
    show-icons: true;
    icon-theme: "kalaos-icons";
    font: "SF Pro Display 11";
    drun-display-format: "{name} [{generic}]";
    terminal: "ghostty";
    ssh-client: "ghostty -e ssh";
    run-command: "{cmd} &";
    run-shell-command: "{terminal} -e {cmd}";
    match-alg: "fzf";
    sort: true;
    sidebar-mode: false;
}
ROFI_CONFIG_EOF

# ─── Wofi config ──────────────────────────────────────────────
cat > /home/jairo/kalaos/dotfiles/wofi/config <<'WOFI_CONFIG_EOF'
# KalaOS Wofi Config
gtk_theme = kalaos-gtk
font = SF Pro Display 11
allow_markup = true
show_icons = true
icon_theme = kalaos-icons
WOFI_CONFIG_EOF

# ─── SwayNC config ────────────────────────────────────────────
cat > /home/jairo/kalaos/dotfiles/swaync/config.json <<'SWAYNC_CONFIG_EOF'
{
    "positionX": "right",
    "positionY": "top",
    "layer": "overlay",
    "control-center-layer": "overlay",
    "cssPriority": "application",
    "notification-visible-time": 5000,
    "notification-body-text-size": 12,
    "notification-title-text-size": 13,
    "notification-icon-size": 48,
    "widgets": ["title", "notifications"],
    "widget-config": {
        "title": {
            "text": "Notifications",
            "clear-all-button": true,
            "button-text": "Clear"
        }
    }
}
SWAYNC_CONFIG_EOF

# ─── Servicios ─────────────────────────────────────────────────
enable_service swaync

log_ok "Bar module completed"
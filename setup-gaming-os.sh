#!/bin/bash
# CachyOS Gaming Setup Script
# Clean installation script for a minimal, gaming-optimized Hyprland setup
# Inspired by Omarchy but without bloatware

set -e  # Exit on any error

echo "=========================================="
echo "  CachyOS Gaming Setup Script"
echo "  Clean, minimal, gaming-optimized"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "[1/8] Updating system packages..."
pacman -Syu --noconfirm

echo ""
echo "[2/8] Installing base development tools..."
pacman -S --noconfirm base-devel git curl wget

echo ""
echo "[3/8] Installing Hyprland and dependencies..."
pacman -S --noconfirm hyprland kitty waybar rofi-wayland \
    polkit-kde-agent sddm qt5-wayland qt6-wayland \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    brightnessctl pavucontrol pipewire pipewire-pulse pipewire-alsa \
    wireplumber networkmanager network-manager-applet \
    blueman bluez bluez-utils \
    gvfs mtpfs udisk2 \
    grim slurp swappy \
    wl-clipboard \
    fastfetch neofetch htop btop \
    unzip p7zip \
    firefox

echo ""
echo "[4/8] Installing gaming-related packages..."
pacman -S --noconfirm steam lutris heroic-games-launcher \
    mangohud gamemode goverlay \
    vulkan-radeon vulkan-intel vulkan-nouveau \
    lib32-vulkan-radeon lib32-vulkan-intel lib32-vulkan-nouveau \
    mesa lib32-mesa \
    dxvk-nvapi vkd3d-proton \
    wine-staging winetricks \
    protonup-qt

echo ""
echo "[5/8] Installing Quickshell..."
# Quickshell from AUR (using yay or paru, or build manually)
if ! command -v yay &> /dev/null; then
    echo "Installing yay AUR helper..."
    pacman -S --noconfirm --needed base-devel git
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd /tmp
    rm -rf yay
fi

yay -S --noconfirm quickshell

echo ""
echo "[6/8] Creating user configuration directories..."
# Get the actual user (not root)
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
else
    REAL_USER=$(who | awk '{print $1}' | head -1)
fi

USER_HOME="/home/$REAL_USER"

mkdir -p "$USER_HOME/.config/hypr"
mkdir -p "$USER_HOME/.config/quickshell"
mkdir -p "$USER_HOME/.config/kitty"
mkdir -p "$USER_HOME/.config/waybar"
mkdir -p "$USER_HOME/.config/rofi"

echo ""
echo "[7/8] Configuring Hyprland (Omarchy-like)..."

# Hyprland configuration
cat > "$USER_HOME/.config/hypr/hyprland.conf" << 'EOF'
# Hyprland Configuration - Omarchy-inspired, minimal

# Environment variables
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
env = XDG_SESSION_TYPE,wayland
env = XDG_CURRENT_DESKTOP,Hyprland

# Monitor configuration (auto-detect)
# monitor=,highrr,auto,1

# Input settings
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = true
        tap-to-click = true
    }
}

# General settings
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# Decorations
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 2
    }
    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animations
animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, myBezier, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 80, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Window rules
windowrule = float, title:(Open File|Save As|File Upload)
windowrule = center, title:(Open File|Save As|File Upload)

# Keybindings - Omarchy-like
# Mod key is SUPER (Windows key)
$mainMod = SUPER

# Launch applications
bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, D, exec, rofi -show drun
bind = $mainMod, B, exec, firefox
bind = $mainMod, Q, killactive,
bind = $mainMod, F, fullscreen, 0
bind = $mainMod SHIFT, F, fullscreen, 1

# Move focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Move windows
bind = $mainMod SHIFT, left, movewindow, l
bind = $mainMod SHIFT, right, movewindow, r
bind = $mainMod SHIFT, up, movewindow, u
bind = $mainMod SHIFT, down, movewindow, d

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Special workspaces (scratchpads)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

# Screenshot tools
bind = $mainMod SHIFT, P, exec, grim -g "$(slurp)" - | swappy -f -
bind = $mainMod, P, exec, grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png
bind = $mainMod, PRINT, exec, grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png

# Audio controls
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Brightness controls
bind = , XF86MonBrightnessUp, exec, brightnessctl set +10%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 10%-

# Lock screen
bind = $mainMod, L, exec, hyprlock

# Resize windows
bind = $mainMod, R, exec, hyprctl dispatch resizeactive 10% 10%

# Scroll through windows
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Misc
bind = $mainMod, V, exec, wl-paste | rofi -dmenu -p "Clipboard"
bind = $mainMod SHIFT, E, exec, rofi -show emoji -modi emoji
bind = $mainMod, T, exec, kitty --title floatterm
bind = $mainMod SHIFT, Q, exit

# Game mode - disable animations when game is running
# (Can be triggered by game-specific window rules)

EOF

echo ""
echo "[8/8] Configuring Quickshell..."

# Quickshell configuration (Omarchy-like bar)
cat > "$USER_HOME/.config/quickshell/shell.qml" << 'EOF'
import Quickshell
import Quickshell.Io
import Quickshell.Surfaces
import Quickshell.Wayland
import Quickshell.Widgets

import "widgets"

Shell {
    id: root

    // Color scheme - Omarchy inspired
    property color primary: "#33ccff"
    property color secondary: "#00ff99"
    property color bg: "#1a1a1a"
    property color fg: "#ffffff"

    WaylandSurface {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        layer: WlrLayer.Top
        exclusive: true
        visible: true

        Rectangle {
            anchors.fill: parent
            color: root.bg

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                // Workspace indicator
                Rectangle {
                    width: 150
                    height: parent.height
                    color: "transparent"

                    Text {
                        text: "Workspaces: 1 2 3 4 5"
                        color: root.fg
                        anchors.centerIn: parent
                    }
                }

                // Taskbar / Active windows
                Rectangle {
                    width: 300
                    height: parent.height
                    color: "transparent"

                    Text {
                        text: "Active Windows"
                        color: root.fg
                        anchors.centerIn: parent
                    }
                }

                // System tray
                Rectangle {
                    width: 100
                    height: parent.height
                    color: "transparent"

                    Text {
                        text: "System Tray"
                        color: root.fg
                        anchors.centerIn: parent
                    }
                }

                // Clock
                Rectangle {
                    width: 150
                    height: parent.height
                    color: "transparent"

                    Text {
                        text: Qt.formatTime(new Date(), "hh:mm")
                        color: root.fg
                        anchors.centerIn: parent
                        font.bold: true
                    }
                }
            }
        }
    }
}
EOF

# Kitty terminal config
cat > "$USER_HOME/.config/kitty/kitty.conf" << 'EOF'
# Kitty Configuration
font_family JetBrains Mono
font_size 12
foreground #ffffff
background #1a1a1a
cursor #33ccff
selection_background #33ccff
selection_foreground #1a1a1a

# Keybindings
map ctrl+shift+enter new_window
map ctrl+shift+w close_window
map ctrl+shift+] next_window
map ctrl+shift+[ previous_window
map ctrl+shift+enter new_tab
map ctrl+shift+q close_tab
map ctrl+shift+. next_tab
map ctrl+shift+, previous_tab

# Scrollback
scrollback_lines 10000
EOF

# Waybar configuration
cat > "$USER_HOME/.config/waybar/config.jsonc" << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 40,
    "modules-left": ["hyprland/workspaces", "tray"],
    "modules-center": ["hyprland/window"],
    "modules-right": ["pulseaudio", "network", "battery", "clock"],
    
    "hyprland/workspaces": {
        "format": "{icon}",
        "format-icons": {
            "1": "1",
            "2": "2",
            "3": "3",
            "4": "4",
            "5": "5",
            "6": "6",
            "7": "7",
            "8": "8",
            "9": "9",
            "10": "10",
            "active": "●",
            "default": "○"
        },
        "on-click": "activate"
    },
    
    "tray": {
        "icon-size": 20,
        "spacing": 10
    },
    
    "clock": {
        "format": "{:%H:%M}",
        "tooltip": true,
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
    
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-bluetooth": "{icon} {volume}%",
        "format-muted": "🔇",
        "format-icons": {
            "headphone": "🎧",
            "hands-free": "📞",
            "headset": "🎧",
            "phone": "📞",
            "portable": "📱",
            "car": "🚗",
            "default": ["🔈", "🔉", "🔊"]
        },
        "on-click": "pavucontrol"
    },
    
    "network": {
        "format-wifi": "📶 {signalStrength}%",
        "format-ethernet": "🔗",
        "format-disconnected": "❌",
        "tooltip": true,
        "tooltip-format-wifi": "📶 {essid}\nStrength: {signalStrength}%",
        "tooltip-format-ethernet": "🔗 Connected",
        "on-click": "nm-connection-editor"
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-icons": ["🪫", "🔋"],
        "format-full": "🔋 100%",
        "format-charging": "⚡ {capacity}%"
    }
}
EOF

# Waybar style
cat > "$USER_HOME/.config/waybar/style.css" << 'EOF'
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrains Mono", monospace;
    font-size: 14px;
    min-height: 0;
}

window#waybar {
    background: rgba(26, 26, 26, 0.95);
    color: #ffffff;
}

#workspaces {
    background: transparent;
}

#workspaces button {
    padding: 0 10px;
    color: #ffffff;
    background: transparent;
}

#workspaces button.active {
    color: #33ccff;
    background: rgba(51, 204, 255, 0.2);
}

#workspaces button:hover {
    background: rgba(255, 255, 255, 0.1);
}

#tray {
    padding: 0 10px;
}

#clock {
    padding: 0 15px;
    color: #33ccff;
    font-weight: bold;
}

#pulseaudio {
    padding: 0 10px;
}

#network {
    padding: 0 10px;
}

#battery {
    padding: 0 10px;
}

#battery.warning {
    color: #ffcc00;
}

#battery.critical {
    color: #ff0000;
}
EOF

# Rofi configuration
cat > "$USER_HOME/.config/rofi/config.rasi" << 'EOF'
configuration {
    modi: "drun,run,window,emoji";
    show-icons: true;
    icon-theme: "Papirus";
    font: "JetBrains Mono 12";
    display-drun: "Apps";
    display-run: "Run";
    display-window: "Windows";
    drun-display-format: "{name}";
    disable-history: false;
    sidebar-mode: false;
}

@theme "style"
EOF

cat > "$USER_HOME/.config/rofi/style.rasi" << 'EOF'
* {
    bg-col: #1a1a1a;
    bg-col-light: #2a2a2a;
    border-col: #33ccff;
    selected-col: #33ccff;
    blue: #33ccff;
    green: #00ff99;
    fg-col: #ffffff;
    fg-col2: #33ccff;
    grey: #555555;
    grey2: #333333;
    width: 600;
}

window {
    height: 400px;
    border: 2px;
    border-color: @border-col;
    background-color: @bg-col;
}

mainbox {
    background-color: transparent;
}

inputbar {
    children: [prompt,entry];
    background-color: @bg-col-light;
    border-radius: 5px;
    padding: 2px;
}

prompt {
    background-color: @blue;
    padding: 5px;
    text-color: @bg-col;
    border-radius: 3px;
    margin: 2px;
}

textbox {
    background-color: transparent;
    padding: 5px;
    text-color: @fg-col;
}

entry {
    padding: 5px;
    margin: 2px;
    text-color: @fg-col;
    background-color: transparent;
    cursor: text;
}

listview {
    border: 0px 0px 0px;
    padding: 5px 0px;
    margin: 5px 0px 0px 0px;
    columns: 1;
    lines: 8;
    background-color: transparent;
    text-color: @fg-col;
}

element {
    padding: 5px;
    background-color: transparent;
    text-color: @fg-col;
    cursor: pointer;
}

element-icon {
    size: 24px;
    cursor: pointer;
    margin: 0px 5px 0px 0px;
}

element-text {
    cursor: pointer;
    vertical-align: 0.5;
}

element selected {
    background-color: @selected-col;
    text-color: @bg-col;
}
EOF

# Enable and configure services
echo ""
echo "Enabling system services..."
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable sddm

# Gaming optimizations
echo ""
echo "Applying gaming optimizations..."

# Create sysctl config for gaming
cat > /etc/sysctl.d/99-gaming.conf << 'EOF'
# Gaming optimizations
vm.swappiness = 1
vm.vfs_cache_pressure = 50
kernel.nice = -5
EOF

# Create limits config for gaming
cat > /etc/security/limits.d/99-gaming.conf << 'EOF'
# Gaming optimizations
@users - nice -5
@users - rtprio 95
@users - memlock unlimited
EOF

# GameMode configuration
mkdir -p "$USER_HOME/.config"
cat > "$USER_HOME/.config/gamemode.ini" << 'EOF'
[general]
renice=15

[cpu]
governor=performance

[gpu]
apply_gpu_optimisations=accept-responsibility

[custom]
start=export MANGOHUD=1
EOF

# Set ownership
chown -R $REAL_USER:$REAL_USER "$USER_HOME/.config"

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Reboot your system"
echo "2. Login and Hyprland will start automatically"
echo "3. Press SUPER+D to open the application launcher"
echo "4. Press SUPER+RETURN to open a terminal"
echo "5. Press SUPER+L to lock the screen"
echo ""
echo "Gaming features installed:"
echo "- Steam, Lutris, Heroic Games Launcher"
echo "- MangoHud, GameMode, GOverlay"
echo "- Vulkan drivers and DXVK"
echo "- Wine and Proton support"
echo ""
echo "Enjoy your clean, gaming-optimized setup!"
echo ""

#!/usr/bin/env bash
# Module: 09-login - LightDM (GTK display manager, official repos)

log_step "Configuring LightDM login"

pacman_install lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings

# ─── LightDM config ──────────────────────────────────────────────
run_cmd "mkdir -p /etc/lightdm" "LightDM config dir"

cat > /etc/lightdm/lightdm.conf <<'LIGHTDM_EOF'
[LightDM]
run-directory=/run/lightdm

[Seat:*]
greeter-session=lightdm-gtk-greeter
autologin-user-timeout=0
user-session=hyprland

[VNCServer]
enabled=false
LIGHTDM_EOF

# ─── GTK Greeter config (KalaOS theme) ───────────────────────────
cat > /etc/lightdm/lightdm-gtk-greeter.conf <<'GREETER_EOF'
[greeter]
# Theme
theme-name = Adwaita-dark
icon-theme-name = Papirus-Dark
font-name = Cantarell 11
background = /usr/share/backgrounds/kalaos-bg.jpg

# UI
show-language-selector = true
show-indicators = ~session;~layout;~a11y;~power
show-clock = true
clock-format = %H:%M
keyboard = onboard

# Window
position = 50%,center 50%,center
panel-position = bottom
default-user-image = #avatar-default
user-image = #avatar-default
EOF

# ─── Ensure background exists ────────────────────────────────────
run_cmd "mkdir -p /usr/share/backgrounds" "Backgrounds dir"
# Will be set by theming module; fallback if missing
if [[ ! -f /usr/share/backgrounds/kalaos-bg.jpg ]]; then
    run_cmd "cp ${SCRIPT_DIR:-$HOME/kalaos}/assets/logo/kalaos-logo.png /usr/share/backgrounds/kalaos-bg.jpg 2>/dev/null || true" "Fallback background"
fi

# ─── Enable LightDM ──────────────────────────────────────────────
enable_service lightdm

# Ensure graphical target is default
run_cmd "systemctl set-default graphical.target" "Set graphical.target as default"

log_ok "Login module completed (LightDM + GTK greeter)"
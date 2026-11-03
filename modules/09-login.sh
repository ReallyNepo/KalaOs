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

# ─── Ensure user exists + in required groups (Wayland needs video/seat) ───
TARGET_USER="${AUTOLOGIN_USER:-}"
if [[ -z "$TARGET_USER" ]]; then
    TARGET_USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1; exit}' /etc/passwd)
fi

if [[ -n "$TARGET_USER" ]]; then
    run_cmd "usermod -aG video,seat,input $TARGET_USER 2>/dev/null || true" "Add user to video/seat/input groups"
fi

# ─── Hyprland Wayland session (for LightDM) ──────────────────────
run_cmd "mkdir -p /usr/share/wayland-sessions" "Wayland sessions dir"
run_cmd "cat > /usr/share/wayland-sessions/hyprland.desktop <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=env XDG_CURRENT_DESKTOP=Hyprland Hyprland
Type=Application
DesktopNames=Hyprland
EOF" "Create Hyprland Wayland session"

# Also create X11 fallback
run_cmd "mkdir -p /usr/share/xsessions" "X11 sessions dir"
run_cmd "cat > /usr/share/xsessions/hyprland.desktop <<'EOF'
[Desktop Entry]
Name=Hyprland (X11 fallback)
Comment=An intelligent dynamic tiling Wayland compositor
Exec=env XDG_CURRENT_DESKTOP=Hyprland Hyprland
Type=Application
EOF" "Create Hyprland X11 fallback session"

# ─── Add fish to /etc/shells ───────────────────────────────────────
run_cmd "grep -q '^/usr/bin/fish$' /etc/shells || echo '/usr/bin/fish' >> /etc/shells" "Add fish to shells"

# ─── LightDM PAM (ensure proper session setup) ────────────────────
run_cmd "cat > /etc/pam.d/lightdm <<'PAM_EOF'
#%PAM-1.0
auth        requisite   pam_nologin.so
auth        required    pam_env.so
auth        required    pam_unix.so
auth        optional    pam_gnome_keyring.so
account     required    pam_unix.so
password    required    pam_unix.so
session     required    pam_limits.so
session     required    pam_unix.so
session     required    pam_env.so
session     optional    pam_gnome_keyring.so auto_start
session     required    pam_systemd.so
PAM_EOF" "Configure LightDM PAM"

# ─── Ensure XDG_RUNTIME_DIR for user ───────────────────────────────
run_cmd "mkdir -p /run/user/$(id -u $TARGET_USER 2>/dev/null || echo 1000)" "XDG runtime dir"
run_cmd "chown $TARGET_USER:$TARGET_USER /run/user/$(id -u $TARGET_USER 2>/dev/null || echo 1000) 2>/dev/null || true" "Fix runtime dir perms"

# ─── Enable LightDM ──────────────────────────────────────────────
enable_service lightdm

# Ensure graphical target is default
run_cmd "systemctl set-default graphical.target" "Set graphical.target as default"

log_ok "Login module completed (LightDM + GTK greeter)"
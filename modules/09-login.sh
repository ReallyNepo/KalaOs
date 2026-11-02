#!/usr/bin/env bash
# Module: 09-login - Autologin via agetty (no greeter, zero deps)

log_step "Configuring TTY autologin (agetty)"

# Get target user (default: first non-root user or $AUTOLOGIN_USER)
TARGET_USER="${AUTOLOGIN_USER:-}"
if [[ -z "$TARGET_USER" ]]; then
    TARGET_USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1; exit}' /etc/passwd)
fi

if [[ -z "$TARGET_USER" ]]; then
    log_warn "No user found for autologin; skipping login config"
    log_ok "Login module completed (no autologin)"
    exit 0
fi

log_step "Setting up autologin for user: $TARGET_USER"

# ─── Configure agetty autologin on tty1 ──────────────────────────
run_cmd "mkdir -p /etc/systemd/system/getty@tty1.service.d" "getty drop-in dir"

cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<AUTOLOGIN_EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $TARGET_USER --noclear %I \$TERM
Type=idle
AUTOLOGIN_EOF

# ─── Auto-start Hyprland on tty1 login ───────────────────────────
run_cmd "mkdir -p /home/$TARGET_USER/.config/hypr" "Hypr config dir"
run_cmd "chown -R $TARGET_USER:$TARGET_USER /home/$TARGET_USER/.config/hypr" "Fix hypr perms"

# Add auto-start to .bash_profile (runs on TTY login)
BASH_PROFILE="/home/$TARGET_USER/.bash_profile"
if [[ ! -f "$BASH_PROFILE" ]] || ! grep -q "Hyprland" "$BASH_PROFILE"; then
    cat >> "$BASH_PROFILE" <<'BASH_EOF'

# Auto-start Hyprland on tty1
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]]; then
    exec Hyprland
fi
BASH_EOF
    run_cmd "chown $TARGET_USER:$TARGET_USER $BASH_PROFILE" "Fix bash_profile perms"
fi

# ─── Also add to .zprofile for zsh users ─────────────────────────
ZSH_PROFILE="/home/$TARGET_USER/.zprofile"
if [[ ! -f "$ZSH_PROFILE" ]] || ! grep -q "Hyprland" "$ZSH_PROFILE"; then
    cat > "$ZSH_PROFILE" <<'ZSH_EOF'
# Auto-start Hyprland on tty1
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && "$(tty)" = "/dev/tty1" ]]; then
    exec Hyprland
fi
ZSH_EOF
    run_cmd "chown $TARGET_USER:$TARGET_USER $ZSH_PROFILE" "Fix zprofile perms"
fi

# ─── Fish shell config ───────────────────────────────────────────
FISH_CONFIG="/home/$TARGET_USER/.config/fish/config.fish"
run_cmd "mkdir -p $(dirname "$FISH_CONFIG")" "Fish config dir"
if [[ ! -f "$FISH_CONFIG" ]] || ! grep -q "Hyprland" "$FISH_CONFIG"; then
    cat >> "$FISH_CONFIG" <<'FISH_EOF'

# Auto-start Hyprland on tty1
if test -z "$DISPLAY"; and test -z "$WAYLAND_DISPLAY"; and test (tty) = "/dev/tty1"
    exec Hyprland
end
FISH_EOF
    run_cmd "chown -R $TARGET_USER:$TARGET_USER $(dirname "$FISH_CONFIG")" "Fix fish perms"
fi

log_ok "Login module completed (agetty autologin → Hyprland on tty1)"
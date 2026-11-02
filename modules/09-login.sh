#!/usr/bin/env bash
# Module: 09-login - Greetd + wlgreet (Wayland) + tema KalaOS

log_step "Configuring Greetd + wlgreet login"

pacman_install greetd wlgreet

# ─── Greetd config ────────────────────────────────────────────
log_step "Configuring greetd with wlgreet"

run_cmd "mkdir -p /etc/greetd" "Greetd config dir"

cat > /etc/greetd/config.toml <<'GREETD_CONFIG_EOF'
[terminal]
vt = 1

[default_session]
command = "wlgreet --cmd 'hyprland'"
user = "greeter"

[initial_session]
command = "wlgreet --cmd 'hyprland'"
user = "greeter"

[greetd]
# Configuración adicional si se necesita
GREETD_CONFIG_EOF

# ─── Usuario greeter ───────────────────────────────────────────
run_cmd "id -u greeter &>/dev/null || useradd -r -s /bin/false -d /var/lib/greetd greeter" "Create greeter user"

# ─── Habilitar greetd ──────────────────────────────────────────
enable_service greetd

# ─── Autologin si configurado ──────────────────────────────────
if [[ -n "$AUTOLOGIN_USER" && "$AUTOLOGIN_USER" != "" ]]; then
    log_step "Configuring autologin for: $AUTOLOGIN_USER"
    run_cmd "mkdir -p /etc/greetd" "Greetd dir"
    cat > /etc/greetd/autologin.toml <<AUTOLOGIN_EOF
[initial_session]
command = "hyprland"
user = "$AUTOLOGIN_USER"
AUTOLOGIN_EOF
fi

log_ok "Login module completed"
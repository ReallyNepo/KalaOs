#!/usr/bin/env bash
# Module: 09-login - Greetd + tuigreet (TUI) + tema KalaOS

log_step "Configuring Greetd + tuigreet login"

LOGIN_PKGS=(
    greetd
)

AUR_LOGIN_PKGS=(
    tuigreet
    greetd-tuigreet
)

pacman_install "${LOGIN_PKGS[@]}"
aur_install "${AUR_LOGIN_PKGS[@]}"

# ─── Greetd config ────────────────────────────────────────────
log_step "Configuring greetd with tuigreet"

run_cmd "mkdir -p /etc/greetd" "Greetd config dir"

cat > /etc/greetd/config.toml <<'GREETD_CONFIG_EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --user-menu --cmd 'hyprland'"
user = "greeter"

[initial_session]
command = "tuigreet --time --remember --user-menu --cmd 'hyprland'"
user = "greeter"

[greetd]
# Configuración adicional si se necesita
GREETD_CONFIG_EOF

# ─── Tuigreet config (CSS tema KalaOS) ────────────────────────
run_cmd "mkdir -p /etc/tuigreet" "Tuigreet config dir"

cat > /etc/tuigreet/config.toml <<'TUIGREET_CONFIG_EOF'
[general]
# Tema KalaOS morado/rojo
theme = "kalaos"

[theme.kalaos]
# Colores base (se pueden sobrescribir desde generate-theme.sh)
background = "#1a0d1f"
foreground = "#f5e6f8"
accent_purple = "#7c3aed"
accent_red = "#c0392b"
surface = "#241230"
border = "#3d1a4a"
muted = "#6b4a7a"

# UI
prompt = "KalaOS 🐱"
time_format = "%H:%M"
date_format = "%A, %d %B %Y"
show_hostname = true
hostname = "kalaos"

# Input
input_background = "#241230"
input_foreground = "#f5e6f8"
input_cursor = "#ff6b35"

# Button
button_background = "#7c3aed"
button_foreground = "#1a0d1f"
button_hover_background = "#a855f7"

# User menu
user_menu_background = "#241230"
user_menu_foreground = "#f5e6f8"
user_menu_selected_background = "#7c3aed"
user_menu_selected_foreground = "#1a0d1f"

# Session menu
session_menu_background = "#241230"
session_menu_foreground = "#f5e6f8"
session_menu_selected_background = "#c0392b"
session_menu_selected_foreground = "#1a0d1f"

# Power menu
power_menu_background = "#241230"
power_menu_foreground = "#f5e6f8"
power_menu_selected_background = "#c0392b"
power_menu_selected_foreground = "#1a0d1f"
TUIGREET_CONFIG_EOF

# ─── Generar tema tuigreet dinámico desde palette ──────────────
run_cmd "mkdir -p ${SCRIPT_DIR:-$HOME/kalaos}/modules" "Modules dir"
cat > ${SCRIPT_DIR:-$HOME/kalaos}/modules/generate-tuigreet-theme.sh <<'TUI_THEME_GEN_EOF'
#!/usr/bin/env bash
# Genera tuigreet theme desde palette actual

set -euo pipefail

THEME_DIR="$HOME/.config/kalaos/theme"
PALETTE_FILE="$THEME_DIR/current.json"

if [[ ! -f "$PALETTE_FILE" ]]; then
    PALETTE_FILE="${SCRIPT_DIR:-$HOME/kalaos}/assets/theme/kalaos-palette.json"
fi

BG=$(jq -r '.background' "$PALETTE_FILE")
FG=$(jq -r '.foreground' "$PALETTE_FILE")
ACCENT_PURPLE=$(jq -r '.accent_purple // .color2' "$PALETTE_FILE")
ACCENT_RED=$(jq -r '.accent_red // .color1' "$PALETTE_FILE")
SURFACE=$(jq -r '.surface // .color0' "$PALETTE_FILE")
BORDER=$(jq -r '.border // .color8' "$PALETTE_FILE")
MUTED=$(jq -r '.muted // .color8' "$PALETTE_FILE")

cat > /etc/tuigreet/theme-kalaos.toml <<EOF
[theme.kalaos]
background = "$BG"
foreground = "$FG"
accent_purple = "$ACCENT_PURPLE"
accent_red = "$ACCENT_RED"
surface = "$SURFACE"
border = "$BORDER"
muted = "$MUTED"

input_background = "$SURFACE"
input_foreground = "$FG"
input_cursor = "$ACCENT_RED"

button_background = "$ACCENT_PURPLE"
button_foreground = "$BG"
button_hover_background = "$ACCENT_RED"

user_menu_background = "$SURFACE"
user_menu_foreground = "$FG"
user_menu_selected_background = "$ACCENT_PURPLE"
user_menu_selected_foreground = "$BG"

session_menu_background = "$SURFACE"
session_menu_foreground = "$FG"
session_menu_selected_background = "$ACCENT_RED"
session_menu_selected_foreground = "$BG"

power_menu_background = "$SURFACE"
power_menu_foreground = "$FG"
power_menu_selected_background = "$ACCENT_RED"
power_menu_selected_foreground = "$BG"
EOF
TUI_THEME_GEN_EOF

chmod +x ${SCRIPT_DIR:-$HOME/kalaos}/modules/generate-tuigreet-theme.sh

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
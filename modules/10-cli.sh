#!/usr/bin/env bash
# Module: 10-cli - CLI propia `kala` (wrapper omarchy-cli + extensiones KalaOS)

log_step "Installing KalaOS CLI: kala"

CLI_PKGS=(
    gum                    # UI components for scripts
    jq                     # JSON processing
    yq                     # YAML processing
    chafa                  # Terminal image viewer para logo
)

pacman_install "${CLI_PKGS[@]}"
aur_install claude-code opencode

# ─── Estructura CLI kala ──────────────────────────────────────
log_step "Creating kala CLI structure"

KALA_DIR="/usr/local/bin"
KALA_LIB_DIR="/usr/local/lib/kala"
KALA_CONFIG_DIR="/etc/kala"

run_cmd "mkdir -p $KALA_LIB_DIR $KALA_CONFIG_DIR" "Create kala directories"

# ─── Entry point principal: /usr/local/bin/kala ───────────────
cat > "$KALA_DIR/kala" <<'KALA_MAIN_EOF'
#!/usr/bin/env bash
# KalaOS CLI - Main entry point
# Arch-based. Cat-powered. Game-ready.

set -euo pipefail

readonly KALA_VERSION="1.0.0"
readonly KALA_LIB_DIR="/usr/local/lib/kala"
readonly CONFIG_FILE="/etc/kala/kalaos.conf"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok()      { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*"; }
log_step()    { echo -e "\n${MAGENTA}${BOLD}▶${NC} ${BOLD}$*${NC}"; }

# Load config
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# ASCII Logo
show_logo() {
    cat <<'LOGO_EOF'
      /\_/\
     ( •.• )  KalaOS
      > ^ <   Arch-based. Cat-powered. Game-ready.
LOGO_EOF
}

# Help
show_help() {
    show_logo
    echo
    echo "Uso: kala <comando> [opciones]"
    echo
    echo "Comandos principales:"
    echo "  install              Ejecutar instalador completo (./install.sh)"
    echo "  update               Actualizar sistema + re-aplicar configs"
    echo "  theme <nombre>       Cambiar tema (purple-red, cyan, amber, custom)"
    echo "  wallpaper <ruta>     Setea wallpaper + regenera palette sistema"
    echo "  gaming <on|off>      Toggle gaming stack"
    echo "  kernel <variant>     Cambia kernel (bore/eevdf/zen) + rebuild initramfs"
    echo "  debloat <nivel>      Re-ejecuta debloat (minimal/standard/aggressive)"
    echo "  config edit          Abre \$EDITOR en kalaos.conf"
    echo "  config show          Muestra config actual resolviendo defaults"
    echo "  doctor               Health check (deps, services, perf, gaming)"
    echo "  backup               Backup configs + kalaos.conf a ~/kalaos-backup/"
    echo "  restore <dir>        Restaura backup"
    echo "  logo                 Muestra logo pixel-art en terminal"
    echo "  version              Versión KalaOS + commit hash"
    echo
    echo "Ejemplos:"
    echo "  kala wallpaper ~/Pictures/gaming.jpg"
    echo "  kala theme purple-red"
    echo "  kala kernel cachyos-eevdf"
    echo "  kala doctor"
}

# Subcommand: install
cmd_install() {
    /home/jairo/kalaos/install.sh "$@"
}

# Subcommand: update
cmd_update() {
    log_step "Updating system packages"
    pacman -Syu --noconfirm
    log_step "Re-applying KalaOS configs"
    /home/jairo/kalaos/install.sh
}

# Subcommand: theme
cmd_theme() {
    local theme="${1:-purple-red}"
    log_step "Switching theme to: $theme"
    # TODO: implement theme switching
    sed -i "s/^THEME_BASE=.*/THEME_BASE=\"$theme\"/" "$CONFIG_FILE"
    /home/jairo/kalaos/modules/generate-theme.sh
    log_ok "Theme changed to $theme. Reload Waybar/Hyprland to apply."
}

# Subcommand: wallpaper
cmd_wallpaper() {
    local wallpaper="${1:-}"
    if [[ -z "$wallpaper" ]]; then
        log_error "Usage: kala wallpaper <path-to-image>"
        return 1
    fi
    /home/jairo/kalaos/modules/generate-theme.sh "$wallpaper"
    pkill -USR2 waybar 2>/dev/null || true
    hyprctl reload 2>/dev/null || true
    log_ok "Wallpaper and theme updated"
}

# Subcommand: gaming
cmd_gaming() {
    local state="${1:-toggle}"
    case "$state" in
        on|enable|true)
            sed -i 's/^ENABLE_GAMING=.*/ENABLE_GAMING=true/' "$CONFIG_FILE"
            log_ok "Gaming stack enabled"
            ;;
        off|disable|false)
            sed -i 's/^ENABLE_GAMING=.*/ENABLE_GAMING=false/' "$CONFIG_FILE"
            log_ok "Gaming stack disabled"
            ;;
        toggle)
            if grep -q '^ENABLE_GAMING=true' "$CONFIG_FILE"; then
                cmd_gaming off
            else
                cmd_gaming on
            fi
            ;;
        *)
            log_error "Usage: kala gaming <on|off|toggle>"
            return 1
            ;;
    esac
}

# Subcommand: kernel
cmd_kernel() {
    local variant="${1:-}"
    if [[ -z "$variant" ]]; then
        log_error "Usage: kala kernel <cachyos-bore|cachyos-eevdf|linux-zen>"
        return 1
    fi
    sed -i "s/^KERNEL_VARIANT=.*/KERNEL_VARIANT=\"$variant\"/" "$CONFIG_FILE"
    /home/jairo/kalaos/modules/01-kernel.sh
    log_ok "Kernel changed to $variant. Reboot to apply."
}

# Subcommand: debloat
cmd_debloat() {
    local level="${1:-aggressive}"
    sed -i "s/^DEBLOAT_LEVEL=.*/DEBLOAT_LEVEL=\"$level\"/" "$CONFIG_FILE"
    /home/jairo/kalaos/modules/11-debloat.sh
    log_ok "Debloat level set to $level"
}

# Subcommand: config
cmd_config() {
    local action="${1:-show}"
    case "$action" in
        edit)
            ${EDITOR:-nano} "$CONFIG_FILE"
            ;;
        show)
            cat "$CONFIG_FILE"
            ;;
        *)
            log_error "Usage: kala config <edit|show>"
            return 1
            ;;
    esac
}

# Subcommand: doctor
cmd_doctor() {
    log_step "KalaOS Health Check"

    # Check services
    log_info "Checking critical services..."
    for svc in NetworkManager bluetooth greetd gamemoded; do
        if systemctl is-active --quiet "$svc"; then
            log_ok "  $svc: active"
        else
            log_warn "  $svc: inactive"
        fi
    done

    # Check kernel
    log_info "Kernel: $(uname -r)"

    # Check GPU
    log_info "GPU: $(lspci | grep -iE 'vga|3d|display' | head -1 | cut -d: -f3-)"

    # Check gaming
    if [[ "$ENABLE_GAMING" == true ]]; then
        log_ok "Gaming stack: enabled"
        command -v gamescope &>/dev/null && log_ok "  gamescope: installed" || log_warn "  gamescope: missing"
        command -v mangohud &>/dev/null && log_ok "  mangohud: installed" || log_warn "  mangohud: missing"
    else
        log_info "Gaming stack: disabled"
    fi

    # Check disk
    log_info "Disk usage: $(df -h / | awk 'NR==2 {print $3"/"$2" ("$5")"}')"

    # Check memory
    log_info "Memory: $(free -h | awk 'NR==2 {print $3"/"$2}')"

    # Check zram
    if [[ -f /sys/block/zram0/disksize ]]; then
        log_ok "ZRAM: active ($(cat /sys/block/zram0/disksize | numfmt --to=iec))"
    else
        log_warn "ZRAM: not configured"
    fi

    log_ok "Health check complete"
}

# Subcommand: backup
cmd_backup() {
    local backup_dir="$HOME/kalaos-backup-$(date +%Y%m%d-%H%M%S)"
    log_step "Creating backup at $backup_dir"
    mkdir -p "$backup_dir"
    cp -r "$HOME/.config/hypr" "$backup_dir/" 2>/dev/null || true
    cp -r "$HOME/.config/ghostty" "$backup_dir/" 2>/dev/null || true
    cp -r "$HOME/.config/waybar" "$backup_dir/" 2>/dev/null || true
    cp -r "$HOME/.config/fish" "$backup_dir/" 2>/dev/null || true
    cp -r "$HOME/.config/starship" "$backup_dir/" 2>/dev/null || true
    cp -r "$HOME/.config/rofi" "$backup_dir/" 2>/dev/null || true
    cp "$CONFIG_FILE" "$backup_dir/kalaos.conf" 2>/dev/null || true
    log_ok "Backup created: $backup_dir"
}

# Subcommand: restore
cmd_restore() {
    local backup_dir="${1:-}"
    if [[ -z "$backup_dir" || ! -d "$backup_dir" ]]; then
        log_error "Usage: kala restore <backup-directory>"
        return 1
    fi
    log_step "Restoring from $backup_dir"
    cp -r "$backup_dir/hypr" "$HOME/.config/" 2>/dev/null || true
    cp -r "$backup_dir/ghostty" "$HOME/.config/" 2>/dev/null || true
    cp -r "$backup_dir/waybar" "$HOME/.config/" 2>/dev/null || true
    cp -r "$backup_dir/fish" "$HOME/.config/" 2>/dev/null || true
    cp -r "$backup_dir/starship" "$HOME/.config/" 2>/dev/null || true
    cp -r "$backup_dir/rofi" "$HOME/.config/" 2>/dev/null || true
    cp "$backup_dir/kalaos.conf" "$CONFIG_FILE" 2>/dev/null || true
    log_ok "Restored. Run 'kala update' to apply."
}

# Subcommand: logo
cmd_logo() {
    if command -v chafa &>/dev/null && [[ -f /home/jairo/kalaos/assets/logo/kalaos-cat-arch.png ]]; then
        chafa --size 40x20 /home/jairo/kalaos/assets/logo/kalaos-cat-arch.png
    else
        show_logo
    fi
}

# Subcommand: version
cmd_version() {
    show_logo
    echo "Version: $KALA_VERSION"
    echo "Config: $CONFIG_FILE"
    if [[ -d /home/jairo/kalaos/.git ]]; then
        echo "Commit: $(cd /home/jairo/kalaos && git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
    fi
}

# Subcommand: ai
cmd_ai() {
    local subcmd="${1:-help}"
    shift || true
    case "$subcmd" in
        claude)
            exec kalaos-claude "$@"
            ;;
        opencode)
            exec kalaos-opencode "$@"
            ;;
        doctor)
            cmd_doctor
            ;;
        logs)
            journalctl -f -u greetd -u NetworkManager -u bluetooth -u gamemoded
            ;;
        help|-h|--help|*)
            echo "Uso: kala ai <claude|opencode|doctor|logs>"
            echo
            echo "  claude    - Claude Code con contexto completo KalaOS"
            echo "  opencode  - opencode con contexto completo KalaOS"
            echo "  doctor    - Health check completo (alias kala doctor)"
            echo "  logs      - Logs en vivo de servicios críticos"
            ;;
    esac
}

# Main dispatch
main() {
    local cmd="${1:-help}"
    shift || true

    case "$cmd" in
        install)        cmd_install "$@" ;;
        update)         cmd_update "$@" ;;
        theme)          cmd_theme "$@" ;;
        wallpaper)      cmd_wallpaper "$@" ;;
        gaming)         cmd_gaming "$@" ;;
        kernel)         cmd_kernel "$@" ;;
        debloat)        cmd_debloat "$@" ;;
        config)         cmd_config "$@" ;;
        doctor)         cmd_doctor "$@" ;;
        backup)         cmd_backup "$@" ;;
        restore)        cmd_restore "$@" ;;
        logo)           cmd_logo "$@" ;;
        version|-v|--version) cmd_version "$@" ;;
        ai)             cmd_ai "$@" ;;
        help|-h|--help|*) show_help ;;
    esac
}

main "$@"
KALA_MAIN_EOF

chmod +x "$KALA_DIR/kala"

# ─── Completions para fish/bash/zsh ────────────────────────────
log_step "Installing kala completions"

# Fish completion
mkdir -p /home/jairo/kalaos/dotfiles/fish/completions
cat > /home/jairo/kalaos/dotfiles/fish/completions/kala.fish <<'KALA_FISH_COMP_EOF'
# KalaOS CLI completions for fish
complete -c kala -f -n '__fish_use_subcommand' -a 'install update theme wallpaper gaming kernel debloat config doctor backup restore logo version ai help'
complete -c kala -n '__fish_seen_subcommand_from theme' -a 'purple-red cyan amber custom'
complete -c kala -n '__fish_seen_subcommand_from gaming' -a 'on off toggle'
complete -c kala -n '__fish_seen_subcommand_from kernel' -a 'cachyos-bore cachyos-eevdf linux-zen'
complete -c kala -n '__fish_seen_subcommand_from debloat' -a 'minimal standard aggressive'
complete -c kala -n '__fish_seen_subcommand_from config' -a 'edit show'
complete -c kala -n '__fish_seen_subcommand_from ai' -a 'claude opencode doctor logs help'
KALA_FISH_COMP_EOF

# Bash completion
cat > /usr/share/bash-completion/completions/kala <<'KALA_BASH_COMP_EOF'
_kala() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="install update theme wallpaper gaming kernel debloat config doctor backup restore logo version help"

    case "$prev" in
        theme) COMPREPLY=( $(compgen -W "purple-red cyan amber custom" -- "$cur") ); return 0 ;;
        gaming) COMPREPLY=( $(compgen -W "on off toggle" -- "$cur") ); return 0 ;;
        kernel) COMPREPLY=( $(compgen -W "cachyos-bore cachyos-eevdf linux-zen" -- "$cur") ); return 0 ;;
        debloat) COMPREPLY=( $(compgen -W "minimal standard aggressive" -- "$cur") ); return 0 ;;
        config) COMPREPLY=( $(compgen -W "edit show" -- "$cur") ); return 0 ;;
    esac

    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
}
complete -F _kala kala
KALA_BASH_COMP_EOF

# ─── Instalar AI Agent Wrappers ────────────────────────────────
log_step "Installing AI Agent wrappers (kalaos-claude, kalaos-opencode)"

run_cmd "cp /home/jairo/kalaos/dotfiles/kala/kalaos-claude $KALA_DIR/kalaos-claude" "Install kalaos-claude"
run_cmd "cp /home/jairo/kalaos/dotfiles/kala/kalaos-opencode $KALA_DIR/kalaos-opencode" "Install kalaos-opencode"
run_cmd "chmod +x $KALA_DIR/kalaos-claude $KALA_DIR/kalaos-opencode" "Make AI wrappers executable"

# ─── Instalar Skill KalaOS ──────────────────────────────────────
run_cmd "cp /home/jairo/kalaos/dotfiles/kalaos-skill.md $KALA_CONFIG_DIR/kalaos-skill.md" "Install KalaOS Skill"
run_cmd "cp /home/jairo/kalaos/dotfiles/kalaos-skill.md /home/jairo/kalaos/dotfiles/kalaos-skill.md" "Ensure skill in repo"

# ─── Subcomandos kala para AI agents ────────────────────────────
cat > "$KALA_LIB_DIR/kala-ai" <<'KALA_AI_EOF'
#!/usr/bin/env bash
# kala ai - AI Agent shortcuts

case "${1:-}" in
    claude)
        shift
        exec kalaos-claude "$@"
        ;;
    opencode)
        shift
        exec kalaos-opencode "$@"
        ;;
    doctor)
        exec kala doctor
        ;;
    logs)
        journalctl -f -u greetd -u NetworkManager -u bluetooth -u gamemoded
        ;;
    *)
        echo "Uso: kala ai <claude|opencode|doctor|logs>"
        exit 1
        ;;
esac
KALA_AI_EOF

chmod +x "$KALA_LIB_DIR/kala-ai"

log_ok "CLI module completed"
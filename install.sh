#!/usr/bin/env bash
# KalaOS Installer - Idempotent, modular, config-driven
# Uso: ./install.sh [--dry-run] [--module MODULE] [--skip MODULE]

set -euo pipefail

# ─── Colores y logging ─────────────────────────────────────────
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
log_dry()     { echo -e "${CYAN}[DRY-RUN]${NC} $*"; }

# ─── Configuración ─────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/kalaos.conf"
MODULES_DIR="${SCRIPT_DIR}/modules"
DOTFILES_DIR="${SCRIPT_DIR}/dotfiles"
ASSETS_DIR="${SCRIPT_DIR}/assets"
PKGLISTS_DIR="${SCRIPT_DIR}/pkglists"

DRY_RUN=false
RUN_MODULE=""
SKIP_MODULES=()

# ─── Cargar configuración ──────────────────────────────────────
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Config file not found: $CONFIG_FILE"
        exit 1
    fi
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
    log_ok "Config loaded: $CONFIG_FILE"
}

# ─── Helpers ───────────────────────────────────────────────────
run_cmd() {
    local cmd="$1"
    local desc="${2:-$cmd}"
    if [[ "$DRY_RUN" == true ]]; then
        log_dry "$desc"
    else
        log_info "$desc"
        eval "$cmd"
    fi
}

pacman_install() {
    local pkgs=("$@")
    [[ ${#pkgs[@]} -eq 0 ]] && return 0
    local to_install=()
    for pkg in "${pkgs[@]}"; do
        pacman -Q "$pkg" &>/dev/null || to_install+=("$pkg")
    done
    [[ ${#to_install[@]} -eq 0 ]] && return 0
    run_cmd "pacman -S --needed --noconfirm ${to_install[*]}" "Installing: ${to_install[*]}"
}

pacman_remove() {
    local pkgs=("$@")
    [[ ${#pkgs[@]} -eq 0 ]] && return 0
    run_cmd "pacman -Rns --noconfirm ${pkgs[*]}" "Removing: ${pkgs[*]}"
}

aur_install() {
    local pkgs=("$@")
    [[ ${#pkgs[@]} -eq 0 ]] && return 0
    # Run yay as original user (not root) to avoid makepkg root error
    local build_user="${SUDO_USER:-$USER}"
    if [[ "$build_user" == "root" ]]; then
        log_warn "Cannot determine non-root user for AUR build; skipping: ${pkgs[*]}"
        return 0
    fi
    run_cmd "sudo -u $build_user yay -S --needed --noconfirm ${pkgs[*]}" "AUR installing: ${pkgs[*]}"
}

enable_service() {
    local svc="$1"
    # Suppress systemd warning for units without [Install] section (non-fatal)
    run_cmd "systemctl enable --now $svc 2>/dev/null || systemctl start $svc" "Enabling service: $svc"
}

disable_service() {
    local svc="$1"
    run_cmd "systemctl disable --now $svc 2>/dev/null || true" "Disabling service: $svc"
}

stow_dotfiles() {
    local pkg="$1"
    local target="${2:-$HOME}"
    if command -v stow &>/dev/null; then
        run_cmd "cd '$DOTFILES_DIR' && stow -t '$target' '$pkg'" "Stowing $pkg to $target"
    else
        log_warn "stow not installed, skipping $pkg"
    fi
}

# ─── Módulos ───────────────────────────────────────────────────
MODULES=(
    "00-base"
    "01-kernel"
    "02-drivers"
    "03-gaming"
    "04-hyprland"
    "05-shell"
    "06-bar"
    "07-theming"
    "08-fonts"
    "09-login"
    "10-cli"
    "11-debloat"
    "12-perf"
    "13-branding"
)

run_module() {
    local module="$1"
    local module_path="${MODULES_DIR}/${module}.sh"
    if [[ ! -f "$module_path" ]]; then
        log_warn "Module not found: $module_path"
        return 0
    fi
    log_step "Running module: $module"
    # shellcheck source=/dev/null
    source "$module_path"
    log_ok "Module completed: $module"
}

# ─── Main ──────────────────────────────────────────────────────
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run) DRY_RUN=true; shift ;;
            --module) RUN_MODULE="$2"; shift 2 ;;
            --skip) SKIP_MODULES+=("$2"); shift 2 ;;
            -h|--help)
                cat <<EOF
KalaOS Installer
Uso: ./install.sh [OPCIONES]

Opciones:
  --dry-run           Simular sin ejecutar comandos
  --module NOMBRE     Ejecutar solo un módulo específico
  --skip NOMBRE       Saltar un módulo (repetible)
  -h, --help          Mostrar esta ayuda

Módulos disponibles: ${MODULES[*]}
EOF
                exit 0
                ;;
            *) log_error "Unknown option: $1"; exit 1 ;;
        esac
    done
}

main() {
    echo -e "${MAGENTA}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                    KalaOS Installer                        ║"
    echo "║         Arch-based. Cat-powered. Game-ready.               ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    parse_args "$@"
    load_config

    # Verificar root para operaciones de sistema
    if [[ "$DRY_RUN" == false && $EUID -ne 0 ]]; then
        log_error "Run as root (sudo ./install.sh) for system modifications"
        exit 1
    fi

    local modules_to_run=("${MODULES[@]}")
    if [[ -n "$RUN_MODULE" ]]; then
        modules_to_run=("$RUN_MODULE")
    fi

    for module in "${modules_to_run[@]}"; do
        if [[ " ${SKIP_MODULES[*]} " =~ " ${module} " ]]; then
            log_warn "Skipping module: $module"
            continue
        fi
        run_module "$module"
    done

    log_step "Installation complete!"
    log_ok "KalaOS is ready. Run 'kala doctor' to verify."
}

main "$@"
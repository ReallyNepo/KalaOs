#!/usr/bin/env bash
# KalaOS Smoke Tests - Verificación post-install
# Ejecutar: ./tests/smoke.sh

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $*"; }
fail() { echo -e "${RED}✗${NC} $*"; }
warn() { echo -e "${YELLOW}!${NC} $*"; }

echo "╔══════════════════════════════════════════════════════════╗"
echo "║                    KalaOS Smoke Tests                      ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo

ERRORS=0

# ─── Kernel ───────────────────────────────────────────────────
echo "▶ Kernel"
if uname -r | grep -qE 'cachyos|zen'; then
    pass "Kernel CachyOS/Zen: $(uname -r)"
else
    fail "Kernel no es CachyOS/Zen: $(uname -r)"
    ((ERRORS++))
fi

# ─── Servicios críticos ───────────────────────────────────────
echo "▶ Servicios"
for svc in NetworkManager bluetooth greetd gamemoded; do
    if systemctl is-active --quiet "$svc"; then
        pass "  $svc: active"
    else
        fail "  $svc: inactive"
        ((ERRORS++))
    fi
done

# ─── GPU Drivers ──────────────────────────────────────────────
echo "▶ GPU"
GPU_INFO=$(lspci | grep -iE 'vga|3d|display' | head -1)
if [[ -n "$GPU_INFO" ]]; then
    pass "GPU detectada: $GPU_INFO"
else
    warn "No se detectó GPU"
fi

if [[ "$GPU_INFO" == *NVIDIA* ]]; then
    if command -v nvidia-smi &>/dev/null; then
        pass "  nvidia-smi disponible"
        nvidia-smi --query-gpu=name --format=csv,noheader | head -1 | xargs -I{} pass "  GPU: {}"
    else
        fail "  nvidia-smi no disponible"
        ((ERRORS++))
    fi
fi

# ─── Hyprland ─────────────────────────────────────────────────
echo "▶ Hyprland"
if command -v hyprland &>/dev/null; then
    pass "Hyprland instalado"
    if [[ -f "$HOME/.config/hypr/hyprland.conf" ]]; then
        pass "  Config encontrada"
    else
        warn "  Config no encontrada en ~/.config/hypr/"
    fi
else
    fail "Hyprland no instalado"
    ((ERRORS++))
fi

# ─── Terminal ─────────────────────────────────────────────────
echo "▶ Terminal (Ghostty)"
if command -v ghostty &>/dev/null; then
    pass "Ghostty instalado"
    if [[ -f "$HOME/.config/ghostty/config" ]]; then
        pass "  Config encontrada"
    else
        warn "  Config no encontrada"
    fi
else
    fail "Ghostty no instalado"
    ((ERRORS++))
fi

# ─── Shell ────────────────────────────────────────────────────
echo "▶ Shell (Fish)"
if command -v fish &>/dev/null; then
    pass "Fish instalado"
    if [[ "$SHELL" == */fish ]]; then
        pass "  Shell por defecto: fish"
    else
        warn "  Shell por defecto no es fish ($SHELL)"
    fi
else
    fail "Fish no instalado"
    ((ERRORS++))
fi

# ─── Starship ─────────────────────────────────────────────────
if command -v starship &>/dev/null; then
    pass "Starship instalado"
else
    warn "Starship no instalado"
fi

# ─── Waybar ───────────────────────────────────────────────────
echo "▶ Waybar"
if command -v waybar &>/dev/null; then
    pass "Waybar instalado"
else
    fail "Waybar no instalado"
    ((ERRORS++))
fi

# ─── Gaming stack ─────────────────────────────────────────────
echo "▶ Gaming Stack"
if command -v steam &>/dev/null; then
    pass "Steam instalado"
else
    warn "Steam no instalado"
fi

for tool in gamescope mangohud gamemoded; do
    if command -v "$tool" &>/dev/null; then
        pass "  $tool instalado"
    else
        warn "  $tool no instalado"
    fi
done

# ─── ZRAM ─────────────────────────────────────────────────────
echo "▶ ZRAM"
if [[ -f /sys/block/zram0/disksize ]]; then
    SIZE=$(cat /sys/block/zram0/disksize | numfmt --to=iec)
    pass "ZRAM activo: $SIZE"
else
    warn "ZRAM no configurado"
fi

# ─── CPU Governor ─────────────────────────────────────────────
echo "▶ CPU Governor"
GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
if [[ "$GOV" == "performance" ]]; then
    pass "Governor: performance"
else
    warn "Governor: $GOV (esperado: performance)"
fi

# ─── Kala CLI ─────────────────────────────────────────────────
echo "▶ Kala CLI"
if command -v kala &>/dev/null; then
    pass "kala instalado"
    kala version | head -3
else
    fail "kala no instalado"
    ((ERRORS++))
fi

# ─── Theming ──────────────────────────────────────────────────
echo "▶ Theming"
if [[ -f "$HOME/.config/kalaos/theme/current.json" ]]; then
    pass "Tema actual generado"
else
    warn "Tema no generado aún"
fi

# ─── Fonts ────────────────────────────────────────────────────
echo "▶ Fonts"
for font in "SF Pro Display" "JetBrains Mono Nerd Font"; do
    if fc-list | grep -qi "$font"; then
        pass "  $font instalada"
    else
        warn "  $font no encontrada"
    fi
done

# ─── Resumen ──────────────────────────────────────────────────
echo
echo "═══════════════════════════════════════════════════════════"
if [[ $ERRORS -eq 0 ]]; then
    echo -e "${GREEN}✓ Todos los tests críticos pasaron${NC}"
    exit 0
else
    echo -e "${RED}✗ $ERRORS test(s) crítico(s) fallaron${NC}"
    exit 1
fi
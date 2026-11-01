#!/usr/bin/env bash
# Module: 03-gaming - Gaming stack completo (Steam, Proton-GE, gamescope, tools)

[[ "$ENABLE_GAMING" == true ]] || { log_warn "Gaming disabled in config, skipping"; exit 0; }

# ─── Enable Chaotic-AUR (deferred from 00-base to avoid mesa-tkg conflicts) ──────
log_step "Enabling Chaotic-AUR for gaming binaries"
for repo in "${CUSTOM_REPOS[@]}"; do
    case "$repo" in
        chaotic-aur)
            if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
                run_cmd "pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com" "Import chaotic-aur key"
                run_cmd "pacman-key --lsign-key 3056513887B78AEB" "Sign chaotic-aur key"
                run_cmd "pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'" "Install chaotic-aur keyring"
                run_cmd "cat >> /etc/pacman.conf <<'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF" "Adding chaotic-aur repository"
            fi
            ;;
    esac
done
run_cmd "pacman -Sy" "Sync package databases with chaotic-aur"

log_step "Installing gaming stack"

# ─── Steam + Proton-GE + Wine-GE ───────────────────────────────
GAMING_PKGS=(
    steam
    proton-ge-custom          # AUR: GE-Proton latest
    wine-ge-custom            # AUR: Wine-GE latest
    lutris
    heroic-games-launcher     # AUR: Epic/GOG launcher
    bottles                   # Flatpak preferred, pero AUR existe
)

pacman_install steam lutris
aur_install proton-ge-custom wine-ge heroic-games-launcher

# ─── Gamescope session (Steam Deck style) ──────────────────────
if [[ "$GAMESCOPE_SESSION" == true ]]; then
    GAMING_PKGS+=(
        gamescope
        lib32-gamescope
        jupiter-dkms          # AUR: Steam Deck (Jupiter) hardware support
    )
    pacman_install gamescope lib32-gamescope
    aur_install jupiter-dkms
fi

# ─── Performance / Overlay tools ───────────────────────────────
GAMING_PKGS+=(
    mangohud
    lib32-mangohud
    goverlay                  # GUI para MangoHud/vkBasalt
    vkbasalt                  # CAS sharpening, FXAA, etc.
    lib32-vkbasalt
    gamemode
    lib32-gamemode
    cpupower
    tuned
    tuned-ppd
)

pacman_install "${GAMING_PKGS[@]}"

# ─── Config gamemode ───────────────────────────────────────────
run_cmd "cat > /etc/gamemode.ini <<'EOF'
[general]
renice=10
ioprio=1
ethtool=1
inhibit_screensaver=1
EOF" "Configure gamemode"

enable_service gamemoded

# ─── MangoHud config global ────────────────────────────────────
run_cmd "mkdir -p /etc/MangoHud" "MangoHud config dir"
run_cmd "cat > /etc/MangoHud/MangoHud.conf <<'EOF'
# KalaOS default MangoHud config
position=top-left
toggle_hud=Shift_R+F12
reload_cfg=Shift_R+F11
fps_limit=0
cpu_stats=1
gpu_stats=1
ram_stats=1
vram_stats=1
frame_timing=1
arch=both
output_type=openGL
vsync=0
gpu_color=FF6B35
cpu_color=7C3AED
ram_color=06B6D4
font_size=24
background_alpha=0.7
EOF" "Global MangoHud config"

# ─── vkBasalt config ───────────────────────────────────────────
run_cmd "cat > /etc/vkBasalt.conf <<'EOF'
# KalaOS vkBasalt config
enable = true
cas = true
cas_sharpen = 0.4
fidelityfx_cas = true
fidelityfx_cas_sharpen = 0.4
toggle_key = Home
EOF" "vkBasalt config"

# ─── Steam deck UI mode ────────────────────────────────────────
if [[ "$STEAM_DECK_UI" == true ]]; then
    run_cmd "mkdir -p /etc/steam" "Steam config dir"
    run_cmd "echo 'SteamDeck=1' > /etc/steam/steam_devices" "Enable Steam Deck UI"
fi

# ─── Proton environment ────────────────────────────────────────
run_cmd "cat > /etc/profile.d/kalaos-gaming.sh <<'EOF'
# KalaOS Gaming Environment
export PROTON_HIDE_NVIDIA_GPUS=0
export PROTON_ENABLE_NVAPI=1
export PROTON_ENABLE_NGX_UPDATER=1
export DXVK_ASYNC=1
export DXVK_HUD=0
export VKD3D_CONFIG=dxr11,multi_queue
export RADV_PERFTEST=aco,ngg,nggc
export AMD_DEBUG=useaco
export MESA_SHADER_CACHE_MAX_SIZE=16G
export __GL_SHADER_DISK_CACHE_SIZE=16777216000
export __GL_SHADER_DISK_CACHE_PATH=/var/cache/nvidia
EOF" "Gaming environment variables"

# ─── CPU Governor para gaming ──────────────────────────────────
run_cmd "cat > /etc/default/cpupower <<'EOF'
governor='performance'
EOF" "Set performance governor"
enable_service cpupower

log_ok "Gaming module completed"
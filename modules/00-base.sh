#!/usr/bin/env bash
# Module: 00-base - Repos, pacman.conf, mirrors, base packages

# ─── Repositorios ──────────────────────────────────────────────
log_step "Configuring repositories"

# pacman.conf optimizations
run_cmd "sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf" "Enable parallel downloads"
run_cmd "sed -i 's/^#Color/Color/' /etc/pacman.conf" "Enable color output"
run_cmd "grep -q '^ILoveCandy' /etc/pacman.conf || sed -i '/^Color/a ILoveCandy' /etc/pacman.conf" "Add ILoveCandy"

# CachyOS repo (kernel + optimized libs)
if ! grep -q "\[cachyos\]" /etc/pacman.conf; then
    run_cmd "cat >> /etc/pacman.conf <<'EOF'

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
EOF" "Adding CachyOS repository"
fi

# Chaotic-AUR (gaming binaries pre-built)
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

# Actualizar mirrors y base de datos
run_cmd "pacman -Sy" "Sync package databases"

# ─── Paquetes base esenciales ──────────────────────────────────
log_step "Installing base packages"

# Remove conflicting firmware packages first (linux-firmware-other provides same files)
run_cmd "pacman -Rdd --noconfirm linux-firmware-other 2>/dev/null || true" "Remove conflicting linux-firmware-other"

# Remove jack2 (conflicts with pipewire-jack which provides JACK)
run_cmd "pacman -Rdd --noconfirm jack2 2>/dev/null || true" "Remove jack2 (conflicts with pipewire-jack)"

# Remove mesa-tkg variants (conflicts with standard mesa)
run_cmd "pacman -Rdd --noconfirm mesa-tkg mesa-tkg-git 2>/dev/null || true" "Remove mesa-tkg variants (conflicts with standard mesa)"

# Install standard mesa from extra first to claim slot before chaotic-aur pulls mesa-tkg-git
run_cmd "pacman -S --needed --noconfirm extra/mesa" "Install standard mesa from extra repo"

BASE_PKGS=(
    # Sistema base
    base base-devel linux-firmware linux-firmware-amd linux-firmware-ti
    # Gestión paquetes AUR
    yay
    # Utilidades sistema
    sudo polkit reflector rsync unzip p7zip tar gzip bzip2 xz zstd
    # Red
    networkmanager network-manager-applet nm-connection-editor
    # Bluetooth
    bluez bluez-utils blueman
    # Audio (PipeWire completo)
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber libpipewire
    # Gráficos/Vulkan
    mesa vulkan-radeon vulkan-intel vulkan-icd-loader vulkan-tools
    # Sistema archivos
    btrfs-progs dosfstools exfatprogs f2fs-tools ntfs-3g udftools
    # Virtualización
    qemu-full libvirt virt-manager dnsmasq bridge-utils vde2 openbsd-netcat
    # Fuentes esenciales
    noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-liberation
    # Utilidades varias
    htop btop fastfetch neofetch jq yq fzf ripgrep fd bat eza zoxide
    # Archivos dotfiles
    stow chezmoi
    # Seguridad
    age sops
)

pacman_install "${BASE_PKGS[@]}"

# Refresh mirrors to avoid 404s on CachyOS packages (now reflector is installed)
run_cmd "reflector --country Spain,France,Germany --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist" "Refresh mirrors with reflector"
run_cmd "pacman -Sy" "Sync package databases after mirror refresh"

# ─── Servicios base ────────────────────────────────────────────
log_step "Enabling base services"
enable_service NetworkManager
enable_service bluetooth
enable_service libvirtd
enable_service fstrim.timer

# ─── Reflector (mirrors auto) ──────────────────────────────────
run_cmd "cat > /etc/xdg/reflector/reflector.conf <<'EOF'
--country Spain,France,Germany
--protocol https
--latest 20
--sort rate
--save /etc/pacman.d/mirrorlist
EOF" "Configure reflector"
enable_service reflector.timer

log_ok "Base module completed"
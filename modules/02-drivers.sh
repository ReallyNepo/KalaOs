#!/usr/bin/env bash
# Module: 02-drivers - GPU drivers, firmware, Vulkan layers

log_step "Configuring GPU drivers"

# ─── Detectar GPU si auto ──────────────────────────────────────
if [[ "$GPU_VENDOR" == "auto" ]]; then
    if lspci | grep -qi nvidia; then
        GPU_VENDOR="nvidia"
    elif lspci | grep -qi "amd\|ati"; then
        GPU_VENDOR="amd"
    elif lspci | grep -qi intel; then
        GPU_VENDOR="intel"
    fi
    log_info "Detected GPU vendor: $GPU_VENDOR"
fi

# ─── Determinar driver NVIDIA ──────────────────────────────────
if [[ "$GPU_VENDOR" == "nvidia" ]]; then
    if [[ "$NVIDIA_DRIVER" == "auto" ]]; then
        # Detectar arquitectura GPU
        GPU_ARCH=$(nvidia-smi --query-gpu=architecture --format=csv,noheader 2>/dev/null | head -1 || echo "unknown")
        case "$GPU_ARCH" in
            *Turing*|*Ampere*|*Ada*|*Blackwell*|*Hopper*)  # RTX 20/30/40/50
                NVIDIA_DRIVER="nvidia-open-dkms"
                ;;
            *)  # Pascal y anteriores
                NVIDIA_DRIVER="nvidia-dkms"
                ;;
        esac
        log_info "Auto-selected NVIDIA driver: $NVIDIA_DRIVER"
    fi
fi

# ─── Paquetes por vendor ───────────────────────────────────────
DRIVER_PKGS=()

case "$GPU_VENDOR" in
    nvidia)
        DRIVER_PKGS+=(
            "$NVIDIA_DRIVER"
            nvidia-settings
            nvidia-utils
            libva-nvidia-driver
            opencl-nvidia
            nvidia-container-toolkit
            envycontrol
        )
        ;;
    amd)
        DRIVER_PKGS+=(
            mesa
            vulkan-radeon
            libva-mesa-driver
            mesa-vdpau
            rocm-opencl-runtime
            radeontop
        )
        ;;
    intel)
        DRIVER_PKGS+=(
            mesa
            vulkan-intel
            intel-media-driver
            libva-intel-driver
            intel-gpu-tools
            compute-runtime
        )
        ;;
    hybrid)
        # Optimus/AMD hybrid - ambos drivers + switching
        DRIVER_PKGS+=(
            nvidia-dkms nvidia-utils nvidia-settings libva-nvidia-driver
            mesa vulkan-radeon vulkan-intel
            envycontrol optimus-manager
        )
        ;;
esac

# Firmware común
DRIVER_PKGS+=(linux-firmware linux-firmware-qlogic linux-firmware-whence sof-firmware)

# Vulkan layers y tools gaming
if [[ "$ENABLE_VULKAN_LAYERS" == true ]]; then
    DRIVER_PKGS+=(
        vulkan-tools
        vulkan-icd-loader
        lib32-vulkan-icd-loader
        vkbasalt
        goverlay
        mangohud
        lib32-mangohud
        gamescope
    )
fi

pacman_install "${DRIVER_PKGS[@]}"

# ─── Configuración NVIDIA específica ───────────────────────────
if [[ "$GPU_VENDOR" == "nvidia" || "$GPU_VENDOR" == "hybrid" ]]; then
    log_step "Configuring NVIDIA-specific settings"

    # modprobe.d para early loading + modeset
    run_cmd "cat > /etc/modprobe.d/nvidia.conf <<'EOF'
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_EnableGpuFirmware=1
EOF" "NVIDIA modprobe options"

    # pacman hook para regenerar initramfs en updates
    run_cmd "mkdir -p /etc/pacman.d/hooks" "Ensure hooks dir"
    run_cmd "cat > /etc/pacman.d/hooks/nvidia.hook <<'EOF'
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia-dkms
Target=nvidia-open-dkms
Target=linux-cachyos
Target=linux-cachyos-eevdf

[Action]
Description=Update NVIDIA module in initcpio
When=PostTransaction
Exec=/usr/bin/mkinitcpio -p kalaos
EOF" "NVIDIA pacman hook"
fi

# ─── AMD PPTables / undervolt ──────────────────────────────────
if [[ "$GPU_VENDOR" == "amd" ]]; then
    run_cmd "cat > /etc/modprobe.d/amdgpu.conf <<'EOF'
options amdgpu ppfeaturemask=0xffffffff
EOF" "AMD GPU feature mask unlock"
fi

# ─── Intel i915 ────────────────────────────────────────────────
if [[ "$GPU_VENDOR" == "intel" ]]; then
    run_cmd "cat > /etc/modprobe.d/i915.conf <<'EOF'
options i915 enable_guc=3 enable_fbc=1 enable_psr=1
EOF" "Intel i915 optimizations"
fi

log_ok "Drivers module completed"
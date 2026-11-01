#!/usr/bin/env bash
# Module: 01-kernel - CachyOS kernel (BORE/EEVDF), headers, cmdline, initramfs

log_step "Configuring kernel: $KERNEL_VARIANT"

# ─── Determinar paquetes kernel ────────────────────────────────
case "$KERNEL_VARIANT" in
    cachyos-bore)
        KERNEL_PKGS=(linux-cachyos linux-cachyos-headers)
        ;;
    cachyos-eevdf)
        KERNEL_PKGS=(linux-cachyos-eevdf linux-cachyos-eevdf-headers)
        ;;
    linux-zen)
        KERNEL_PKGS=(linux-zen linux-zen-headers)
        ;;
    *)
        log_error "Unknown kernel variant: $KERNEL_VARIANT"
        exit 1
        ;;
esac

# ─── Instalar kernel y headers ─────────────────────────────────
pacman_install "${KERNEL_PKGS[@]}"

# ─── Kernel cmdline ────────────────────────────────────────────
log_step "Setting kernel cmdline"
KERNEL_PARAMS=(
    "nvme.noacpi=1"
    "mitigations=off"
    "transparent_hugepage=always"
    "nowatchdog"
    "module_blacklist=pcspkr"
)

# NVIDIA specific
if [[ "$GPU_VENDOR" == "nvidia" || "$GPU_VENDOR" == "auto" ]]; then
    KERNEL_PARAMS+=("nvidia_drm.modeset=1" "nvidia_drm.fbdev=1")
fi

# AMD specific
if [[ "$GPU_VENDOR" == "amd" || "$GPU_VENDOR" == "auto" ]]; then
    KERNEL_PARAMS+=("amdgpu.ppfeaturemask=0xffffffff")
fi

# Intel specific
if [[ "$GPU_VENDOR" == "intel" || "$GPU_VENDOR" == "auto" ]]; then
    KERNEL_PARAMS+=("i915.enable_guc=3")
fi

CMDLINE_STR="${KERNEL_PARAMS[*]}"

# systemd-boot
if [[ "$BOOTLOADER" == "systemd-boot" ]]; then
    BOOT_ENTRY="/boot/loader/entries/$(ls /boot/loader/entries/ | grep -E 'cachyos|arch' | head -1)"
    if [[ -f "$BOOT_ENTRY" ]]; then
        run_cmd "sed -i 's/^options .*/options ${CMDLINE_STR}/' '$BOOT_ENTRY'" "Update kernel cmdline in $BOOT_ENTRY"
    fi
fi

# GRUB fallback
if [[ "$BOOTLOADER" == "grub" ]]; then
    run_cmd "sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"${CMDLINE_STR}\"/' /etc/default/grub" "Update GRUB cmdline"
    run_cmd "grub-mkconfig -o /boot/grub/grub.cfg" "Regenerate GRUB config"
fi

# ─── mkinitcpio preset para CachyOS ────────────────────────────
run_cmd "cat > /etc/mkinitcpio.d/kalaos.preset <<'EOF'
# KalaOS mkinitcpio preset
ALL_kver="/boot/vmlinuz-${KERNEL_VARIANT}"
PRESETS=('default' 'fallback')
default_image="/boot/initramfs-${KERNEL_VARIANT}.img"
fallback_image="/boot/initramfs-${KERNEL_VARIANT}-fallback.img"
default_options="-S autodetect -S kms -S block -S filesystems -S keyboard -S fsck"
fallback_options="-S autodetect -S kms -S block -S filesystems -S keyboard -S fsck"
EOF" "Create KalaOS mkinitcpio preset"

# Regenerar initramfs
run_cmd "mkinitcpio -p kalaos" "Regenerate initramfs"

# ─── Kernel modules auto-load ──────────────────────────────────
run_cmd "cat > /etc/modules-load.d/kalaos.conf <<'EOF'
# KalaOS kernel modules
nvidia
nvidia_modeset
nvidia_uvm
nvidia_drm
amdgpu
i915
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
EOF" "Configure kernel modules autoload"

log_ok "Kernel module completed"
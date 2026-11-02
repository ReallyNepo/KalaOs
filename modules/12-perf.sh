#!/usr/bin/env bash
# Module: 12-perf - ZRAM/zswap, CPU governor, irqbalance, sysctl, fstrim

log_step "Configuring performance optimizations"

# ─── ZRAM (zswap alternative, mejor para gaming) ───────────────
log_step "Setting up ZRAM"

ZRAM_SIZE=$(( $(grep MemTotal /proc/meminfo | awk '{print $2}') * ZRAM_SIZE_PERCENT / 100 * 1024 ))  # KB to bytes

run_cmd "cat > /etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = ${ZRAM_SIZE}K
compression-algorithm = ${ZRAM_COMPRESSION}
swap-priority = 100
fs-type = swap
EOF" "Configure ZRAM generator"

enable_service systemd-zram-setup@zram0

# ─── ZSWAP (fallback si no zram) ──────────────────────────────
run_cmd "cat > /etc/sysctl.d/99-kalaos-zswap.conf <<'EOF'
# Zswap settings (used if zram not available)
vm.zswap.enabled=1
vm.zswap.compressor=zstd
vm.zswap.max_pool_percent=20
vm.zswap.zpool=z3fold
EOF" "Configure zswap fallback"

# ─── CPU Governor ──────────────────────────────────────────────
log_step "Setting CPU governor to: $CPU_GOVERNOR"

run_cmd "cat > /etc/default/cpupower <<EOF
governor='$CPU_GOVERNOR'
EOF" "Set cpupower governor"

# ─── IRQ Balance (distribuir interrupciones) ──────────────────
if [[ "$ENABLE_IRQBALANCE" == true ]]; then
    log_step "Enabling irqbalance"
    enable_service irqbalance
fi

# ─── Sysctl optimizations para gaming/latencia ─────────────────
log_step "Applying sysctl optimizations"

run_cmd "cat > /etc/sysctl.d/99-kalaos-gaming.conf <<'EOF'
# KalaOS Gaming/Performance Sysctl

# Virtual Memory
vm.swappiness = 10
vm.vfs_cache_pressure = 50
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
vm.dirty_writeback_centisecs = 1500
vm.dirty_expire_centisecs = 3000

# Network (gaming latency)
net.core.netdev_max_backlog = 16384
net.core.somaxconn = 8192
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.ipv4.tcp_rmem = 4096 1048576 16777216
net.ipv4.tcp_wmem = 4096 1048576 16777216
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_mtu_probing = 1

# Kernel
kernel.sched_autogroup_enabled = 0
kernel.sched_child_runs_first = 1
kernel.sched_migration_cost_ns = 5000000
kernel.sched_min_granularity_ns = 1000000
kernel.sched_wakeup_granularity_ns = 1500000

# Filesystem
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 1024

# GPU/IO
vm.page-cluster = 0
EOF" "Apply gaming sysctl"

# Aplicar inmediatamente
run_cmd "sysctl --system" "Apply sysctl"

# ─── fstrim timer (SSD maintenance) ───────────────────────────
log_step "Enabling fstrim timer"
enable_service fstrim.timer

# ─── tuned profile para gaming ────────────────────────────────
run_cmd "mkdir -p /etc/tuned" "Tuned config dir"
run_cmd "cat > /etc/tuned/kalaos-gaming.conf <<'EOF'
[main]
summary=KalaOS Gaming Profile
description=Optimized for gaming workloads

[cpu]
governor=performance
energy_perf_bias=performance
min_perf_pct=100
force_latency=1

[disk]
devices=!/dev/sd*,!/dev/nvme*
type=ssd

[net]
auto=1

[vm]
transparent_hugepages=always

[sysctl]
vm.swappiness=10
vm.vfs_cache_pressure=50
net.ipv4.tcp_congestion_control=bbr
kernel.sched_autogroup_enabled=0
EOF" "Create tuned gaming profile"

enable_service tuned
run_cmd "tuned-adm profile kalaos-gaming" "Apply tuned gaming profile"

# ─── Preload (app startup) ────────────────────────────────────
# No preload moderno (systemd-homed lo maneja), pero podemos usar systemd-oomd
run_cmd "mkdir -p /etc/systemd/oomd.conf.d" "systemd-oomd config dir"
run_cmd "cat > /etc/systemd/oomd.conf.d/kalaos.conf <<'EOF'
[ManagedOOMMemoryPressureLimit]
DefaultMemoryPressureLimit=80
DefaultMemoryPressureDurationSec=30s

[ManagedOOMMemoryPressureLimitSwap]
DefaultSwapMemoryPressureLimit=90
DefaultSwapMemoryPressureDurationSec=30s
EOF" "Configure systemd-oomd"

enable_service systemd-oomd

# ─── Module loading optimizations ─────────────────────────────
run_cmd "cat > /etc/modprobe.d/kalaos-perf.conf <<'EOF'
# Performance module options
options nvme_core default_ps_max_latency_us=0
options nvme_core io_timeout=4294967295
EOF" "NVMe performance options"

log_ok "Performance module completed"
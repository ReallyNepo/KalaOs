---
name: kalaos
description: KalaOS - Arch-based gaming OS with Hyprland, full context for AI agents
metadata:
  type: project
---

# KalaOS Skill - Contexto completo para AI Agents (Claude Code, opencode)

## Sistema Base
- **Distro**: KalaOS (Arch-based, CachyOS kernel BORE/EEVDF)
- **Kernel**: `cachyos-bore` (default) | `cachyos-eevdf` | `linux-zen`
- **Init**: systemd
- **Bootloader**: systemd-boot
- **Kernel params**: `nvme.noacpi=1 mitigations=off transparent_hugepage=always nowatchdog`

## Desktop Environment
- **WM**: Hyprland (Omarchy-style keybindings, animations, blur, gaps, rounding=8)
- **Bar**: Waybar + Rofi/Wofi + SwayNC
- **Terminal**: Ghostty (Fish + Starship + Atuin + Zoxide + Carapace)
- **Shell**: Fish (default)
- **Login**: Greetd + tuigreet (TUI)

## Gaming Stack
- **Steam** + Proton-GE + Wine-GE + Lutris + Heroic
- **Gamescope** session (Steam Deck style)
- **MangoHud** + vkBasalt + Gamemode
- **Drivers**: NVIDIA (auto: open-dkms RTX 20+, dkms GTX 10-), AMD, Intel

## Configuración Declarativa (Source of Truth)
**Archivo principal**: `/etc/kala/kalaos.conf` (o `~/kalaos/kalaos.conf`)

Variables clave:
- `KERNEL_VARIANT`, `GPU_VENDOR`, `NVIDIA_DRIVER`
- `ENABLE_GAMING`, `GAMESCOPE_SESSION`, `THEME_BASE`
- `DEBLOAT_LEVEL`, `ZRAM_SIZE_PERCENT`, `CPU_GOVERNOR`
- `AUTOLOGIN_USER`, `EXTRA_PACKAGES`, `CUSTOM_REPOS`

## Estructura de Archivos Importantes
```
/etc/kala/kalaos.conf              # Config principal
${KALAOS_REPO:-$HOME/kalaos}/kalaos.conf     # Repo config
/etc/kala/                         # CLI libs
/usr/local/bin/kala                # CLI principal
/usr/local/lib/kala/               # CLI modules
${KALAOS_REPO:-$HOME/kalaos}/modules/        # 14 módulos instaladores (00-13)
${KALAOS_REPO:-$HOME/kalaos}/dotfiles/       # Configs versionados (stow)
```

## Logs y Diagnóstico Crítico
```bash
# Sistema
journalctl -u greetd -f                    # Login issues
journalctl -u NetworkManager -f            # Red
journalctl -u bluetooth -f                 # Bluetooth
journalctl -u gamemoded -f                 # Gaming

# Hyprland
hyprctl monitors
hyprctl workspaces
hyprctl clients
hyprctl devices
hyprctl binds
hyprctl version

# GPU
nvidia-smi                                 # NVIDIA
radeontop                                  # AMD
intel_gpu_top                              # Intel
vulkaninfo                                 # Vulkan

# Performance
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
cat /sys/block/zram0/disksize
zramctl
systemd-analyze blame
```

## Comandos KalaOS CLI (Troubleshooting)
```bash
kala doctor              # Health check completo
kala config show         # Ver config actual
kala config edit         # Editar config
kala update              # Actualizar sistema + reaplicar configs
kala kernel <variant>    # Cambiar kernel
kala gaming <on|off>     # Toggle gaming stack
kala debloat <level>     # Re-ejecutar debloat
kala backup              # Backup configs
kala restore <dir>       # Restaurar backup
kala wallpaper <path>    # Cambiar wallpaper + regenerar tema
kala theme <name>        # Cambiar tema base
```

## Archivos de Config Generados (no editar manualmente)
| Archivo | Generado por | Descripción |
|---------|-------------|-------------|
| `~/.config/hypr/colors-hyprland.conf` | theming | Colores Hyprland |
| `~/.config/waybar/colors-waybar.css` | theming | Colores Waybar |
| `~/.config/ghostty/themes/kalaos-purple-red.conf` | theming | Tema Ghostty |
| `~/.config/rofi/kalaos-theme.rasi` | theming | Tema Rofi |
| `~/.config/gtk-3.0/gtk.css` | theming | GTK3 theme |
| `~/.config/gtk-4.0/gtk.css` | theming | GTK4 theme |
| `~/.config/starship/palette.toml` | theming | Starship palette |
| `/etc/tuigreet/theme-kalaos.toml` | login | Tuigreet theme |

## Módulos de Instalación (Orden)
0. `00-base.sh` - Repos, pacman, base packages, services
1. `01-kernel.sh` - Kernel CachyOS, cmdline, initramfs
2. `02-drivers.sh` - GPU drivers, Vulkan layers
3. `03-gaming.sh` - Steam, Proton-GE, gamescope, MangoHud
4. `04-hyprland.sh` - Hyprland + keybindings
5. `05-shell.sh` - Ghostty, Fish, Starship, Atuin
6. `06-bar.sh` - Waybar, Rofi, Wofi, SwayNC
7. `07-theming.sh` - Matugen, paleta morado/rojo, Aether
8. `08-fonts.sh` - SF Pro, JetBrains Mono Nerd, KalaPixel
9. `09-login.sh` - Greetd + tuigreet
10. `10-cli.sh` - CLI `kala` completa
11. `11-debloat.sh` - Limpieza 3 niveles
12. `12-perf.sh` - ZRAM, governor, irqbalance, sysctl
13. `13-branding.sh` - Logo cat-arch, bootsplash, plymouth

## Troubleshooting Común

### NVIDIA no carga / pantalla negra
```bash
# Verificar driver
nvidia-smi
# Regenerar initramfs
sudo mkinitcpio -p kalaos
# Verificar kernel cmdline
cat /proc/cmdline
```

### Waybar no muestra colores / tema roto
```bash
# Regenerar tema desde wallpaper
${KALAOS_REPO:-$HOME/kalaos}/modules/generate-theme.sh
# Recargar
pkill -USR2 waybar
hyprctl reload
```

### Hyprland no inicia / crash
```bash
# Logs
journalctl --user -u hyprland -f
# Verificar config
hyprctl reload 2>&1
# Verificar GPU
glxinfo | grep "OpenGL renderer"
```

### Gaming performance baja
```bash
kala doctor
# Verificar governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# Debe ser "performance"
# Verificar ZRAM
zramctl
# Verificar gamemode
systemctl status gamemoded
```

### Audio no funciona
```bash
wpctl status
pactl info
systemctl --user status pipewire wireplumber
```

### Fish no es shell / starship no carga
```bash
echo $SHELL
chsh -s /usr/bin/fish
fish -c "starship init fish | source"
```

## Acceso a Configs como AI Agent

### Leer config principal
```bash
cat /etc/kala/kalaos.conf
# o
cat ${KALAOS_REPO:-$HOME/kalaos}/kalaos.conf
```

### Ver módulos instalados
```bash
ls ${KALAOS_REPO:-$HOME/kalaos}/modules/
```

### Ver dotfiles deployados
```bash
ls ~/.config/hypr/
ls ~/.config/ghostty/
ls ~/.config/waybar/
ls ~/.config/rofi/
```

### Ejecutar smoke tests
```bash
${KALAOS_REPO:-$HOME/kalaos}/tests/smoke.sh
```

## Variables de Entorno Gaming
```bash
PROTON_HIDE_NVIDIA_GPUS=0
PROTON_ENABLE_NVAPI=1
PROTON_ENABLE_NGX_UPDATER=1
DXVK_ASYNC=1
DXVK_HUD=0
VKD3D_CONFIG=dxr11,multi_queue
RADV_PERFTEST=aco,ngg,nggc
AMD_DEBUG=useaco
MESA_SHADER_CACHE_MAX_SIZE=16G
__GL_SHADER_DISK_CACHE_SIZE=16777216000
__GL_SHADER_DISK_CACHE_PATH=/var/cache/nvidia
```

## Alias Útiles para Troubleshooting
```bash
alias kala-log='journalctl -f -u greetd -u NetworkManager -u bluetooth -u gamemoded'
alias kala-gpu='nvidia-smi || radeontop || intel_gpu_top'
alias kala-perf='btop'
alias kala-hypr='hyprctl monitors && hyprctl workspaces && hyprctl clients'
alias kala-zram='zramctl && cat /sys/block/zram0/disksize'
alias kala-theme='cat ~/.config/kalaos/theme/current.json | jq'
```
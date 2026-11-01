# KalaOS Installation Guide

## Requisitos previos

- Sistema base Arch Linux o CachyOS minimal instalado
- Conexión a internet
- Usuario con permisos sudo
- Particiones montadas en `/` y `/boot` (o `/efi`)

## Instalación rápida

```bash
# 1. Clonar repositorio
git clone https://github.com/tu-usuario/kalaos.git
cd kalaos

# 2. Revisar configuración (opcional)
nano kalaos.conf

# 3. Ejecutar instalador como root
sudo ./install.sh
```

## Instalación personalizada

### Dry-run (simulación)
```bash
sudo ./install.sh --dry-run
```

### Solo un módulo específico
```bash
sudo ./install.sh --module 07-theming
```

### Saltar módulos
```bash
sudo ./install.sh --skip 11-debloat --skip 03-gaming
```

## Post-instalación

1. **Reboot** para cargar nuevo kernel y drivers
2. **Login** con Greetd + tuigreet
3. **Verificar** con `kala doctor`
4. **Personalizar** wallpaper: `kala wallpaper ~/Pictures/mi-foto.jpg`

## Estructura de directorios

```
kalaos/
├── install.sh              # Instalador principal
├── kalaos.conf             # Configuración declarativa
├── modules/                # Módulos de instalación (00-13)
├── dotfiles/               # Configs versionados (stow/chezmoi)
├── assets/                 # Logo, wallpapers, bootsplash
├── pkglists/               # Listas de paquetes
├── tests/                  # Smoke tests
└── docs/                   # Documentación
```

## Configuración clave (kalaos.conf)

| Variable | Descripción | Valores |
|----------|-------------|---------|
| `KERNEL_VARIANT` | Kernel a instalar | `cachyos-bore`, `cachyos-eevdf`, `linux-zen` |
| `GPU_VENDOR` | GPU detectada | `auto`, `nvidia`, `amd`, `intel`, `hybrid` |
| `NVIDIA_DRIVER` | Driver NVIDIA | `auto`, `nvidia-open-dkms`, `nvidia-dkms` |
| `ENABLE_GAMING` | Stack gaming | `true`, `false` |
| `THEME_BASE` | Tema base colores | `purple-red`, `cyan`, `amber` |
| `DEBLOAT_LEVEL` | Nivel limpieza | `minimal`, `standard`, `aggressive` |
| `LOGIN_MANAGER` | Display manager | `greetd-tuigreet` |

## Troubleshooting

### NVIDIA no detecta modo gráfico
```bash
# Regenerar initramfs
sudo mkinitcpio -p kalaos
# Reboot
```

### Waybar no muestra colores
```bash
# Regenerar tema
kala wallpaper ~/Pictures/wallpaper.jpg
# o
/home/jairo/kalaos/modules/generate-theme.sh
```

### Fish no es shell por defecto
```bash
chsh -s /usr/bin/fish
```

### Gaming performance baja
```bash
# Verificar governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# Debe ser "performance"
kala doctor
```

## Actualizaciones

```bash
# Actualizar sistema + reaplicar configs
kala update

# O manualmente
sudo pacman -Syu
./install.sh
```

## Backup / Restore

```bash
# Backup
kala backup

# Restore
kala restore ~/kalaos-backup-20240115-143000
```

## Desinstalación

```bash
# No hay desinstalador automático
# Para volver a Arch vanilla:
# 1. Eliminar repos CachyOS/chaotic-aur de /etc/pacman.conf
# 2. pacman -Syu
# 3. Cambiar kernel a linux/linux-zen
# 4. Reboot
```
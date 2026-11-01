# KalaOS 🐱

<details open>
<summary><strong>🇪🇸 Español</strong> / <strong>🇺🇸 English</strong></summary>

---

## 🇪🇸 Español

> **Arch-based. Cat-powered. Game-ready.**

KalaOS es una distribución Linux gaming optimizada basada en **kernel CachyOS** con **Hyprland**, **Ghostty**.

```
@@@                                             @@@
               @@@@@@                  @                    @@@@@@
                @@@@@@@@               @ @               @@@@@@@@
               @@@@@@@ @@@@               @          @@@@@ @@@@@@@
               @@@  @@@@  @@@@       @    @@      @@@@   @@@@  @@@
               @@@     @@   @@@@@@@@       @ @@@@@@@   @@      @@
               @@@       @@@@      @        @       @@@@       @@@
               @@@                 @        @@                 @@@
                @@@                           @               @@@
                @@@              @            @@             @@@@
                @@@             @              @              @@
                 @@@           @                @@           @@@
                  @@          @@@@            @@ @           @
                                  @          @
                            @    @@@@      @@@@    @
                           @@    @@@@      @@@@    @@
                                  @          @       @
                          @                          @@
                           @@@@@     @@@@@@      @@@@ @
       @@@@@@@@@@@      @     @@@     @@@@@    @@@     @       @@@@@@@@@@@
                 @@@@@@@@             @@@@             @@@@@@@@
                  @@   @               @@               @   @@
          @ @@@@@@@@ @@@@             @@@@             @@@@ @@@@@@@
     @@@@@@@@        @               @@@@@@               @        @@@@@@@@@
                   @@@              @@@@@@@@              @@@
            @@@@@@ @              @@@@@@@@@@@@              @@@@@@@@@
        @@@@ @                   @@@@@@@@@@@@@@              @     @@@@@
                 @             @@@@@@@@@@@@@@@@@@             @
                @@            @@@@@@@      @@@@@@@            @@
               @            @@@@@@@          @@@@@@@
              @@           @@@@@@@@          @@@@@@@@@          @
              @           @@@@@@@@            @@@@@@@@       @@@ @
             @          @@@@@@@@@              @@@@@@@@@@     @@@ @
            @        @@@@@@@@@@@@@             @@@@@@@@@@@@     @@@@
                   @@@@@@@@@@@@@@              @@@@@@@@@@@@@@      @
          @      @@@@@@@@@@@@@@@@@             @@@@@@@@@@@@@@@@      @
         @@    @@@@@@@@@@@@@@    @            @    @@@@@@@@@@@@@@@   @
            @@@@@@@                                          @@@@@@@
        @ @@@@@@@                                              @@@@@@@ @
       @@@@@@                                                       @@@@@
     @@@                                                                @@ @@@
                                @             @
                                @@           @@
                                  @@        @@
                                   @@      @@
                                    @@@   @@
                                    @@@@@@@@
                                     @@@@@@
```

### ✨ Características

| Área | Detalles |
|------|----------|
| **Kernel** | CachyOS BORE/EEVDF scheduler, x86-64-v3/v4, LTO, PGO |
| **Desktop** | Hyprland (animaciones, blur, gaps, keybindings estilo Omarchy) |
| **Terminal** | Ghostty con syntax highlighting IDE-like, Fish + Starship + Atuin |
| **Bar/Launcher** | Waybar + Rofi/Wofi + SwayNC (tema dinámico desde wallpaper) |
| **Gaming** | Gamescope session, Proton-GE, Wine-GE, MangoHud, vkBasalt, Gamemode |
| **Drivers** | NVIDIA (auto: open-dkms RTX 20+, dkms GTX 10-), AMD, Intel, Vulkan layers |
| **Login** | Greetd + tuigreet (TUI) |
| **Fonts** | macOS SF Pro + JetBrains Mono Nerd + Pixel font custom |
| **Theming** | Paleta rojo/morado base, auto-colores desde wallpaper (matugen) |
| **CLI** | `kala` - gestor propio (install, update, theme, wallpaper, gaming, kernel, doctor, backup, ai) |
| **IA Agents** | `claude-code` + `opencode` con Skill KalaOS preconfigurado |
| **GUI Theming** | Aether + nwg-look |
| **Performance** | ZRAM zstd, CPU governor performance, irqbalance, tuned, sysctl gaming |

---

### 🚀 Instalación Rápida

```bash
# 1. Instala Arch Linux o CachyOS minimal (base + linux-firmware + sudo + networkmanager)
# 2. Clona y ejecuta
git clone https://github.com/ReallyNepo/kalaos.git
cd kalaos
sudo ./install.sh
```

> **Nota**: Requiere sistema base Arch/CachyOS ya instalado con particiones montadas.

---

### ⚙️ Configuración

Edita `kalaos.conf` antes de instalar o después y re-ejecuta `./install.sh`:

```bash
# Ejemplos
KERNEL_VARIANT="cachyos-bore"      # cachyos-eevdf, linux-zen
GPU_VENDOR="auto"                  # nvidia, amd, intel, hybrid
NVIDIA_DRIVER="auto"               # nvidia-open-dkms (RTX 20+), nvidia-dkms (GTX 10-)
ENABLE_GAMING=true
THEME_BASE="red-purple"            # red-purple, cyan, amber, custom
DEBLOAT_LEVEL="aggressive"         # minimal, standard, aggressive
AUTOLOGIN_USER="tu-usuario"        # Para autologin
```

---

### 🎮 Uso Diario

```bash
# Health check completo
kala doctor

# Cambiar wallpaper + tema completo
kala wallpaper ~/Pictures/mi-foto.jpg

# Cambiar tema base
kala theme cyan

# Toggle gaming stack
kala gaming off

# Cambiar kernel
kala kernel cachyos-eevdf

# Actualizar sistema + configs
kala update

# Backup configs
kala backup

# IA Agents con contexto KalaOS
kala ai claude
kala ai opencode
```

---

### 🎨 Theming Dinámico

El sistema extrae colores de tu wallpaper y regenera **todos** los temas:

- Hyprland (bordes, gaps, blur)
- Waybar (CSS)
- Ghostty (terminal + syntax highlighting)
- Rofi/Wofi (launchers)
- GTK3/GTK4 (apps)
- Starship (prompt)
- Tuigreet (login)

```bash
kala wallpaper ~/Pictures/gaming.jpg  # ¡Todo se recolorea!
```

---

### 📁 Estructura del Repo

```
kalaos/
├── install.sh              # Instalador idempotente
├── kalaos.conf             # Config declarativa (source of truth)
├── modules/                # 14 módulos (00-base → 13-branding)
├── dotfiles/               # Configs versionados (stow/chezmoi)
│   ├── hypr/               # Hyprland config
│   ├── ghostty/            # Terminal config
│   ├── waybar/             # Bar config
│   ├── rofi/ wofi/         # Launchers
│   ├── fish/               # Shell config
│   ├── starship/           # Prompt
│   ├── greetd/             # Login
│   ├── kala/               # CLI + AI wrappers
│   └── kalaos-skill.md     # Contexto IA
├── assets/                 # Logo, wallpapers, bootsplash, plymouth
├── pkglists/               # Listas paquetes (core, gaming, fonts, debloat)
├── tests/                  # Smoke tests
└── docs/                   # INSTALL, CONFIG, CUSTOMIZE, BRANDING
```

---

### 🔧 Módulos de Instalación

| Módulo | Descripción |
|--------|-------------|
| `00-base` | Repos, pacman.conf, base packages, services |
| `01-kernel` | Kernel CachyOS (BORE/EEVDF), cmdline, initramfs |
| `02-drivers` | GPU drivers (NVIDIA/AMD/Intel), Vulkan layers |
| `03-gaming` | Steam, Proton-GE, gamescope, MangoHud, gamemode |
| `04-hyprland` | Hyprland + keybindings Omarchy-style |
| `05-shell` | Ghostty, Fish, Starship, Atuin, Zoxide, Carapace |
| `06-bar` | Waybar, Rofi, Wofi, SwayNC |
| `07-theming` | Matugen, paleta rojo/morado, auto-colores, Aether |
| `08-fonts` | SF Pro, JetBrains Mono Nerd, KalaPixel |
| `09-login` | Greetd + tuigreet TUI themed |
| `10-cli` | CLI `kala` + AI agents (`claude-code`, `opencode`) |
| `11-debloat` | Limpieza 3 niveles (apps, locales, docs, man) |
| `12-perf` | ZRAM, governor, irqbalance, sysctl, tuned, fstrim |
| `13-branding` | ASCII logo (Arch + cat ears), bootsplash, plymouth |

---

### 📚 Documentación

- [INSTALL.md](docs/INSTALL.md) - Guía de instalación completa
- [CONFIG.md](docs/CONFIG.md) - Referencia completa kalaos.conf
- [CUSTOMIZE.md](docs/CUSTOMIZE.md) - Personalización avanzada
- [BRANDING.md](docs/BRANDING.md) - Guía de branding y logo

---

### 🐛 Troubleshooting

```bash
# Verificar estado
kala doctor

# Regenerar tema
${KALAOS_REPO:-$HOME/kalaos}/modules/generate-theme.sh

# Rebuild initramfs (NVIDIA)
sudo mkinitcpio -p kalaos

# Ver logs
journalctl -u greetd -f
```

---

## 🇺🇸 English

> **Arch-based. Cat-powered. Game-ready.**

KalaOS is an optimized gaming Linux distribution based on **CachyOS kernel** with **Hyprland**, **Ghostty**.

### ✨ Features

| Area | Details |
|------|---------|
| **Kernel** | CachyOS BORE/EEVDF scheduler, x86-64-v3/v4, LTO, PGO |
| **Desktop** | Hyprland (animations, blur, gaps, Omarchy-style keybindings) |
| **Terminal** | Ghostty with IDE-like syntax highlighting, Fish + Starship + Atuin |
| **Bar/Launcher** | Waybar + Rofi/Wofi + SwayNC (dynamic theme from wallpaper) |
| **Gaming** | Gamescope session, Proton-GE, Wine-GE, MangoHud, vkBasalt, Gamemode |
| **Drivers** | NVIDIA (auto: open-dkms RTX 20+, dkms GTX 10-), AMD, Intel, Vulkan layers |
| **Login** | Greetd + tuigreet (TUI) |
| **Fonts** | macOS SF Pro + JetBrains Mono Nerd + Custom Pixel font |
| **Theming** | Red/purple base palette, auto-colors from wallpaper (matugen) |
| **CLI** | `kala` - own manager (install, update, theme, wallpaper, gaming, kernel, doctor, backup, ai) |
| **AI Agents** | `claude-code` + `opencode` with preconfigured KalaOS Skill |
| **GUI Theming** | Aether + nwg-look |
| **Performance** | ZRAM zstd, CPU governor performance, irqbalance, tuned, sysctl gaming |

---

### 🚀 Quick Install

```bash
# 1. Install Arch Linux or CachyOS minimal (base + linux-firmware + sudo + networkmanager)
# 2. Clone and run
git clone https://github.com/ReallyNepo/kalaos.git
cd kalaos
sudo ./install.sh
```

> **Note**: Requires base Arch/CachyOS already installed with partitions mounted.

---

### ⚙️ Configuration

Edit `kalaos.conf` before install or after and re-run `./install.sh`:

```bash
# Examples
KERNEL_VARIANT="cachyos-bore"      # cachyos-eevdf, linux-zen
GPU_VENDOR="auto"                  # nvidia, amd, intel, hybrid
NVIDIA_DRIVER="auto"               # nvidia-open-dkms (RTX 20+), nvidia-dkms (GTX 10-)
ENABLE_GAMING=true
THEME_BASE="red-purple"            # red-purple, cyan, amber, custom
DEBLOAT_LEVEL="aggressive"         # minimal, standard, aggressive
AUTOLOGIN_USER="your-user"         # For autologin
```

---

### 🎮 Daily Usage

```bash
# Full health check
kala doctor

# Change wallpaper + full theme
kala wallpaper ~/Pictures/my-photo.jpg

# Change base theme
kala theme cyan

# Toggle gaming stack
kala gaming off

# Change kernel
kala kernel cachyos-eevdf

# Update system + configs
kala update

# Backup configs
kala backup

# AI Agents with KalaOS context
kala ai claude
kala ai opencode
```

---

### 🎨 Dynamic Theming

System extracts colors from your wallpaper and regenerates **all** themes:

- Hyprland (borders, gaps, blur)
- Waybar (CSS)
- Ghostty (terminal + syntax highlighting)
- Rofi/Wofi (launchers)
- GTK3/GTK4 (apps)
- Starship (prompt)
- Tuigreet (login)

```bash
kala wallpaper ~/Pictures/gaming.jpg  # Everything recolors!
```

---

### 📁 Repo Structure

```
kalaos/
├── install.sh              # Idempotent installer
├── kalaos.conf             # Declarative config (source of truth)
├── modules/                # 14 modules (00-base → 13-branding)
├── dotfiles/               # Versioned configs (stow/chezmoi)
│   ├── hypr/               # Hyprland config
│   ├── ghostty/            # Terminal config
│   ├── waybar/             # Bar config
│   ├── rofi/ wofi/         # Launchers
│   ├── fish/               # Shell config
│   ├── starship/           # Prompt
│   ├── greetd/             # Login
│   ├── kala/               # CLI + AI wrappers
│   └── kalaos-skill.md     # AI context
├── assets/                 # Logo, wallpapers, bootsplash, plymouth
├── pkglists/               # Package lists (core, gaming, fonts, debloat)
├── tests/                  # Smoke tests
└── docs/                   # INSTALL, CONFIG, CUSTOMIZE, BRANDING
```

---

### 🔧 Install Modules

| Module | Description |
|--------|-------------|
| `00-base` | Repos, pacman.conf, base packages, services |
| `01-kernel` | CachyOS Kernel (BORE/EEVDF), cmdline, initramfs |
| `02-drivers` | GPU drivers (NVIDIA/AMD/Intel), Vulkan layers |
| `03-gaming` | Steam, Proton-GE, gamescope, MangoHud, gamemode |
| `04-hyprland` | Hyprland + Omarchy-style keybindings |
| `05-shell` | Ghostty, Fish, Starship, Atuin, Zoxide, Carapace |
| `06-bar` | Waybar, Rofi, Wofi, SwayNC |
| `07-theming` | Matugen, red/purple palette, auto-colors, Aether |
| `08-fonts` | SF Pro, JetBrains Mono Nerd, KalaPixel |
| `09-login` | Greetd + tuigreet TUI themed |
| `10-cli` | CLI `kala` + AI agents (`claude-code`, `opencode`) |
| `11-debloat` | Cleanup 3 levels (apps, locales, docs, man) |
| `12-perf` | ZRAM, governor, irqbalance, sysctl, tuned, fstrim |
| `13-branding` | ASCII logo (Arch + cat ears), bootsplash, plymouth |

---

### 📚 Documentation

- [INSTALL.md](docs/INSTALL.md) - Complete installation guide
- [CONFIG.md](docs/CONFIG.md) - Full kalaos.conf reference
- [CUSTOMIZE.md](docs/CUSTOMIZE.md) - Advanced customization
- [BRANDING.md](docs/BRANDING.md) - Branding & logo guide

---

### 🐛 Troubleshooting

```bash
# Check status
kala doctor

# Regenerate theme
${KALAOS_REPO:-$HOME/kalaos}/modules/generate-theme.sh

# Rebuild initramfs (NVIDIA)
sudo mkinitcpio -p kalaos

# View logs
journalctl -u greetd -f
```

---

## 🤝 Contributing

1. Fork the repo
2. Create branch: `git checkout -b feature/my-feature`
3. Edit `kalaos.conf` or modules/dotfiles
4. Test: `sudo ./install.sh --dry-run`
5. PR with description

---

## 📄 License

- Code: MIT
- Branding/Logo: CC-BY-SA 4.0

---

---

**Made with ❤️ and 🐱 for gamers who love Arch.**

</details>
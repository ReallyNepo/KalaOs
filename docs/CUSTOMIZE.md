# KalaOS Customization Guide

## Cambiar Tema Base

```bash
# Temas incluidos
kala theme purple-red    # Default: morado/rojo
kala theme cyan          # Cian/azul
kala theme amber         # Ámbar/naranja

# Tema personalizado desde wallpaper
kala wallpaper ~/Pictures/mi-foto.jpg
```

## Wallpaper & Paleta Automática

El sistema usa `matugen`/`wallust` para extraer colores del wallpaper y generar temas para **todos** los componentes:

- Hyprland (bordes, blur, gaps)
- Waybar (colores CSS)
- Ghostty (tema terminal + syntax highlighting)
- Rofi/Wofi (launcher)
- GTK3/GTK4 (apps)
- Starship (prompt)
- Tuigreet (login)
- Tuigreet (login)

```bash
# Setea wallpaper + regenera todo
kala wallpaper ~/Pictures/gaming.jpg

# O manualmente
${KALAOS_REPO:-$HOME/kalaos}/modules/generate-theme.sh ~/Pictures/gaming.jpg
```

## Personalizar Hyprland

Edita `~/.config/hypr/hyprland.conf` (gestionado por stow):

```bash
# Keybindings personalizados
bind = SUPER, T, exec, ghostty -e htop
bind = SUPER SHIFT, T, exec, ghostty -e btop

# Window rules
windowrulev2 = float, class:^(mi-app)$
windowrulev2 = workspace 3, class:^(discord)$

# Animations custom
animation = miAnim, bezier, 0.4, 0.0, 0.2, 1
```

Recarga: `hyprctl reload` o `SUPER+SHIFT+R`

## Personalizar Ghostty

Tema base en `~/.config/ghostty/themes/kalaos-purple-red.conf` (auto-generado).

Override manual en `~/.config/ghostty/config`:

```ini
# Font personalizada
font-family = "Mi Fuente Mono"
font-size = 12

# Opacidad
background-opacity = 0.9

# Keybinds extra
keybind = super+return = new_window
```

## Personalizar Waybar

Config en `~/.config/waybar/config.jsonc`, estilos en `~/.config/waybar/style.css`.

Colores se inyectan desde `~/.config/waybar/colors-waybar.css` (auto-generado).

```json
// Módulo custom
"custom/mi-script": {
    "format": "{}",
    "exec": "~/.config/waybar/scripts/mi-script.sh",
    "interval": 30,
    "on-click": "notify-send 'Click!'"
}
```

Añade al array `modules-right` o `modules-left`.

## Personalizar Starship

Config en `~/.config/starship.toml`. Paleta en `~/.config/starship/palette.toml` (auto).

```toml
# Añadir modulo custom
[custom.uptime]
command = "uptime -p | sed 's/up //'"
format = "⏱ [$output](bold yellow) "
when = true
```

## Personalizar Fish

Config en `~/.config/fish/config.fish`.

```fish
# Aliases custom
alias miscript='~/scripts/mi-script.sh'
abbr -g --add deploy 'mi-script deploy production'

# Funciones
function mi_backup
    tar -czf ~/backup-$(date +%Y%m%d).tar.gz $argv
end
```

## Crear Tema Propio

1. Crea paleta JSON en `~/.config/kalaos/theme/mi-tema.json`:
```json
{
  "name": "Mi Tema",
  "background": "#0d0d0d",
  "foreground": "#ffffff",
  "accent_purple": "#bb86fc",
  "accent_red": "#cf6679",
  "surface": "#1e1e1e",
  "border": "#333333",
  "muted": "#888888"
}
```

2. Aplica:
```bash
cp ~/.config/kalaos/theme/mi-tema.json ~/.config/kalaos/theme/current.json
${KALAOS_REPO:-$HOME/kalaos}/modules/generate-theme.sh
```

3. En `kalaos.conf`: `THEME_BASE="custom"`

## Dotfiles Management

Configs versionados en `~/kalaos/dotfiles/` (usa `stow`):

```bash
# Ver qué está stoweado
stow -n -v -t ~ hypr waybar fish ghostty starship rofi wofi swaync greetd kala

# Re-stow (tras cambios)
cd ~/kalaos && stow -R -t ~ hypr waybar fish ghostty starship rofi wofi swaync greetd kala

# Unstow
stow -D -t ~ hypr
```

## Kala CLI Extensions

Añade subcomandos en `/usr/local/lib/kala/` o `~/.local/share/kala/commands/`:

```bash
# ~/.local/share/kala/commands/mi-comando
#!/usr/bin/env bash
echo "Mi comando custom KalaOS"
```

Luego disponible como: `kala mi-comando`

## Gaming Optimizations Per-Game

```bash
# MangoHud per-game
mangohud steam steam://rungameid/APPID

# gamemode
gamemoderun %command%

# gamescope
gamescope -W 1920 -H 1080 -r 144 -f -- %command%

# Variables de entorno en launch options Steam:
PROTON_HIDE_NVIDIA_GPUS=0 PROTON_ENABLE_NVAPI=1 DXVK_ASYNC=1 %command%
```

## Kernel Parameters

Edita `KERNEL_CMDLINE` en `kalaos.conf` y re-ejecuta `./install.sh` o módulo `01-kernel`:

```bash
# Para low latency audio
threadirqs

# Para CPU isolation (gaming)
isolcpus=6,7 nohz_full=6,7 rcu_nocbs=6,7

# Para NVIDIA specific
nvidia_drm.modeset=1 nvidia_drm.fbdev=1
```
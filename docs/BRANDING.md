# KalaOS Branding Guide

## Logo: KalaOS Cat-Arch

### Concepto
Logo basado en Arch Linux (triángulo) + orejas de gato, proporcionado por el usuario como imagen PNG.

### Archivos
```
assets/logo/
├── kalaos-logo.png              # Logo fuente (PNG proporcionado por usuario, 1024x1536)
├── kalaos-ascii.txt             # ASCII art para terminal (generado con chafa)
```

Los iconos de sistema (16x16 a 512x512) se generan automáticamente desde `kalaos-logo.png` durante la instalación.

### Paleta de Colores Oficial

| Color | Hex | RGB | Uso |
|-------|-----|-----|-----|
| **Purple Dark** | `#1A0D1F` | 26, 13, 31 | Background principal |
| **Purple Base** | `#7C3AED` | 124, 58, 237 | Accent primario |
| **Purple Light** | `#A855F7` | 168, 85, 247 | Hover, focus |
| **Red Base** | `#C0392B` | 192, 57, 43 | Accent secundario |
| **Red Light** | `#E74C3C` | 231, 76, 60 | Warning, error |
| **Orange Accent** | `#FF6B35` | 255, 107, 53 | Cursor, highlights |
| **Foreground** | `#F5E6F8` | 245, 230, 248 | Texto principal |
| **Surface** | `#241230` | 36, 18, 48 | Cards, panels |
| **Border** | `#3D1A4A` | 61, 26, 74 | Bordes sutiles |

### Gradientes Oficiales

```css
/* Purple gradient */
background: linear-gradient(135deg, #7C3AED 0%, #A855F7 100%);

/* Red gradient */
background: linear-gradient(315deg, #C0392B 0%, #E74C3C 100%);

/* Combined (logo) */
background: conic-gradient(from 45deg, #7C3AED, #C0392B, #7C3AED);
```

## Tipografía

| Uso | Fuente | Fallback |
|-----|--------|----------|
| UI/Headings | SF Pro Display | Noto Sans, Inter |
| UI/Body | SF Pro Text | Noto Sans, Inter |
| Mono/Code | JetBrains Mono Nerd Font | FiraCode Nerd Font, SF Mono |
| Pixel/Logo | KalaPixel | (custom) |

## Elementos Visuales

### Cat Ears (Orejas)
- Forma: Triángulo isósceles (parte del logo PNG)
- Color: Red gradient (`#C0392B` → `#E74C3C`)
- Inner ear: `#FF6B35` (orange accent)
- Posición: En vértices superiores del triángulo Arch

## Aplicaciones

### Boot Splash / Plymouth
- Logo centrado 256x256 (generado desde kalaos-logo.png)
- Texto "KalaOS" debajo (monospace, 28px, `#F5E6F8`)
- Tagline: "Arch-based. Cat-powered. Game-ready." (12px, `#7C3AED`)
- Progress bar: Purple border, Red fill
- Animación: Pulse logo (scale 1.0→1.02), pulse text color

### SDDM / Greetd (tuigreet)
- Background: `#1A0D1F`
- Logo: 128x128 arriba (generado desde kalaos-logo.png)
- Input fields: Surface background, purple focus border
- Buttons: Purple background, dark text
- Hover: Light purple

### Terminal (fastfetch/neofetch)
- Logo ASCII/Chafa 60x30 (generado desde kalaos-logo.png, guardado en kalaos-ascii.txt)
- Info cols: Purple keys, Red values
- Separator: ` -> `

### Desktop (Waybar, Rofi, Notifications)
- Border radius: 8px (match Hyprland)
- Focus ring: 2px solid `#7C3AED`
- Hover states: Surface + 10% opacity

## Merchandising / Assets Adicionales

### Wallpapers Base (incluidos)
```
assets/wallpapers/
├── kalaos-purple-red-abstract.jpg    # Abstracto morado/rojo
├── kalaos-cat-arch-minimal.jpg       # Logo centrado minimal
├── kalaos-gaming-rgb.jpg             # Estilo gaming RGB
└── kalaos-cyberpunk.jpg              # Cyberpunk morado/rojo
```

### Iconos .desktop
```
/usr/share/applications/kalaos-*.desktop
```
Todos usan `Icon=kalaos` (resuelve a hicolor apps/kalaos.png)

### Cursor Theme
- Basado en `bibata-modern-amber`
- Custom cursors para: resize, move, link, crosshair
- Color accent: `#FF6B35`

## Generar Assets

```bash
# Desde PNG fuente a iconos de sistema múltiples tamaños
for size in 16 32 48 64 128 256 512; do
  magick assets/logo/kalaos-logo.png \
         -resize ${size}x${size} \
         /usr/share/icons/hicolor/${size}x${size}/apps/kalaos.png
done

# Boot splash (256x256)
magick assets/logo/kalaos-logo.png -resize 256x256 /boot/splash/kalaos.png

# Plymouth (256x256)
magick assets/logo/kalaos-logo.png -resize 256x256 /usr/share/plymouth/themes/kalaos/kalaos-logo.png

# SDDM background (1920x1080)
magick assets/logo/kalaos-logo.png -resize 1920x1080 /usr/share/sddm/themes/kalaos/background.png

# ASCII para terminal (fastfetch)
chafa --format=symbols --symbols=block --colors=256 --size=60x30 assets/logo/kalaos-logo.png > assets/logo/kalaos-ascii.txt

# Favicon ICO
magick assets/logo/kalaos-logo.png -resize 16x16 assets/logo/favicon-16.png
magick assets/logo/kalaos-logo.png -resize 32x32 assets/logo/favicon-32.png
magick assets/logo/kalaos-logo.png -resize 48x48 assets/logo/favicon-48.png
```

## Guidelines

### DO ✅
- Usar paleta oficial exacta
- Mantener proporciones logo (1:1)
- Espacio de seguridad: 10% alrededor
- Animaciones sutiles (200-300ms)

### DON'T ❌
- Estirar/deformar logo
- Cambiar colores sin generar tema completo
- Usar logo sobre fondos con poco contraste
- Añadir efectos (sombras, glows) al logo base

## Licencia
Logo y branding: CC-BY-SA 4.0
Código: MIT
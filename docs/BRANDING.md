# KalaOS Branding Guide

## Logo: Cat-Arch

### Concepto
Logo oficial de Arch Linux (triángulo) + orejas de gato + bigotes + ojos animados.

### Archivos
```
assets/logo/
├── kalaos-cat-arch.svg          # Vectorial (fuente)
├── kalaos-cat-arch-16.png       # 16x16  (favicon, tray)
├── kalaos-cat-arch-32.png       # 32x32  (taskbar, alt-tab)
├── kalaos-cat-arch-48.png       # 48x48  (app launcher)
├── kalaos-cat-arch-64.png       # 64x64  (dock)
├── kalaos-cat-arch-128.png      # 128x128 (about)
├── kalaos-cat-arch-256.png      # 256x256 (bootsplash, plymouth)
└── kalaos-cat-arch-512.png      # 512x512 (installer, SDDM)
```

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
- Forma: Triángulo isósceles
- Color: Red gradient (`#C0392B` → `#E74C3C`)
- Inner ear: `#FF6B35` (orange accent)
- Posición: En vértices superiores del triángulo Arch

### Whiskers (Bigotes)
- 3 por lado
- Color: `#F5E6F8` @ 70% opacity
- Curvatura sutil hacia afuera

### Eyes (Ojos)
- Forma: Elipse vertical (rx=18, ry=28)
- Color: `#FF6B35` (orange)
- Pupila: Elipse vertical (rx=6, ry=16) color `#1A0D1F`
- Animación: Parpadeo cada 4s (ry: 28→4→28)

## Aplicaciones

### Boot Splash / Plymouth
- Logo centrado 256x256
- Texto "KalaOS" debajo (monospace, 28px, `#F5E6F8`)
- Tagline: "Arch-based. Cat-powered. Game-ready." (12px, `#7C3AED`)
- Progress bar: Purple border, Red fill
- Animación: Pulse logo (scale 1.0→1.02), pulse text color

### SDDM / Greetd (tuigreet)
- Background: `#1A0D1F`
- Logo: 128x128 arriba
- Input fields: Surface background, purple focus border
- Buttons: Purple background, dark text
- Hover: Light purple

### Terminal (fastfetch/neofetch)
- Logo ASCII/Chafa 40x20
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
# Desde SVG a PNGs múltiples tamaños
for size in 16 32 48 64 128 256 512; do
  magick assets/logo/kalaos-cat-arch.svg \
         -resize ${size}x${size} \
         assets/logo/kalaos-cat-arch-${size}.png
done

# Favicon ICO
magick assets/logo/kalaos-cat-arch-{16,32,48,64}.png assets/logo/favicon.ico
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
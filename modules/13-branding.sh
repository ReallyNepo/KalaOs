#!/usr/bin/env bash
# Module: 13-branding - Logo pixel-art cat-arch, boot splash, plymouth theme

log_step "Installing KalaOS branding (logo, bootsplash, plymouth)"

BRANDING_PKGS=(
    plymouth
    chafa                    # Terminal image viewer para logo
    imagemagick              # Image processing
)

pacman_install "${BRANDING_PKGS[@]}"

# ─── Crear logo pixel-art cat-arch (SVG + PNGs) ───────────────
log_step "Creating pixel-art cat-arch logo"

mkdir -p /home/jairo/kalaos/assets/logo

# SVG vectorial del logo cat-arch (Arch triangle + cat ears)
cat > /home/jairo/kalaos/assets/logo/kalaos-cat-arch.svg <<'SVG_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
  <!-- KalaOS Cat-Arch Logo - Pixel Art Style -->
  <!-- Colors: Purple #7C3AED, Red #C0392B, Dark #1A0D1F, Light #F5E6F8 -->

  <defs>
    <linearGradient id="purpleGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#7C3AED;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#A855F7;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="redGrad" x1="0%" y1="100%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#C0392B;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#E74C3C;stop-opacity:1" />
    </linearGradient>
  </defs>

  <!-- Background circle (optional) -->
  <circle cx="256" cy="256" r="240" fill="#1A0D1F" stroke="#7C3AED" stroke-width="4"/>

  <!-- Arch Triangle (main shape) - Purple gradient -->
  <polygon points="256,40 460,440 60,440" fill="url(#purpleGrad)" stroke="#A855F7" stroke-width="3"/>

  <!-- Inner triangle highlight -->
  <polygon points="256,80 420,410 92,410" fill="none" stroke="#A855F7" stroke-width="1" opacity="0.5"/>

  <!-- Cat Ears (left) - Red gradient -->
  <polygon points="120,180 160,80 200,180" fill="url(#redGrad)" stroke="#E74C3C" stroke-width="2"/>
  <!-- Cat Ear inner -->
  <polygon points="135,170 160,100 185,170" fill="#FF6B35" opacity="0.8"/>

  <!-- Cat Ears (right) - Red gradient -->
  <polygon points="312,180 352,80 392,180" fill="url(#redGrad)" stroke="#E74C3C" stroke-width="2"/>
  <!-- Cat Ear inner -->
  <polygon points="327,170 352,100 377,170" fill="#FF6B35" opacity="0.8"/>

  <!-- Whiskers (left) -->
  <g stroke="#F5E6F8" stroke-width="2" opacity="0.7">
    <line x1="160" y1="280" x2="80" y2="260"/>
    <line x1="160" y1="300" x2="70" y2="300"/>
    <line x1="160" y1="320" x2="80" y2="340"/>
  </g>

  <!-- Whiskers (right) -->
  <g stroke="#F5E6F8" stroke-width="2" opacity="0.7">
    <line x1="352" y1="280" x2="432" y2="260"/>
    <line x1="352" y1="300" x2="442" y2="300"/>
    <line x1="352" y1="320" x2="432" y2="340"/>
  </g>

  <!-- Eyes (cat-style) -->
  <ellipse cx="200" cy="260" rx="18" ry="28" fill="#FF6B35">
    <animate attributeName="ry" values="28;4;28" dur="4s" repeatCount="indefinite" begin="0s"/>
  </ellipse>
  <ellipse cx="312" cy="260" rx="18" ry="28" fill="#FF6B35">
    <animate attributeName="ry" values="28;4;28" dur="4s" repeatCount="indefinite" begin="0.1s"/>
  </ellipse>

  <!-- Pupils -->
  <ellipse cx="200" cy="260" rx="6" ry="16" fill="#1A0D1F"/>
  <ellipse cx="312" cy="260" rx="6" ry="16" fill="#1A0D1F"/>

  <!-- Nose -->
  <polygon points="256,300 248,315 264,315" fill="#C0392B"/>

  <!-- Mouth -->
  <path d="M 256 315 Q 256 330 240 330 M 256 315 Q 256 330 272 330" stroke="#C0392B" stroke-width="2" fill="none"/>

  <!-- "KALA" text bottom -->
  <text x="256" y="460" font-family="monospace" font-size="28" font-weight="bold"
        fill="#F5E6F8" text-anchor="middle" letter-spacing="8">KALA</text>
  <text x="256" y="485" font-family="monospace" font-size="12"
        fill="#A855F7" text-anchor="middle">OS</text>
</svg>
SVG_EOF

# Generar PNGs en múltiples resoluciones
log_step "Generating PNG variants from SVG"
for size in 16 32 48 64 128 256 512; do
    magick /home/jairo/kalaos/assets/logo/kalaos-cat-arch.svg \
           -resize ${size}x${size} \
           /home/jairo/kalaos/assets/logo/kalaos-cat-arch-${size}.png 2>/dev/null || \
    convert /home/jairo/kalaos/assets/logo/kalaos-cat-arch.svg \
            -resize ${size}x${size} \
            /home/jairo/kalaos/assets/logo/kalaos-cat-arch-${size}.png 2>/dev/null || true
done

# Instalar iconos en sistema
run_cmd "mkdir -p /usr/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128,256x256,512x512}/apps" "Icon directories"
for size in 16 32 48 64 128 256 512; do
    if [[ -f /home/jairo/kalaos/assets/logo/kalaos-cat-arch-${size}.png ]]; then
        run_cmd "cp /home/jairo/kalaos/assets/logo/kalaos-cat-arch-${size}.png /usr/share/icons/hicolor/${size}x${size}/apps/kalaos.png" "Install ${size}px icon"
    fi
done

# ─── Boot Splash (systemd-boot / GRUB) ────────────────────────
if [[ "$BOOTSPLASH" == true ]]; then
    log_step "Configuring boot splash"

    # systemd-boot splash
    if [[ "$BOOTLOADER" == "systemd-boot" ]]; then
        run_cmd "mkdir -p /boot/splash" "Boot splash dir"
        run_cmd "cp /home/jairo/kalaos/assets/logo/kalaos-cat-arch-256.png /boot/splash/kalaos.png" "Copy splash image"

        # kernel cmdline ya tiene quiet splash en 01-kernel.sh
        # Agregar splash a entries
        for entry in /boot/loader/entries/*.conf; do
            [[ -f "$entry" ]] && run_cmd "sed -i 's/^options /options splash /' '$entry'" "Add splash to $entry"
        done
    fi

    # GRUB splash
    if [[ "$BOOTLOADER" == "grub" ]]; then
        run_cmd "cp /home/jairo/kalaos/assets/logo/kalaos-cat-arch-256.png /boot/grub/kalaos.png" "GRUB splash"
        run_cmd "sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/& splash quiet/' /etc/default/grub" "GRUB cmdline splash"
        run_cmd "grub-mkconfig -o /boot/grub/grub.cfg" "Regenerate GRUB"
    fi
fi

# ─── Plymouth Theme KalaOS ────────────────────────────────────
log_step "Creating Plymouth theme"

mkdir -p /usr/share/plymouth/themes/kalaos

cat > /usr/share/plymouth/themes/kalaos/kalaos.plymouth <<'PLYMOUTH_EOF'
[Plymouth Theme]
Name=KalaOS
Description=KalaOS Cat-Arch Boot Theme
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/kalaos
ScriptFile=/usr/share/plymouth/themes/kalaos/kalaos.script
PLYMOUTH_EOF

cat > /usr/share/plymouth/themes/kalaos/kalaos.script <<'PLYMOUTH_SCRIPT_EOF'
# KalaOS Plymouth Theme Script

# Colors
purple = 0.486, 0.227, 0.929;  # #7C3AED
red = 0.753, 0.224, 0.169;     # #C0392B
dark = 0.102, 0.051, 0.122;    # #1A0D1F
light = 0.961, 0.902, 0.973;   # #F5E6F8

# Background
Window.SetBackgroundTopColor(dark[0], dark[1], dark[2]);
Window.SetBackgroundBottomColor(0.05, 0.02, 0.06);

# Logo
logo_image = Image("kalaos-cat-arch-256.png");
logo_sprite = Sprite(logo_image);
logo_sprite.SetX(Window.GetWidth() / 2 - logo_image.GetWidth() / 2);
logo_sprite.SetY(Window.GetHeight() / 2 - logo_image.GetHeight() / 2 - 40);

# Text
text_font = Font("SF Pro Display", 24);
text_sprite = Sprite.NewText("KalaOS", text_font, light[0], light[1], light[2]);
text_sprite.SetX(Window.GetWidth() / 2 - text_sprite.GetWidth() / 2);
text_sprite.SetY(logo_sprite.GetY() + logo_image.GetHeight() + 20);

# Tagline
tagline_font = Font("SF Pro Display", 12);
tagline_sprite = Sprite.NewText("Arch-based. Cat-powered. Game-ready.", tagline_font, purple[0], purple[1], purple[2]);
tagline_sprite.SetX(Window.GetWidth() / 2 - tagline_sprite.GetWidth() / 2);
tagline_sprite.SetY(text_sprite.GetY() + text_sprite.GetHeight() + 10);

# Progress bar
progress_box_image = Image("progress_box.png");
progress_bar_image = Image("progress_bar.png");
progress_box_sprite = Sprite(progress_box_image);
progress_box_sprite.SetX(Window.GetWidth() / 2 - progress_box_image.GetWidth() / 2);
progress_box_sprite.SetY(Window.GetHeight() - 100);

progress_bar_sprite = Sprite(progress_bar_image);
progress_bar_sprite.SetX(progress_box_sprite.GetX() + 4);
progress_bar_sprite.SetY(progress_box_sprite.GetY() + 4);

# Animation
anim_time = 0;

fun refresh_callback = () {
    anim_time = anim_time + 0.02;

    # Pulse logo
    scale = 1.0 + Math.Sin(anim_time * 2) * 0.02;
    logo_sprite.SetScale(scale, scale);

    # Pulse text color
    r = purple[0] + Math.Sin(anim_time * 3) * 0.1;
    g = purple[1] + Math.Sin(anim_time * 3 + 1) * 0.1;
    b = purple[2] + Math.Sin(anim_time * 3 + 2) * 0.1;
    text_sprite.SetColor(r, g, b);
}

fun progress_callback = (duration, progress) {
    progress_bar_sprite.SetScale(progress, 1);
}

Plymouth.SetRefreshFunction(refresh_callback);
Plymouth.SetBootProgressFunction(progress_callback);
PLYMOUTH_SCRIPT_EOF

# Crear imágenes simples para progress bar
cat > /usr/share/plymouth/themes/kalaos/progress_box.png <<'EOF'
# Placeholder - generate with imagemagick
EOF
magick -size 300x20 xc:"#241230" -stroke "#7C3AED" -strokewidth 2 -draw "rectangle 0,0 299,19" /usr/share/plymouth/themes/kalaos/progress_box.png 2>/dev/null || true
magick -size 292x12 xc:"#7C3AED" /usr/share/plymouth/themes/kalaos/progress_bar.png 2>/dev/null || true

# Copiar logo
cp /home/jairo/kalaos/assets/logo/kalaos-cat-arch-256.png /usr/share/plymouth/themes/kalaos/ 2>/dev/null || true

# Set plymouth theme
run_cmd "plymouth-set-default-theme -R kalaos" "Set KalaOS plymouth theme"

# ─── Fastfetch/Neofetch config con logo ───────────────────────
log_step "Configuring fastfetch with KalaOS logo"

mkdir -p /home/jairo/kalaos/dotfiles/fastfetch
cat > /home/jairo/kalaos/dotfiles/fastfetch/config.jsonc <<'FASTFETCH_EOF'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "/home/jairo/kalaos/assets/logo/kalaos-cat-arch.svg",
        "type": "chafa",
        "width": 40,
        "height": 20,
        "color": "auto"
    },
    "display": {
        "separator": " -> ",
        "keys": ["os", "host", "kernel", "uptime", "packages", "shell", "display", "wm", "wmtheme", "theme", "icons", "font", "cursor", "terminal", "terminalfont", "cpu", "gpu", "memory", "disk", "battery", "locale", "break", "colors"]
    }
}
FASTFETCH_EOF

# ─── SDDM theme (fallback si no greetd) ───────────────────────
mkdir -p /usr/share/sddm/themes/kalaos
cat > /usr/share/sddm/themes/kalaos/theme.conf <<'SDDM_EOF'
[Theme]
Name=KalaOS
Author=KalaOS Team
Description=KalaOS Cat-Arch SDDM Theme
Version=1.0
Website=https://kalaos.example.com
License=GPL-3.0-or-later

[General]
Background=/usr/share/sddm/themes/kalaos/background.png
Font=SF Pro Display
FontSize=24
SDDM_EOF

cp /home/jairo/kalaos/assets/logo/kalaos-cat-arch-512.png /usr/share/sddm/themes/kalaos/background.png 2>/dev/null || true

# ─── Actualizar icon cache ────────────────────────────────────
run_cmd "gtk-update-icon-cache -f /usr/share/icons/hicolor" "Update icon cache"

log_ok "Branding module completed"
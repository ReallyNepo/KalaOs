#!/usr/bin/env bash
# Module: 08-fonts - macOS fonts (SF Pro) + JetBrains Mono Nerd + pixel font

log_step "Installing fonts: macOS SF Pro + JetBrains Mono Nerd + pixel font"

FONTS_PKGS=(
    # Nerd fonts
    ttf-jetbrains-mono-nerd
    ttf-firacode-nerd
    ttf-font-awesome
    noto-fonts-emoji
    # Font management
    fontconfig
    font-manager
)

pacman_install "${FONTS_PKGS[@]}"

# ─── macOS San Francisco fonts (requiere descarga manual o AUR) ───
log_step "Setting up macOS San Francisco fonts"

# SF Pro se instala via AUR (sf-pro-fonts) o descarga manual
# Usamos AUR para automatizar
aur_install ttf-san-francisco-pro ttf-san-francisco-mono

# ─── Pixel font para logo/UI (KalaPixel) ───────────────────────
log_step "Creating KalaPixel pixel font"

mkdir -p ${KALAOS_REPO:-$HOME/kalaos}/assets/fonts/KalaPixel

# Crear font bitmap simple para el logo (usando fontforge o bdf)
# Por ahora creamos un placeholder - se reemplaza con font real
cat > ${KALAOS_REPO:-$HOME/kalaos}/assets/fonts/KalaPixel/README.md <<'FONT_README_EOF'
# KalaPixel Font

Fuente pixel art personalizada para KALAOS logo y elementos UI.

## Generar desde logo (user provided PNG)

1. Usar logo en assets/logo/kalaos-logo.png
2. Usar fontforge o tools online (fontello, icomoon) para generar TTF/WOFF
3. Colocar aquí como KalaPixel.ttf

## Caracteres mapeados:
- 'K' = Logo cat-arch completo
- 'A' = Orejas de gato
- 'L' = Triángulo Arch
- 'O' = Bigotes
- 0-9 = Iconos gaming (gamepad, steam, etc.)
EOF

# ─── Fontconfig para priorizar fuentes KalaOS ─────────────────
run_cmd "mkdir -p /etc/fonts/conf.d" "Fontconfig dir"

cat > /etc/fonts/local.conf <<'FONTCONFIG_EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- Alias para UI -->
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>SF Pro Display</family>
      <family>SF Pro Text</family>
      <family>Noto Sans</family>
      <family>JetBrains Mono Nerd Font</family>
    </prefer>
  </alias>

  <alias>
    <family>monospace</family>
    <prefer>
      <family>JetBrains Mono Nerd Font</family>
      <family>SF Mono</family>
      <family>Noto Sans Mono</family>
    </prefer>
  </alias>

  <alias>
    <family>KalaPixel</family>
    <prefer>
      <family>KalaPixel</family>
    </prefer>
  </alias>

  <!-- Rendering optimizado -->
  <match target="font">
    <edit name="antialias" mode="assign"><bool>true</bool></edit>
    <edit name="hinting" mode="assign"><bool>true</bool></edit>
    <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
    <edit name="rgba" mode="assign"><const>rgb</const></edit>
    <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
  </match>

  <!-- Emoji color -->
  <match target="pattern">
    <test qual="any" name="family"><string>emoji</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Noto Color Emoji</string>
    </edit>
  </match>
</fontconfig>
FONTCONFIG_EOF

# ─── Rebuild font cache ────────────────────────────────────────
run_cmd "fc-cache -fv" "Rebuild font cache"

log_ok "Fonts module completed"
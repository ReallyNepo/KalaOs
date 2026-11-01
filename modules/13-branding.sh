#!/usr/bin/env bash
# Module: 13-branding - KalaOS logo (user provided PNG), boot splash, plymouth theme

log_step "Installing KalaOS branding (logo, bootsplash, plymouth)"

BRANDING_PKGS=(
    plymouth
    chafa                    # Terminal image viewer para logo ASCII
    imagemagick              # Image processing
)

pacman_install "${BRANDING_PKGS[@]}"

# ─── Usar logo proporcionado por el usuario ───────────────────────
log_step "Setting up KalaOS logo from user file"

LOGO_SRC="${KALAOS_REPO:-$HOME/kalaos}/assets/logo/kalaos-logo.png"
LOGO_DIR="/usr/share/icons/hicolor"

# Verificar que existe el logo
if [[ ! -f "$LOGO_SRC" ]]; then
    log_warn "Logo no encontrado en $LOGO_SRC, saltando branding"
    return 0
fi

# Instalar iconos en sistema (múltiples resoluciones)
run_cmd "mkdir -p $LOGO_DIR/{16x16,32x32,48x48,64x64,128x128,256x256,512x512}/apps" "Icon directories"
for size in 16 32 48 64 128 256 512; do
    run_cmd "magick '$LOGO_SRC' -resize ${size}x${size} '$LOGO_DIR/${size}x${size}/apps/kalaos.png'" "Install ${size}px icon"
done

# ─── Generar ASCII para terminal (fastfetch) ──────────────────────
log_step "Generating ASCII logo for terminal"

run_cmd "mkdir -p ${SCRIPT_DIR:-$HOME/kalaos}/assets/logo" "Assets logo dir"
mkdir -p "${KALAOS_REPO:-$HOME/kalaos}/dotfiles/fastfetch"
chafa --format=symbols --symbols=block --colors=256 --size=60x30 "$LOGO_SRC" > "${KALAOS_REPO:-$HOME/kalaos}/assets/logo/kalaos-ascii.txt" 2>/dev/null || {
    # Fallback si chafa falla
    cat > "${KALAOS_REPO:-$HOME/kalaos}/assets/logo/kalaos-ascii.txt" <<'ASCII_EOF'
\e[31m
       /\
      /  \
                   -`
                  .o+`
                 `ooo/
                `+oooo:
               `+oooooo:
               -+oooooo+:
             `/:-:++oooo+:
            `/++++/+++++++:
           `/++++++++++++++:
          `/+++ooooooooooooo/
         ./ooosssso++osssssso+
        .oossssso-````/ossssss+
       -osssssso.      :ssssssso.
      :osssssss/        osssso+++.
     /ossssssss/        +ssssooo/-
   `/ossssso+/:-        -:/+osssso+-
  `+sso+:-`                 `.-/+oso:
 `++:.                           `-/+/
 .`                                 `/
\e[0m
ASCII_EOF
}

# ─── Boot Splash (systemd-boot / GRUB) ────────────────────────
if [[ "$BOOTSPLASH" == true ]]; then
    log_step "Configuring boot splash"

    # systemd-boot splash
    if [[ "$BOOTLOADER" == "systemd-boot" ]]; then
        run_cmd "mkdir -p /boot/splash" "Boot splash dir"
        run_cmd "magick '$LOGO_SRC' -resize 256x256 /boot/splash/kalaos.png" "Copy splash image"

        for entry in /boot/loader/entries/*.conf; do
            [[ -f "$entry" ]] && run_cmd "sed -i 's/^options /options splash /' '$entry'" "Add splash to $entry"
        done
    fi

    # GRUB splash
    if [[ "$BOOTLOADER" == "grub" ]]; then
        run_cmd "magick '$LOGO_SRC' -resize 256x256 /boot/grub/kalaos.png" "GRUB splash"
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
Description=KalaOS Boot Theme
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/kalaos
ScriptFile=/usr/share/plymouth/themes/kalaos/kalaos.script
PLYMOUTH_EOF

# Copiar logo para plymouth
run_cmd "magick '$LOGO_SRC' -resize 256x256 /usr/share/plymouth/themes/kalaos/kalaos-logo.png" "Plymouth logo"

cat > /usr/share/plymouth/themes/kalaos/kalaos.script <<'PLYMOUTH_SCRIPT_EOF'
# KalaOS Plymouth Theme Script

# Colors (purple/red palette)
purple = 0.486, 0.227, 0.929;  # #7C3AED
red = 0.753, 0.224, 0.169;     # #C0392B
dark = 0.102, 0.051, 0.122;    # #1A0D1F
light = 0.961, 0.902, 0.973;   # #F5E6F8

# Background
Window.SetBackgroundTopColor(dark[0], dark[1], dark[2]);
Window.SetBackgroundBottomColor(0.05, 0.02, 0.06);

# Logo
logo_image = Image("kalaos-logo.png");
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
magick -size 300x20 xc:"#241230" -stroke "#7C3AED" -strokewidth 2 -draw "rectangle 0,0 299,19" /usr/share/plymouth/themes/kalaos/progress_box.png 2>/dev/null || true
magick -size 292x12 xc:"#7C3AED" /usr/share/plymouth/themes/kalaos/progress_bar.png 2>/dev/null || true

# Set plymouth theme
run_cmd "plymouth-set-default-theme -R kalaos" "Set KalaOS plymouth theme"

# ─── Fastfetch config con logo ASCII ───────────────────────────
log_step "Configuring fastfetch with KalaOS ASCII logo"

cat > "${KALAOS_REPO:-$HOME/kalaos}/dotfiles/fastfetch/config.jsonc" <<'FASTFETCH_EOF'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "${KALAOS_REPO:-$HOME/kalaos}/assets/logo/kalaos-ascii.txt",
        "type": "cat",
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
Description=KalaOS SDDM Theme
Version=1.0
Website=https://kalaos.example.com
License=GPL-3.0-or-later

[General]
Background=/usr/share/sddm/themes/kalaos/background.png
Font=SF Pro Display
FontSize=24
SDDM_EOF

run_cmd "magick '$LOGO_SRC' -resize 1920x1080 /usr/share/sddm/themes/kalaos/background.png" "SDDM background"

# ─── Actualizar icon cache ────────────────────────────────────
run_cmd "gtk-update-icon-cache -f /usr/share/icons/hicolor" "Update icon cache"

log_ok "Branding module completed"
#!/usr/bin/env bash
# Module: 11-debloat - Limpieza agresiva (apps, locales, docs, man, themes extra)

log_step "Running debloat (level: $DEBLOAT_LEVEL)"

# ─── Paquetes a remover según nivel ────────────────────────────
DEBLOAT_PKGS_MINIMAL=(
    # Apps que no usa un gamer/power user
    gnome-text-editor
    gnome-calculator
    gnome-clocks
    gnome-weather
    gnome-maps
    gnome-contacts
    gnome-calendar
    totem
    rhythmbox
    cheese
    simple-scan
    baobab
    file-roller
    evince
    eog
    loupe
    snapshot
)

DEBLOAT_PKGS_STANDARD=(
    "${DEBLOAT_PKGS_MINIMAL[@]}"
    # Más apps
    firefox
    thunderbird
    libreoffice-fresh
    gimp
    inkscape
    audacity
    obs-studio
    kdenlive
    # Terminals extra (tenemos ghostty)
    alacritty
    kitty
    foot
    konsole
    gnome-terminal
    kgx
    # Editors extra (usamos nvim)
    code
    geany
    mousepad
    # Multimedia extra
    vlc
    mpv
    celluloid
)

DEBLOAT_PKGS_AGGRESSIVE=(
    "${DEBLOAT_PKGS_STANDARD[@]}"
    # Todo lo que no sea estrictamente necesario para gaming + hyprland
    nautilus
    thunar
    dolphin
    pcmanfm
    # Network managers extra
    network-manager-applet  # si usas solo nmcli/nmtui
    # Bluetooth GUI extra
    blueman
    # Printing
    cups
    system-config-printer
    # Accessibility
    orca
    speech-dispatcher
    # Docs/man (se limpian abajo aparte)
)

case "$DEBLOAT_LEVEL" in
    minimal)    DEBLOAT_PKGS=("${DEBLOAT_PKGS_MINIMAL[@]}") ;;
    standard)   DEBLOAT_PKGS=("${DEBLOAT_PKGS_STANDARD[@]}") ;;
    aggressive) DEBLOAT_PKGS=("${DEBLOAT_PKGS_AGGRESSIVE[@]}") ;;
    *)          DEBLOAT_PKGS=("${DEBLOAT_PKGS_AGGRESSIVE[@]}") ;;
esac

# Filtrar solo paquetes instalados
INSTALLED_TO_REMOVE=()
for pkg in "${DEBLOAT_PKGS[@]}"; do
    if pacman -Q "$pkg" &>/dev/null; then
        INSTALLED_TO_REMOVE+=("$pkg")
    fi
done

if [[ ${#INSTALLED_TO_REMOVE[@]} -gt 0 ]]; then
    log_info "Removing ${#INSTALLED_TO_REMOVE[@]} packages: ${INSTALLED_TO_REMOVE[*]}"
    pacman_remove "${INSTALLED_TO_REMOVE[@]}"
else
    log_ok "No packages to remove for level: $DEBLOAT_LEVEL"
fi

# ─── Limpiar locales no usados ────────────────────────────────
log_step "Cleaning locales (keeping: ${REMOVE_LOCALES_KEEP[*]})"

# Backup locale.gen
cp /etc/locale.gen /etc/locale.gen.bak

# Comentar todo excepto los keep
for loc in "${REMOVE_LOCALES_KEEP[@]}"; do
    run_cmd "sed -i 's/^#\\(${loc}.*\\)/\\1/' /etc/locale.gen" "Enable locale: $loc"
done

# Comentar el resto
run_cmd "sed -i 's/^\\([^#].*\\)/#\\1/' /etc/locale.gen" "Disable other locales"

# Regenerar
run_cmd "locale-gen" "Regenerate locales"

# ─── Limpiar docs y man pages ──────────────────────────────────
if [[ "$REMOVE_DOCS" == true ]]; then
    log_step "Removing documentation files"
    run_cmd "rm -rf /usr/share/doc/* /usr/share/gtk-doc/* /usr/share/help/* 2>/dev/null || true" "Remove docs"
fi

if [[ "$REMOVE_MAN_PAGES" == true ]]; then
    log_step "Removing man pages"
    run_cmd "rm -rf /usr/share/man/* 2>/dev/null || true" "Remove man pages"
fi

# ─── Limpiar cachés ────────────────────────────────────────────
log_step "Cleaning caches"
run_cmd "pacman -Sc --noconfirm" "Clean pacman cache"
run_cmd "rm -rf /var/cache/pacman/pkg/* 2>/dev/null || true" "Remove all pkg cache"
run_cmd "rm -rf /home/*/.cache/* 2>/dev/null || true" "Remove user caches"
run_cmd "rm -rf /root/.cache/* 2>/dev/null || true" "Remove root cache"

# ─── Limpiar journal ───────────────────────────────────────────
run_cmd "journalctl --vacuum-time=7d" "Vacuum journal (keep 7 days)"

# ─── Orphan packages ───────────────────────────────────────────
log_step "Removing orphan packages"
ORPHANS=$(pacman -Qtdq 2>/dev/null || true)
if [[ -n "$ORPHANS" ]]; then
    pacman_remove $ORPHANS
else
    log_ok "No orphan packages"
fi

log_ok "Debloat module completed"
#!/usr/bin/env bash
# KalaOS Rofi Launcher - Omarchy-style combi with KalaOS commands
# Uso: rofi -show kalaos -modes "kalaos:~/.config/rofi/kalaos-launcher.sh"

# Modos disponibles
MODES="drun,run,window,ssh,calc,emoji,kalaos"

# Si se llama sin argumentos, mostrar ayuda
if [[ $# -eq 0 ]]; then
    echo -en "\0prompt\x1fKalaOS 🐱\n"
    echo -en "\0message\x1fApps · Settings · Calc · Emoji · Web\n"
    exit 0
fi

# Obtener selección del usuario
SELECTION="${@}"

# ─── Manejar modo kalaos (comandos internos) ──────────────────
if [[ "$ROFI_RETV" -eq 10 ]]; then
    # Usuario seleccionó un entry del modo kalaos
    case "$SELECTION" in
        "🎨 Theme: purple-red")       kala theme purple-red ;;
        "🎨 Theme: cyan")             kala theme cyan ;;
        "🎨 Theme: amber")            kala theme amber ;;
        "🖼️  Wallpaper: elegir...")    ghostty -e yazi ~/Pictures ;;
        "🎮 Gaming: ON")              kala gaming on ;;
        "🎮 Gaming: OFF")             kala gaming off ;;
        "🎮 Gamescope Session")       gamescope -W 1920 -H 1080 -r 144 -f -- steam ;;
        "⚙️  Kernel: BORE")            kala kernel cachyos-bore ;;
        "⚙️  Kernel: EEVDF")           kala kernel cachyos-eevdf ;;
        "⚙️  Kernel: Zen")             kala kernel linux-zen ;;
        "🧹 Debloat: minimal")        kala debloat minimal ;;
        "🧹 Debloat: standard")       kala debloat standard ;;
        "🧹 Debloat: aggressive")     kala debloat aggressive ;;
        "🩺 Doctor (health check)")    ghostty -e kala doctor ;;
        "📦 Update System")            ghostty -e kala update ;;
        "⚙️  Config: editar kalaos.conf") ghostty -e kala config edit ;;
        "⚙️  Config: ver actual")      ghostty -e kala config show ;;
        "💾 Backup configs")          ghostty -e kala backup ;;
        "🔄 Restore backup")          ghostty -e 'kala restore $(ls -d ~/kalaos-backup-* 2>/dev/null | fzf)' ;;
        "🐱 Logo KalaOS")             kala logo ;;
        "📋 Version")                 kala version ;;
        *) exit 1 ;;
    esac
    exit 0
fi

# ─── Generar entries para modo kalaos ─────────────────────────
if [[ "$ROFI_RETV" -eq 0 ]]; then
    # Primera carga: mostrar categorías
    echo -en "\0prompt\x1fKalaOS 🐱\n"
    echo -en "\0message\x1fApps · Settings · Calc · Emoji · Web\n"

    # Mostrar modo kalaos como una categoría más
    echo -en "\0use-hot-keys\x1ftrue\n"
    echo -en "\0markup-rows\x1ftrue\n"

    # Entries principales (modos estándar)
    echo "🔍 Buscar aplicaciones"
    echo "💻 Ejecutar comando"
    echo "🪟 Ventanas abiertas"
    echo "🔐 SSH"
    echo "🧮 Calculadora"
    echo "😀 Emojis"
    echo "🌐 Búsqueda web"
    echo "⚙️  KalaOS Settings"
    exit 0
fi

# ─── Si selecciona "KalaOS Settings", mostrar submenu ─────────
if [[ "$SELECTION" == "⚙️  KalaOS Settings" ]]; then
    echo -en "\0prompt\x1fKalaOS Settings\n"
    echo -en "\0message\x1fTheme · Gaming · Kernel · Debloat · System\n"
    echo -en "\0markup-rows\x1ftrue\n"
    echo -en "\0use-hot-keys\x1ftrue\n"

    # Theme
    echo "🎨 Theme: purple-red"
    echo "🎨 Theme: cyan"
    echo "🎨 Theme: amber"
    echo "🖼️  Wallpaper: elegir..."

    # Gaming
    echo "🎮 Gaming: ON"
    echo "🎮 Gaming: OFF"
    echo "🎮 Gamescope Session"

    # Kernel
    echo "⚙️  Kernel: BORE"
    echo "⚙️  Kernel: EEVDF"
    echo "⚙️  Kernel: Zen"

    # Debloat
    echo "🧹 Debloat: minimal"
    echo "🧹 Debloat: standard"
    echo "🧹 Debloat: aggressive"

    # System
    echo "🩺 Doctor (health check)"
    echo "📦 Update System"
    echo "⚙️  Config: editar kalaos.conf"
    echo "⚙️  Config: ver actual"
    echo "💾 Backup configs"
    echo "🔄 Restore backup"
    echo "🐱 Logo KalaOS"
    echo "📋 Version"
    exit 0
fi

# ─── Para otros modos (drun, run, window, ssh, calc, emoji) ───
# rofi los maneja nativamente, solo pasamos la selección
echo "$SELECTION"
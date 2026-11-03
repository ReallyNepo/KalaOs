#!/usr/bin/env bash
# Module: 05-shell - Ghostty (IDE-like syntax highlighting), fish, starship, atuin

log_step "Installing terminal stack: Ghostty + fish + starship + atuin"

SHELL_PKGS=(
    ghostty
    fish
    starship
    atuin
    zoxide
    fzf
    fd
    ripgrep
    bat
    eza
    direnv
    mise                    # runtime version manager (asdf replacement)
)

AUR_SHELL_PKGS=(
    git-delta               # modern git diff (AUR)
    carapace-bin            # completions engine (AUR)
    fisher                  # fish plugin manager (AUR)
)

pacman_install "${SHELL_PKGS[@]}"
aur_install "${AUR_SHELL_PKGS[@]}"

# ─── Ghostty config con syntax highlighting IDE-like ───────────
log_step "Configuring Ghostty with IDE-like syntax highlighting"

run_cmd "mkdir -p \$HOME/.config/ghostty" "Ghostty config dir"

# Ensure dotfiles dir exists (for stow)
DOTFILES_DIR="${SCRIPT_DIR:-$HOME/kalaos}/dotfiles"
run_cmd "mkdir -p $DOTFILES_DIR/ghostty" "Ghostty dotfiles dir"

# El tema custom kalaos-purple-red se genera en 07-theming.sh
# Aquí creamos la base con soporte para syntax highlighting
cat > $DOTFILES_DIR/ghostty/config <<'GHOSTTY_EOF'
# KalaOS Ghostty Config - IDE-like syntax highlighting
# Tema se carga desde: ~/.config/ghostty/themes/kalaos-purple-red.conf

# Font
font-family = "JetBrains Mono Nerd Font"
font-size = 11
font-weight = 400
font-weight-bold = 600
font-feature = +liga +calt +clig

# Shell
shell-integration = detect
shell-integration-features = cursor,title,prompt

# Window
window-width = 120
window-height = 40
window-padding-x = 12
window-padding-y = 10
window-decorations = buttonless
window-title = "KalaOS 🐱"
background-opacity = 0.95
background-blur-radius = 15

# Cursor
cursor-style = block
cursor-style-blink = on
cursor-blink-interval = 530

# Scrollback
scrollback-lines = 10000
mouse-hide-while-typing = true

# Tabs
tab-bar-style = tabs
tab-new-position = after-current
tab-switch-animated = true

# Keybindings (Omarchy-style)
keybind = ctrl+shift+t=new_tab
keybind = ctrl+shift+w=close_tab
keybind = ctrl+shift+q=close_surface
keybind = ctrl+shift+n=new_window
keybind = ctrl+shift+p=split_vertical
keybind = ctrl+shift+o=split_horizontal
keybind = super+1=goto_tab:1
keybind = super+2=goto_tab:2
keybind = super+3=goto_tab:3
keybind = super+4=goto_tab:4
keybind = super+5=goto_tab:5
keybind = super+6=goto_tab:6
keybind = super+7=goto_tab:7
keybind = super+8=goto_tab:8
keybind = super+9=goto_tab:9
keybind = ctrl+shift+c=copy
keybind = ctrl+shift+v=paste
keybind = ctrl+shift+f=find
keybind = ctrl+plus=increase_font_size
keybind = ctrl+minus=decrease_font_size
keybind = ctrl+0=reset_font_size

# Clipboard
clipboard-read = clipboard
clipboard-write = clipboard

# Colorscheme (loaded from theme file)
include ~/.config/ghostty/themes/kalaos-purple-red.conf
GHOSTTY_EOF

# ─── Fish config con autocomplete/corrección ───────────────────
log_step "Configuring fish with autocomplete & correction"

run_cmd "mkdir -p \$HOME/.config/fish/{functions,completions,conf.d}" "Fish config dirs"

run_cmd "mkdir -p $DOTFILES_DIR/fish" "Fish dotfiles dir"

cat > $DOTFILES_DIR/fish/config.fish <<'FISH_EOF'
# KalaOS Fish Config - Autocomplete, correction, IDE-like experience

# ─── Default terminal ───────────────────────────────────────────
set -gx TERMINAL ghostty
set -gx TERM xterm-256color

# ─── Starship prompt ──────────────────────────────────────────
starship init fish | source

# ─── Atuin history ────────────────────────────────────────────
atuin init fish | source

# ─── Zoxide ───────────────────────────────────────────────────
zoxide init fish | source

# ─── Carapace completions ─────────────────────────────────────
carapace _carapace fish | source

# ─── Mise (runtime versions) ──────────────────────────────────
mise activate fish | source

# ─── Direnv ───────────────────────────────────────────────────
direnv hook fish | source

# ─── Aliases útiles ───────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias cat='bat --style=plain --paging=never'
alias grep='rg --color=auto'
alias find='fd'
alias vim='nvim'
alias vi='nvim'
alias k='kala'
alias kala='kala'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate -20'

# Sistema
alias update='kala update'
alias theme='kala theme'
alias wallpaper='kala wallpaper'

# ─── Opciones fish ────────────────────────────────────────────
set -g fish_greeting ""
set -g fish_autosuggestion_enabled true
set -g fish_key_bindings fish_default_key_bindings

# Autosuggestion style (morado sutil)
set -g fish_color_autosuggestion "#7C3AED80"

# ─── Corrección automática (fish built-in) ────────────────────
# fish sugiere correcciones automáticamente con tab

# ─── Abbreviations (expansión automática) ─────────────────────
abbr -g --add gco 'git checkout'
abbr -g --add gcb 'git checkout -b'
abbr -g --add gcm 'git commit -m'
abbr -g --add gpu 'git push'
abbr -g --add gpl 'git pull'
abbr -g --add dcu 'docker compose up -d'
abbr -g --add dcd 'docker compose down'
abbr -g --add dcl 'docker compose logs -f'

# ─── Compleciones extra ───────────────────────────────────────
# kubectl, docker, etc. via carapace

# ─── Funciones útiles ─────────────────────────────────────────
function mkcd
    mkdir -p $argv[1]
    cd $argv[1]
end

function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'; tar xjf $argv[1]
            case '*.tar.gz'; tar xzf $argv[1]
            case '*.bz2'; bunzip2 $argv[1]
            case '*.rar'; unrar x $argv[1]
            case '*.gz'; gunzip $argv[1]
            case '*.tar'; tar xf $argv[1]
            case '*.tbz2'; tar xjf $argv[1]
            case '*.tgz'; tar xzf $argv[1]
            case '*.zip'; unzip $argv[1]
            case '*.Z'; uncompress $argv[1]
            case '*.7z'; 7z x $argv[1]
            case '*'; echo "'$argv[1]' cannot be extracted via extract()"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end
FISH_EOF

# ─── Fisher plugins ────────────────────────────────────────────
cat > $DOTFILES_DIR/fish/fish_plugins <<'FISH_PLUGINS_EOF'
# Fisher plugins for KalaOS
jorgebucaran/fisher
jorgebucaran/autopair.fish        # Auto-close brackets/quotes
patrickf1/fzf.fish                # fzf integration
franciscolourenco/done            # Notifications for long commands
jorgebucaran/nvm.fish             # Node version manager (if needed)
FISH_PLUGINS_EOF

# ─── Starship config (tema morado/rojo) ────────────────────────
log_step "Configuring Starship prompt"

run_cmd "mkdir -p $DOTFILES_DIR/starship" "Starship dotfiles dir"

cat > $DOTFILES_DIR/starship/starship.toml <<'STARSHIP_EOF'
# KalaOS Starship Config - Purple/Red theme
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$git_commit\
$rust\
$golang\
$nodejs\
$python\
$docker_context\
$package\
$cmd_duration\
$line_break\
$character"""

[character]
success_symbol = "[🐱](bold purple)"
error_symbol = "[😿](bold red)"
vicmd_symbol = "[⌘](bold purple)"

[username]
show_always = true
format = "[$user](bold purple) "
disabled = false

[hostname]
ssh_only = false
format = "@[$hostname](bold red) "
disabled = false

[directory]
truncation_length = 3
truncation_symbol = "…/"
format = "[$path](bold purple)[$read_only](bold red) "

[git_branch]
symbol = "🌱 "
format = "[$symbol$branch](bold purple) "

[git_status]
format = "([$all_status](bold red)) "
conflicted = "⚔️ "
ahead = "⬆️ "
behind = "⬇️ "
diverged = "↕️ "
untracked = "🆕 "
stashed = "📦 "
modified = "📝 "
deleted = "🗑️ "
renamed = "📛 "

[cmd_duration]
min_time = 2000
format = "[$duration](bold yellow) "
disabled = false

[rust]
symbol = "🦀 "
format = "via [$symbol$version](bold red) "

[golang]
symbol = "🐹 "
format = "via [$symbol$version](bold purple) "

[nodejs]
symbol = "📦 "
format = "via [$symbol$version](bold green) "

[python]
symbol = "🐍 "
format = "via [$symbol$version](bold yellow) "

[docker_context]
symbol = "🐳 "
format = "[$symbol$context](bold blue) "

[package]
symbol = "📦 "
format = "[$symbol$version](bold cyan) "
disabled = false
STARSHIP_EOF

# ─── Atuin config ──────────────────────────────────────────────
run_cmd "mkdir -p $DOTFILES_DIR/fish/conf.d" "Fish conf.d dotfiles dir"

cat > $DOTFILES_DIR/fish/conf.d/atuin.fish <<'ATUIN_EOF'
# Atuin config
set -g ATUIN_SEARCH_MODE fzf
set -g ATUIN_STYLE compact
ATUIN_EOF

# ─── Cambiar shell por defecto ────────────────────────────────
run_cmd "chsh -s /usr/bin/fish $SUDO_USER 2>/dev/null || chsh -s /usr/bin/fish" "Set fish as default shell"

log_ok "Shell module completed"
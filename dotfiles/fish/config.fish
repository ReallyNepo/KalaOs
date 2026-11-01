# KalaOS Fish Config - Autocomplete, correction, IDE-like experience

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

# ─── Abbreviations (expansión automática) ─────────────────────
abbr -g --add gco 'git checkout'
abbr -g --add gcb 'git checkout -b'
abbr -g --add gcm 'git commit -m'
abbr -g --add gpu 'git push'
abbr -g --add gpl 'git pull'
abbr -g --add dcu 'docker compose up -d'
abbr -g --add dcd 'docker compose down'
abbr -g --add dcl 'docker compose logs -f'

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
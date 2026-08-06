# =============================================================================
# lens — config.fish
# =============================================================================

# --- no greeting ---
set -g fish_greeting ""

# --- env vars ---
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx TERMINAL kitty
set -gx BROWSER ""

# qt/gtk theming
set -gx QT_QPA_PLATFORMTHEME qt5ct
set -gx GTK_THEME Adwaita:dark

# --- path ---
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin

# --- starship prompt ---
if command -q starship
    starship init fish | source
end

# --- aliases ---
# files
alias ls="eza --icons --group-directories-first" 2>/dev/null; or alias ls="ls --color=auto"
alias ll="eza -la --icons --group-directories-first" 2>/dev/null; or alias ll="ls -la --color=auto"
alias la="eza -a --icons --group-directories-first" 2>/dev/null; or alias la="ls -a --color=auto"
alias tree="eza --tree --icons" 2>/dev/null; or alias tree="tree"

# cat with syntax highlight
alias cat="bat --style=plain" 2>/dev/null; or alias cat="cat"

# grep
alias grep="rg" 2>/dev/null; or alias grep="grep --color=auto"

# navigation
if command -q zoxide
    zoxide init fish | source
end

# git shortcuts
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline -15"
alias gd="git diff"

# system
alias update="yay -Syu"
alias cleanup="yay -Rns (yay -Qdtq)" # remove orphans
alias pkgs="yay -Q | wc -l" # count installed packages

# hyprland
alias hyprconf="$EDITOR ~/.config/hypr/hyprland.conf"
alias hyprkeys="$EDITOR ~/.config/hypr/keybinds.conf"
alias wayconf="$EDITOR ~/.config/waybar/config.jsonc"
alias waystyle="$EDITOR ~/.config/waybar/style.css"

# quick reload
alias wayreload="killall waybar; waybar &; disown"

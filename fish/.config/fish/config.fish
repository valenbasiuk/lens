# =============================================================================
# lens - config.fish
# =============================================================================

# --- no greeting ---
set -g fish_greeting ""

# --- env vars ---
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx TERMINAL kitty
# set -gx BROWSER firefox  # uncomment and set your browser here

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

# --- zoxide (smarter cd) ---
if command -q zoxide
    zoxide init fish | source
end

# --- aliases: files ---
if command -q eza
    alias ls "eza --icons --group-directories-first"
    alias ll "eza -la --icons --group-directories-first"
    alias la "eza -a --icons --group-directories-first"
    alias tree "eza --tree --icons"
else
    alias ls "ls --color=auto"
    alias ll "ls -la --color=auto"
    alias la "ls -a --color=auto"
end

# --- aliases: cat ---
if command -q bat
    alias cat "bat --style=plain"
end

# --- aliases: grep ---
if command -q rg
    alias grep "rg"
else
    alias grep "grep --color=auto"
end

# --- aliases: git ---
alias gs "git status"
alias ga "git add"
alias gc "git commit"
alias gp "git push"
alias gl "git log --oneline -15"
alias gd "git diff"

# --- aliases: system ---
alias update "yay -Syu"
alias cleanup "yay -Rns (yay -Qdtq)"
alias pkgs "yay -Q | wc -l"

# --- aliases: hyprland quick-edit ---
alias hyprconf "$EDITOR ~/.config/hypr/hyprland.conf"
alias hyprkeys "$EDITOR ~/.config/hypr/keybinds.conf"
alias wayconf "$EDITOR ~/.config/waybar/config.jsonc"
alias waystyle "$EDITOR ~/.config/waybar/style.css"
alias wayreload "killall waybar; waybar &; disown"

# --- settings panel from terminal ---
alias settings "bash ~/.config/hypr/scripts/lensctl"

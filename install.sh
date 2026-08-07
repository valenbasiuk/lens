#!/bin/bash

# =============================================================================
# lens installer
# dotfiles para arch linux + hyprland
# frutiger aero aesthetic
# =============================================================================

set -e

# --- colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# --- repo directory (where install.sh lives) ---
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- helpers ---
info() {
    echo -e "${CYAN}[*]${NC} $1"
}

success() {
    echo -e "${GREEN}[+]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[x]${NC} $1"
    exit 1
}

ask() {
    local prompt="$1"
    local reply
    read -rp "$(echo -e "${CYAN}[?]${NC} ${prompt} [y/N] ")" reply
    [[ "$reply" =~ ^[yY]$ ]]
}

# --- banner ---
banner() {
    echo ""
    echo -e "${CYAN}"
    echo "  ██╗     ███████╗███╗   ██╗███████╗"
    echo "  ██║     ██╔════╝████╗  ██║██╔════╝"
    echo "  ██║     █████╗  ██╔██╗ ██║███████╗"
    echo "  ██║     ██╔══╝  ██║╚██╗██║╚════██║"
    echo "  ███████╗███████╗██║ ╚████║███████║"
    echo "  ╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝"
    echo -e "${NC}"
    echo -e "  ${BOLD}dotfiles para arch linux + hyprland${NC}"
    echo -e "  frutiger aero aesthetic"
    echo ""
}

# =============================================================================
# YAY
# =============================================================================

ensure_yay() {
    if command -v yay &>/dev/null; then
        success "YAY already installed."
        return
    fi

    info "installing YAY..."
    sudo pacman -S --needed --noconfirm git base-devel
    local tmpdir
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    success "YAY installed."
}

# =============================================================================
# CORE PACKAGES
# =============================================================================

install_core() {
    info "installing core packages..."

    local core_packages=(
        # HYPRLAND ecosystem
        hyprland
        hyprpaper
        hypridle
        hyprlock
        hyprpicker
        xdg-desktop-portal-hyprland

        # bar + launcher + notifications
        waybar
        rofi-wayland
        swaync

        # terminal + shell
        kitty
        fish
        starship

        # file managers
        thunar
        thunar-archive-plugin
        thunar-volman
        tumbler
        yazi

        # screenshots
        grim
        slurp
        swappy

        # fetch
        fastfetch

        # theming GTK/QT
        nwg-look
        qt5ct
        qt6ct

        # fonts
        ttf-jetbrains-mono-nerd
        inter-font
        noto-fonts
        noto-fonts-emoji

        # clipboard + input utilities
        cliphist
        wl-clipboard
        brightnessctl
        pamixer
        polkit-gnome

        # stow for dotfiles deploy
        stow
    )

    yay -S --needed --noconfirm "${core_packages[@]}"
    success "core packages installed."
}

# =============================================================================
# SYSTEM DEPENDENCIES
# =============================================================================

install_invisible() {
    info "installing system dependencies..."

    local invisible_packages=(
        # audio
        pipewire
        pipewire-pulse
        pipewire-alsa
        wireplumber
        playerctl
        pavucontrol

        # network
        networkmanager

        # bluetooth base
        bluez
        bluez-utils

        # credentials - git tokens, wifi passwords
        gnome-keyring

        # waybar scripts and hyprland IPC
        jq
        socat

        # multimedia backend
        ffmpeg
        imagemagick

        # xdg - open files with correct app, create ~/Documents etc
        xdg-utils
        xdg-user-dirs

        # archives - thunar needs these
        unzip
        p7zip

        # GTK layer for waybar
        gtk-layer-shell

        # notifications from scripts
        libnotify

        # python - dependency for nwg-look and GTK tools
        python-gobject
    )

    yay -S --needed --noconfirm "${invisible_packages[@]}"

    # enable essential services
    info "enabling services..."
    sudo systemctl enable --now NetworkManager.service 2>/dev/null || true
    systemctl --user enable --now pipewire.service 2>/dev/null || true
    systemctl --user enable --now pipewire-pulse.service 2>/dev/null || true
    systemctl --user enable --now wireplumber.service 2>/dev/null || true

    success "dependencies installation done"
}

# =============================================================================
# OPTIONAL MODULES
# =============================================================================

# --- module: virtualization ---
mod_virtualization() {
    info "installing QEMU, KVM, VIRT-MANAGER..."
    yay -S --needed --noconfirm \
        qemu-full \
        virt-manager \
        libvirt \
        dnsmasq \
        virt-viewer \
        edk2-ovmf

    sudo systemctl enable --now libvirtd.service
    sudo usermod -aG libvirt "$USER"
    warn "you need to re-login for the libvirt group to take effect."
    success "virtualization setup installation finished."
}

# --- module: gaming ---
mod_gaming() {
    info "installing STEAM, LUTRIS, WINE, GAMEMODE, MANGOHUD..."

    if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
        warn "multilib is not enabled in /etc/pacman.conf"
        warn "lib32-* libraries will not be installed without multilib."
        warn "enable multilib manually and run the installer again."
    fi

    yay -S --needed --noconfirm \
        steam \
        lutris \
        gamemode \
        lib32-gamemode \
        mangohud \
        lib32-mangohud \
        wine-staging

    success "gaming setup installation finished"
}

# --- module: speedrunning ---
mod_speedrunning() {
    info "installing WAYWALL build deps, PRISMLAUNCHER, JAVA runtimes..."
    yay -S --needed --noconfirm \
        base-devel \
        cmake \
        wayland-protocols \
        libxkbcommon \
        prismlauncher \
        jre17-openjdk \
        jre8-openjdk

    success "speedrunning setup installation finished."
}

# --- module: streaming ---
mod_streaming() {
    info "installing OBS with browser source..."
    yay -S --needed --noconfirm \
        obs-studio-browser \
        v4l2loopback-dkms

    success "streaming setup installation finished."
}

# --- module: dev tools ---
mod_devtools() {
    info "installing DOCKER, RUST, GITHUB CLI, LAZYGIT..."
    yay -S --needed --noconfirm \
        docker \
        docker-compose \
        base-devel \
        rustup \
        git-lfs \
        github-cli \
        neovim \
        lazygit \
        tokei

    sudo systemctl enable --now docker.service
    sudo usermod -aG docker "$USER"
    rustup default stable 2>/dev/null || true
    warn "you need to re-login for the docker group to take effect."
    success "dev tools installation finished."
}

# --- module: audio TUI ---
mod_audio() {
    info "installing CMUS, CAVA, MPD, NCMPCPP..."
    yay -S --needed --noconfirm \
        cmus \
        cava \
        mpd \
        ncmpcpp

    success "audio TUI setup installation finished."
}

# --- module: bluetooth and network GUI ---
mod_btnet() {
    info "installing BLUEMAN, NM-APPLET..."
    yay -S --needed --noconfirm \
        blueman \
        network-manager-applet

    sudo systemctl enable --now bluetooth.service
    success "bluetooth and network GUI installation finished."
}

# --- module: theming extra ---
mod_theming() {
    info "installing PAPIRUS icons, BIBATA cursors, SWWW..."
    yay -S --needed --noconfirm \
        papirus-icon-theme \
        bibata-cursor-theme-bin \
        swww

    success "theming extras installation finished."
}

# --- modules menu ---
modules_menu() {
    echo ""
    echo -e "${BOLD}==========================================${NC}"
    echo -e "${BOLD}  optional modules${NC}"
    echo -e "${BOLD}==========================================${NC}"
    echo ""
    echo "  [1]  virtualization setup (QEMU, KVM, VIRT-MANAGER)"
    echo "  [2]  overall gaming (STEAM, LUTRIS, WINE, GAMEMODE)"
    echo "  [3]  speedrunning (WAYWALL, PRISMLAUNCHER)"
    echo "  [4]  streaming / recording (OBS)"
    echo "  [5]  dev tools (DOCKER, RUST, GITHUB CLI)"
    echo "  [6]  TUI audio setup (CMUS, CAVA, MPD)"
    echo "  [7]  bluetooth and network GUI (BLUEMAN, NM-APPLET)"
    echo "  [8]  theming extras (PAPIRUS, BIBATA, SWWW)"
    echo ""
    echo -e "  select modules to install (e.g. ${CYAN}1 2 5${NC})"
    echo -e "  or press ENTER to skip all."
    echo ""

    local choices
    read -rp "$(echo -e "${CYAN}[?]${NC} modules: ")" choices

    if [[ -z "$choices" ]]; then
        info "no modules selected, skipping."
        return
    fi

    for choice in $choices; do
        case $choice in
            1) mod_virtualization ;;
            2) mod_gaming ;;
            3) mod_speedrunning ;;
            4) mod_streaming ;;
            5) mod_devtools ;;
            6) mod_audio ;;
            7) mod_btnet ;;
            8) mod_theming ;;
            *) warn "option '$choice' not valid, skipping." ;;
        esac
    done
}

# =============================================================================
# STOW DEPLOY
# =============================================================================

deploy_dotfiles() {
    info "symlinking dotfiles with STOW..."

    local packages=(hypr waybar fish kitty rofi starship fastfetch swaync yazi)

    for pkg in "${packages[@]}"; do
        if [[ -d "$REPO_DIR/$pkg" ]]; then
            # backup existing real dirs/files (not symlinks) before stowing
            local config_target
            config_target=$(find "$REPO_DIR/$pkg/.config" -mindepth 1 -maxdepth 1 2>/dev/null | head -1)
            if [[ -n "$config_target" ]]; then
                local target_name
                target_name=$(basename "$config_target")
                local target_path="$HOME/.config/$target_name"
                if [[ -e "$target_path" && ! -L "$target_path" ]]; then
                    warn "$target_path exists, backing up to ${target_path}.bak"
                    mv "$target_path" "${target_path}.bak"
                fi
            fi

            stow -v -R -t "$HOME" -d "$REPO_DIR" "$pkg" 2>&1 | while read -r line; do
                echo "    $line"
            done
            success "$pkg linked."
        else
            warn "$pkg: not found in repo, skipping."
        fi
    done

    success "dotfiles deployed."
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    banner

    info "this will install and configure your entire environment"
    info "make sure you are running this from the repo directory"
    echo ""

    if ! ask "continue?"; then
        warn "cancelled"
        exit 0
    fi

    echo ""

    ensure_yay
    install_core
    install_invisible
    modules_menu
    deploy_dotfiles

    success "everything ready. restart your session to apply the changes."
}

main "$@"

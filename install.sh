#!/bin/bash

# =============================================================================
# lens installer
# dotfiles para arch linux + hyprland
# estetica frutiger aero
# =============================================================================

set -e

# --- colores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# --- directorio del repo (donde esta install.sh) ---
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
    # ask "mensaje" -> devuelve 0 si el usuario dice y, 1 si no
    local prompt="$1"
    local reply
    read -rp "$(echo -e "${CYAN}[?]${NC} ${prompt} [y/N] ")" reply
    [[ "$reply" =~ ^[yY]$ ]]
}

# --- banner ---
banner() {
    echo ""
    echo -e "${CYAN}"
    echo "      ___       ___           ___           ___     "
    echo "     /\__\     /\  \         /\__\         /\  \    "
    echo "    /:/  /    /::\  \       /::|  |       /::\  \   "
    echo "   /:/  /    /:/\:\  \     /:|:|  |      /:/\ \  \  "
    echo "  /:/  /    /::\~\:\  \   /:/|:|  |__   _\:\~\ \  \ "
    echo " /:/__/    /:/\:\ \:\__\ /:/ |:| /\__\ /\ \:\ \ \__\"
    echo " \:\  \    \:\~\:\ \/__/ \/__|:|/:/  / \:\ \:\ \/__/"
    echo "  \:\  \    \:\ \:\__\       |:/:/  /   \:\ \:\__\  "
    echo "   \:\  \    \:\ \/__/       |::/  /     \:\/:/  /  "
    echo "    \:\__\    \:\__\         /:/  /       \::/  /   "
    echo "     \/__/     \/__/         \/__/         \/__/    "

    echo -e "${NC}"
    echo -e "  ${BOLD}dotfiles for arch linux + hyprland${NC}"
    echo -e "   w frutiger aero aesthetic"
    echo ""
}

# --- yay ---
ensure_yay() {
    if command -v yay &>/dev/null; then
        success "yay is already installed."
        return
    fi

    info "installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    local tmpdir
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    success "yay installed."
}

# --- core packages ---
install_core() {
    info "installing core packages..."

    local core_packages=(
        # compositor + ecosystem HYPRLAND
        hyprland
        hyprpaper
        hypridle
        hyprlock
        hyprpicker
        xdg-desktop-portal-hyprland

        # barra + launcher + notificaciones
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

        # fuentes
        ttf-jetbrains-mono-nerd
        inter-font
        noto-fonts
        noto-fonts-emoji

        # clipboard + utilidades de input
        cliphist
        wl-clipboard
        brightnessctl
        pamixer
        polkit-gnome

        # stow para deploy de dotfiles
        stow
    )

    yay -S --needed --noconfirm "${core_packages[@]}"
    success "paquetes core instalados."
}

# --- dependencias invisibles ---
install_invisible() {
    info "instalando dependencias del sistema..."

    local invisible_packages=(
        # audio
        pipewire
        pipewire-pulse
        pipewire-alsa
        wireplumber
        playerctl          # play/pause/next desde keybinds
        pavucontrol         # GUI mixer de audio

        # red
        networkmanager

        # bluetooth base
        bluez
        bluez-utils

        # credenciales — guarda tokens de git, passwords de wifi
        gnome-keyring

        # herramientas para scripts de waybar e hyprland IPC
        jq                  # parseo JSON
        socat               # comunicacion con hyprland socket

        # multimedia backend
        ffmpeg
        imagemagick

        # xdg — abrir archivos con la app correcta, crear ~/Documents etc.
        xdg-utils
        xdg-user-dirs

        # archivos comprimidos — thunar los necesita
        unzip
        p7zip

        # GTK layer para waybar
        gtk-layer-shell

        # notificaciones desde scripts
        libnotify

        # python — dependencia de nwg-look y otras tools GTK
        python-gobject
    )

    yay -S --needed --noconfirm "${invisible_packages[@]}"

    # habilitar servicios esenciales
    info "habilitando servicios..."
    sudo systemctl enable --now NetworkManager.service 2>/dev/null || true
    systemctl --user enable --now pipewire.service 2>/dev/null || true
    systemctl --user enable --now pipewire-pulse.service 2>/dev/null || true
    systemctl --user enable --now wireplumber.service 2>/dev/null || true

    success "dependencies installation done"
}

# =============================================================================
# MODULOS OPCIONALES
# =============================================================================

# --- modulo: virtualizacion ---
mod_virtualization() {
    info "instalando QEMU, KVM, VIRT-MANAGER..."
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

# --- modulo: gaming ---
mod_gaming() {
    info "instalando STEAM, LUTRIS, WINE, GAMEMODE, MANGOHUD..."

    # verificar que multilib esta habilitado en pacman.conf
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        warn "multilib isn't enabled in /etc/pacman.conf"
        warn "lib32-* libraries won't be installed without multilib."
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

# --- modulo: speedrunning ---
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

# --- modulo: streaming ---
mod_streaming() {
    info "installing OBS with browser source..."
    yay -S --needed --noconfirm \
        obs-studio-browser \
        v4l2loopback-dkms

    success "streaming setup installation finished."
}

# --- modulo: dev tools ---
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

# --- module: bluetooth y network GUI ---
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

# --- menu de modulos ---
modules_menu() {
    echo ""
    echo -e "${BOLD}==========================================${NC}"
    echo -e "${BOLD}  optional modules${NC}"
    echo -e "${BOLD}==========================================${NC}"
    echo ""
    echo "  [1]  virtualization setup (QEMU, KVM, VIRT-MANAGER)"
    echo "  [2]  overall gaming (STEAM, LUTRIS, WINE, GAMEMODE)"
    echo "  [3]  speedrunning specifications (WAYWALL, PRISMLAUNCHER)"
    echo "  [4]  streaming / recording (OBS)"
    echo "  [5]  dev tools (DOCKER, RUST, GITHUB CLI)"
    echo "  [6]  TUI audio setup (CMUS, CAVA, MPD)"
    echo "  [7]  bluetooth and network GUI (BLUEMAN, NM-APPLET)"
    echo "  [8]  theming extras (PAPIRUS, BIBATA, SWWW)"
    echo ""
    echo -e "  select the modules you want to install (ej: ${CYAN}1 2 5${NC})"
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

# --- main ---
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
    # TODO: deploy con STOW

    success "everything ready. restart your session to apply the changes."
}

main "$@"

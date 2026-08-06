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
    echo "  ██╗     ███████╗███╗   ██╗███████╗"
    echo "  ██║     ██╔════╝████╗  ██║██╔════╝"
    echo "  ██║     █████╗  ██╔██╗ ██║███████╗"
    echo "  ██║     ██╔══╝  ██║╚██╗██║╚════██║"
    echo "  ███████╗███████╗██║ ╚████║███████║"
    echo "  ╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝"
    echo -e "${NC}"
    echo -e "  ${BOLD}dotfiles para arch linux + hyprland${NC}"
    echo -e "  estetica frutiger aero"
    echo ""
}

# --- yay ---
ensure_yay() {
    if command -v yay &>/dev/null; then
        success "YAY ya esta instalado."
        return
    fi

    info "instalando YAY..."
    sudo pacman -S --needed --noconfirm git base-devel
    local tmpdir
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
    success "YAY instalado."
}

# --- core packages ---
install_core() {
    info "instalando paquetes core..."

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

    success "dependencias del sistema instaladas."
}

# --- main ---
main() {
    banner

    info "esto va a instalar y configurar tu entorno completo."
    info "asegurate de estar corriendo esto desde el directorio del repo."
    echo ""

    if ! ask "continuar?"; then
        warn "cancelado."
        exit 0
    fi

    echo ""

    ensure_yay
    install_core
    install_invisible
    # TODO: menu de modulos opcionales
    # TODO: deploy con STOW

    success "todo listo. reinicia la sesion para aplicar los cambios."
}

main "$@"

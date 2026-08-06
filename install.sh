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

    # TODO: check/install YAY
    # TODO: instalar paquetes core
    # TODO: instalar dependencias invisibles
    # TODO: menu de modulos opcionales
    # TODO: deploy con STOW

    success "todo listo. reinicia la sesion para aplicar los cambios."
}

main "$@"

# lens

dotfiles personales para arch linux + hyprland.

estetica frutiger aero — glassmorphism, gradientes teal/cyan, glossy highlights.

## dependencias

- arch linux
- yay (AUR helper)
- GNU stow

## instalacion

```bash
git clone https://github.com/valenbasiuk/lens.git
cd lens
chmod +x install.sh
./install.sh
```

## estructura

cada carpeta es un "paquete" de stow. cuando corres `stow hypr`, el contenido de `hypr/.config/hypr/` se symlinea a `~/.config/hypr/`.

```
lens/
├── hypr/          # hyprland config
├── waybar/        # barra de estado
├── fish/          # shell
├── kitty/         # terminal
├── rofi/          # launcher
├── swaync/        # notificaciones
├── starship/      # prompt
├── fastfetch/     # system fetch
├── yazi/          # file manager TUI
├── install.sh     # instalador
└── README.md
```

## hardware target

- GPU: NVIDIA RTX 3060 Ti
- shell: fish
- dual boot con windows (SSD separado)

## creditos

hecho a mano, paso a paso, como proyecto de aprendizaje.

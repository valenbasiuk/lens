# Plan de accion - proyecto lens (valenbasiuk/lens)

## Contexto

`lens` es mi repo de dotfiles personales para Hyprland en Arch Linux, estetica Frutiger Aero, manejado con GNU Stow (`hypr/`, `waybar/`, `fish/`, `kitty/`, `rofi/`, `starship/`, `swaync/`, `fastfetch/`, `yazi/`, cada uno un paquete de stow con estructura `paquete/.config/paquete/...`).

Ya lo instale en mi maquina real (Arch + Hyprland 0.55, NVIDIA RTX 3060 Ti, disco 1TB como main). El resultado "andaba" pero con bugs y una estetica demasiado plana/mid para lo que Frutiger Aero deberia ser. Ya diagnostique las causas raiz de los bugs con ayuda de otra sesion de Claude (Sonnet 5) - estan detalladas abajo con fix concreto. Tu trabajo es aplicar los fixes de la Fase 1 primero, y despues iterar sobre la Fase 2 (estetica) conmigo, mostrandome los cambios antes de que yo los pruebe en mi maquina real (no tenes acceso a mi hardware, asi que no podes verificar visualmente - pedime feedback/screenshots despues de cada cambio grande).

**Importante:** quiero seguir entendiendo lo que se cambia y por que, no solo que me tires diffs sin contexto. Explicame brevemente el razonamiento de cada fix antes de aplicarlo.

---

## FASE 1 - Bugs criticos (bloquean uso normal, arrancar por aca)

### 1. Waybar no renderiza nada (causa raiz confirmada)

En `waybar/.config/waybar/style.css` linea 7 hay:
```css
@import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap");
```
GTK-CSS no maneja bien `@import` remoto por HTTP - rompe el parseo completo del stylesheet y waybar no dibuja nada. La fuente Inter ya esta instalada localmente via paquete (`inter-font`), asi que el `@import` no hace falta.

**Fix:** borrar esa linea completa.

### 2. Errores de config de Hyprland al iniciar

Instale sobre Hyprland 0.55, que tuvo breaking changes:

- **`dwindle:pseudotile does not exist`** - removida en 0.55. Borrar `pseudotile = true` del bloque `dwindle { }`.
- **`misc:vfr does not exist`** - se movio a `debug:`. Sacar `vfr = true` del bloque `misc { }`.
- **`windowrulev2 is deprecated`** (~37 veces) - Find & replace `windowrulev2` -> `windowrule`.

### 3. Editor de keybinds falla (`Failed to launch child: nvim`)

neovim nunca se instala en core_packages. Agregarlo.

### 4. Wifi y Bluetooth no abren desde lensctl

`nm-connection-editor` y `blueman-manager` no estan en core_packages. Moverlos ahi.

### 5. Monitor principal mal detectado (165Hz vs 60Hz)

La linea wildcard `monitor = , preferred, auto, 1` no asigna bien. Necesito output de `hyprctl monitors` para poner lineas explicitas.

### 6. Reemplazar Thunar por Dolphin

Cambios en: install.sh, keybinds.conf, hyprland.conf (window rules), lensctl.

---

## FASE 2 - Overhaul estetico

### 2.1 - Paleta: sumar verde, no solo azul/teal
Verde-lima/esmeralda como paleta secundaria. Frutiger Aero clasico usa MUCHO verde combinado con azul.

### 2.2 - Waybar: mucho mas rico, base en end-4 (sin quickshell)
- Pills separados en vez de barra continua
- Gradientes de 4 paradas (blanco -> azul claro -> azul cristal -> azul oscuro)
- box-shadow inset para efecto relieve
- Iconos mas grandes/vistosos
- Hover con mas glow
- Modulos custom extra (CPU/RAM)

### 2.3 - Rofi: estilizar mucho mas fuerte
- Gradiente de fondo mas marcado
- Iconos de apps mas grandes
- Highlight con gradiente animado azul->verde
- Bordes con mas definicion de "vidrio"

### 2.4 - Bordes de ventana: menos glow, mas corte limpio
- Sacar animacion borderangle en loop (desperdicio GPU)
- Gradiente de borde estatico o solo transicion al cambiar foco
- Bajar range/render_power de sombra

### 2.5 - Icon theme aeroso
Buscar en AUR algo glossy/aero. Candidatos: Vimix, Fluent azul, pack Frutiger Aero si existe.

### 2.6 - Wallpapers
3-4 wallpapers frutiger aero en ~/Pictures/wallpapers/. Documentar en README donde conseguirlos.

### 2.7 - Referencia: video tutorial Frutiger Aero en Hyprland
Transcripcion completa disponible. Puntos clave de implementacion CSS:
- Gradiente 4 paradas para waybar (blanco -> azul claro -> azul cristal -> azul negro)
- box-shadow inset para efecto relieve
- text-shadow negro detras de colores neon para legibilidad
- Hover: mas blanco/brillante para feedback visual
- Workspace activo: gradiente cian-azul con glow sutil
- Tooltip: fondo azul oscuro translucido, borde cian, sombra exterior

---

## Como trabajar

1. Fase 1 completa primero (bugs concretos)
2. Para monitor (1.5), pedir output de `hyprctl monitors`
3. Fase 2 de a un punto por vez, con explicacion antes de aplicar
4. Pedir confirmacion visual (screenshot) despues de cambios grandes
5. "Rico pero curado" - no maximalista

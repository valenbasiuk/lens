# Plan de acción profundo — Fase 3: robar sin vergüenza de end-4 y diinki-aero

## Contexto para quien retome esto (Opus u otra sesión)

Este documento es resultado de **desarmar literalmente los dos repos de referencia** (no es investigación de memoria): `diinki-aero-main.zip` completo (GTK theme, icon theme, waybar x2 versiones, wofi x2 versiones, eww, hyprland.conf, wallpapers) fue extraído y leído archivo por archivo, y se investigó la arquitectura actual de `end-4/dots-hyprland` (que en 2026 corre sobre **Quickshell**, no Waybar/AGS — dato importante, ver más abajo). El objetivo es identificar qué copiar literalmente (diinki-aero es GPLv3, licencia explícita en el repo, así que copiar con atribución es 100% legítimo) y qué "traducir" conceptualmente (las ideas funcionales de end-4, ya que su implementación en QML/Quickshell no es portable a nuestro stack sin adoptar quickshell — cosa que ya decidimos no hacer).

Repo propio de referencia: `lens` (ya tiene Fase 1 de bugs resuelta — monitor fijo, border sin animación en loop, blur configurado). Esto continúa desde ahí.

---

## PARTE 1 — Diagnóstico: por qué end-4 "no es directamente copiable"

Dato crítico encontrado en la investigación: **end-4/dots-hyprland migró completamente de Waybar/AGS a Quickshell** (framework QML). Todo — la barra, los sidebars, los widgets — es ahora QML corriendo sobre Quickshell, no CSS sobre GTK como Waybar. Esto significa que:

- **No se puede** copiar/pegar CSS o config de end-4 a nuestro `waybar/style.css` — son tecnologías distintas (QML vs GTK-CSS)
- **Sí se pueden** copiar las **ideas funcionales** e implementarlas con nuestro stack (rofi/waybar/swaync/scripts bash)

### Funcionalidades de end-4 que vale la pena "traducir" (no copiar código, copiar la idea):

| Feature de end-4 | Qué hace | Cómo lo traducimos a nuestro stack (rofi/waybar/swaync) |
|---|---|---|
| **Material You color extraction** | Extrae la paleta de colores del wallpaper activo y retematiza todo el sistema automáticamente | Usar **`wallust`** o **`matugen`** (herramientas CLI, no necesitan Quickshell) que generan variables de color desde una imagen y las inyectan como `@define-color` en el CSS de waybar/rofi/swaync. Esto es 100% portable a nuestro stack y es la feature más "wow" que podemos robar sin instalar nada pesado. |
| **Sidebar con notificaciones + música + calendario** | Panel lateral deslizable con todo el centro de control | Ya tenemos `swaync` (SwayNotificationCenter) que cubre notificaciones + un panel de control básico. Se puede extender su config con módulos custom de clima/música (swaync soporta widgets custom vía su config JSON) |
| **Cheatsheet de keybinds (Super+/)** | Overlay que muestra todos los atajos disponibles | Esto es trivial de replicar: un script que parsea `keybinds.conf` con `grep`/`awk` y lo muestra en un `rofi -dmenu` o una ventana simple. Buena idea funcional, cero dependencias nuevas. |
| **Drag-and-drop de ventanas entre workspaces** | Nativo de la UI de Quickshell | Hyprland ya soporta esto nativamente vía `bindm` (bind con mouse) — no es exclusivo de end-4, ya lo tenemos disponible, solo hace falta el keybind si no está |
| **Anti-flashbang / auto dark-light** | Ajusta brillo/gamma según hora del día | Se puede lograr con `hyprsunset` (herramienta oficial de Hypr ecosystem, liviana, no requiere Quickshell) |
| **Reconocimiento de la "zona menos ocupada" del wallpaper para poner el reloj** | Análisis de imagen para no tapar detalle visual | Demasiado complejo/no vale la pena para nuestro caso — anotado como "no implementar", prioridad de tiempo baja |
| **Clipboard/emoji picker unificado** | Un atajo, un picker | Ya tenemos `cliphist` + `rofi -show clipboard` cubriendo portapapeles. Para emoji, sumar `rofimoji` (rofi + emoji picker, encaja directo en nuestro launcher ya existente) |

**Conclusión Parte 1:** de end-4 no copiamos ni una línea de código — copiamos 4-5 ideas funcionales reales, todas implementables con herramientas livianas (`wallust`, `hyprsunset`, `rofimoji`, un script de cheatsheet) sin tocar el stack base.

---

## PARTE 2 — diinki-aero: shameless copying literal (GPLv3, con atribución)

Acá sí hay copy-paste real porque es CSS/GTK/iconos, compatible 1:1 con nuestro stack.

### 2.1 — El hallazgo más importante: la técnica del "borde como highlight"

Analizando `config/waybar/translucent-version/style.css` de diinki-aero encontré la técnica exacta que le falta a `lens` para verse "vidrio real" en vez de "plano con blur":

```css
#battery, #network, #clock, #tray, #workspaces, #pulseaudio {
  background-image: linear-gradient(to bottom, rgba(255,255,255,0.25), rgba(0,0,0,0.025));
  box-shadow: 0px 0px 3px rgba(0,0,0,0.34);
  border-style: none;
  border-bottom-style: solid;
  border-top-style: solid;
  border-bottom-color: rgba(255,255,255,0.15);
  border-top-color: rgba(255,255,255,0.45);
  border-width: 1px;
}
```

La clave: en vez de un `border` uniforme en los 4 lados, usan **solo borde superior e inferior**, con el de **arriba más brillante** (`0.45` alpha) que el de **abajo** (`0.15` alpha). Esto simula que la luz pega desde arriba en una superficie curva de vidrio — es un truco viejo de Aero real (Windows Vista/7 hacía exactamente esto en los botones). Nuestro `waybar/style.css` actual no tiene este patrón — usa un borde uniforme, por eso se ve "plano" en vez de "curvo/vidrioso".

**Acción:** reescribir cada módulo de nuestro waybar con este patrón de borde asimétrico top/bottom en vez de borde uniforme.

### 2.2 — La barra completa (`window#waybar`)

```css
window#waybar {
  background-image: linear-gradient(to bottom, rgba(255,255,255,0.25)0%, rgba(0,0,0,0.5)50%, rgba(0,0,0,0.6)50%);
  border-radius: 12px;
  border-style: solid;
  border-color: rgba(255,255,255,0.2);
}
```

Gradiente de 3 paradas (blanco arriba → negro medio → negro más oscuro abajo) en vez de nuestro gradiente actual — da más profundidad. Combinar esta idea con la paleta verde+azul que ya definimos (en vez de negro puro, usar azul muy oscuro `rgba(0,20,30,0.6)` para que no rompa la identidad de color del resto del sistema).

### 2.3 — Estados de módulo: activo/hover con glow real

```css
#taskbar button.active {
  background-image: linear-gradient(to bottom, rgba(0,255,255,0.6), rgba(0,100,100,0.1));
}
#workspaces button.active {
  color: @accent_color;
  text-shadow: 0px 0px 6px @accent_color;
}
#workspaces button:hover {
  transition-duration: 120ms;
  color: @accent_color;
  text-shadow: 0px 0px 8px @accent_color;
}
```

Nuestro workspace activo hoy no tiene esta combinación de `text-shadow` con blur de color — es lo que da el efecto "neón suave" en vez de solo cambiar de color sólido. Copiar el patrón, adaptado a que alterne cian/verde según el workspace (par/impar, por ejemplo) para reforzar la paleta dual que pediste.

### 2.4 — Tray menu (clic derecho en el system tray)

Diinki-aero tematiza hasta el menú contextual del tray (algo que normalmente queda gris feo por default):

```css
#tray menu {
  background-color: rgba(255,255,255,0.025);
  padding: 4px;
}
#tray menu menuitem {
  background-image: linear-gradient(to bottom, rgba(255,255,255,0.15),rgba(0,0,0,0.2),rgba(0,0,0,0.4));
  border-bottom-color: rgba(255,255,255,0.15);
  border-top-color: rgba(255,255,255,0.3);
}
#tray menu menuitem:hover {
  background-image: linear-gradient(to bottom, rgba(0,255,255,0.15), rgba(0,0,0,0.3), rgba(0,255,255,0.15));
  color: @accent_color;
  text-shadow: 0px 0px 6px @accent_color;
}
```

Esto es un detalle que la mayoría de la gente nunca toca (queda con el estilo default de GTK) y que suma muchísimo a la sensación de "todo está diseñado", no solo la barra. Copiar tal cual, adaptar color de acento.

### 2.5 — Wofi/Rofi: la fórmula de diinki

```css
#input {
  background-image: linear-gradient(to top, rgba(90,90,90,0.6), rgba(35,35,35,0.8));
  box-shadow: inset 0px -5px 8px rgba(0,0,0,0.4);
}
#entry {
  border-color: rgba(255,255,255,0.01);
  border-bottom-color: rgba(255,255,255,0.25);
  border-right-color: rgba(255,255,255,0.25);
  background-image: linear-gradient(to bottom, rgba(255,255,255,0.3)0%, rgba(20,20,20,0.2)50%, rgba(0,0,0,0.3)50%);
}
#entry:selected {
  background-color: rgba(0,255,255,0.4);
  box-shadow: 0px 0px 6px rgba(0,0,0,0.4);
}
```

Notar: usan `border-bottom-color` y `border-right-color` distintos (no simétrico) en cada entrada de la lista — es el mismo truco de "luz desde una dirección" pero aplicado a filas de lista, no solo a paneles. Nuestro `rofi/theme.rasi` actual no tiene esto — vale la pena portar el concepto a sintaxis `.rasi` (rofi usa su propio lenguaje de theming, no CSS puro, pero el concepto de bordes asimétricos + gradiente de 3 paradas es 100% portable).

### 2.6 — Valores de `hyprland.conf` (decoration/general) — el approach del borde "crisp"

Este es el hallazgo que responde directo a tu queja de "bordes de ventana no tan brillosos, que corten claro":

```
general {
    border_size = 1
    col.active_border = rgb(18,18,18)
    col.inactive_border = rgb(18,18,18)
}
decoration {
    rounding = 12
    active_opacity = 1.0
    shadow:range = 16
    shadow:render_power = 5
    shadow:color = rgba(0,0,0,0.35)
    blur:size = 2
    blur:passes = 3
    blur:vibrancy = 0.1696
}
```

**Esto confirma la hipótesis:** diinki-aero (que es *el* referente de looks que elegiste) usa un borde de ventana **casi negro y sin gradiente de color** (`rgb(18,18,18)` tanto activo como inactivo). Todo el "color" y "brillo" del sistema vive en los **paneles** (waybar, rofi, notificaciones) — no en el borde de las ventanas. El borde de ventana solo aporta el "corte" nítido entre una ventana y el fondo, con blur sutil (`size = 2`, bastante bajo comparado a nuestro `size = 10` actual) y una sombra suave para dar profundidad.

**Esto es un cambio de filosofía, no solo de valores.** Nuestro `lens` actual (después de Fase 1) tiene `col.active_border = rgba(00bcd4ff) rgba(7ed957ff) 45deg` — un borde con gradiente cian→verde en cada ventana. Eso es lo que se siente "demasiado brilloso" — cada ventana individual grita color todo el tiempo. La solución real (no solo "bajar el brillo") es: **sacar el color del borde de ventana**, dejarlo neutro/oscuro y sutil, y que el color/vidrio se concentre en la UI del sistema (barra, launcher, notificaciones) — igual que hace diinki-aero.

**Acción concreta:**
```
col.active_border = rgba(1a1a1aee)
col.inactive_border = rgba(1a1a1a88)
```
(o probar con un solo tono oscuro-azulado tipo `rgba(0a1418ee)` para no ir 100% neutro y mantener algo de identidad de color, a gusto — pero definitivamente sacar el gradiente arcoíris cian-verde del borde de ventana).

Blur bajarlo de `size = 10` a algo entre `4-6` (10 es alto para blur de ventana individual, especialmente sumado a que ya tenemos blur en los paneles — doble blur pesado es innecesario y es motivo real de gasto de GPU que mencionaste te preocupaba).

### 2.7 — GTK Theme + Icon Theme: literalmente ya existen, hechos, listos

Esto responde directo a tu pregunta de icon theme — **no hace falta buscar nada**, diinki-aero ya trae:

- **GTK Theme** propio (`GTKTheme/diinki-aero/`) con soporte GTK 2.0, 3.0, 3.20 y 4.0 — cubre toda la matriz de apps
- **Icon Theme "Crystal Remix"** (`IconTheme/crystal-remix-icon-theme-diinki-version/`) — es un remix de los íconos "Crystal" (el pack clásico de KDE de la era Aero real, azul/glossy/con biselado), con todos los tamaños (22 a 128px) y categorías (apps, places, devices, mimetypes, etc.)

**Acción:** copiar ambas carpetas directo al repo `lens` (con atribución GPLv3 en el README, citando el repo original), como paquetes de stow nuevos:
```
lens/
├── gtk-theme/
│   └── .local/share/themes/diinki-aero/...
├── icon-theme/
│   └── .local/share/icons/crystal-remix/...
```
Y en `install.sh`, agregar el paso de aplicarlos vía `gsettings` o dejarlo para que el usuario los seleccione con `nwg-look` (que ya está en el stack).

### 2.8 — Wallpapers: 3 imágenes, calidad de referencia real

`wallpapers/ArchPool.png`, `HIRAETH.png`, `aquarium.png` — ya los vi, son exactamente el estilo que buscás: objetos 3D de vidrio azul/verde flotando sobre agua con reflejo, curvas fluidas, paleta dual cian-verde-azul perfecta. **Copiar directo a `~/Pictures/wallpapers/`** (no van al repo de git por peso, pero si querés trackearlos igual no son gigantes — a tu criterio). Esto resuelve el punto de "3-4 fondos default" que pediste sin tener que buscar en ningún lado más.

---

## PARTE 3 — Plan de ejecución (orden sugerido)

### Sprint 1 — Ganancia visual más rápida y de mayor impacto
1. Copiar GTK theme + icon theme de diinki-aero al repo (2.7) — 10 minutos, impacto enorme (cambia TODA la UI de golpe: file manager, apps GTK, botones)
2. Copiar los 3 wallpapers (2.8) — 2 minutos
3. Cambiar `col.active_border`/`inactive_border` a neutro oscuro + bajar blur de ventana (2.6) — resuelve directamente tu queja de "bordes muy brillosos" y mejora performance

### Sprint 2 — Reescritura de waybar con la técnica de diinki
4. Aplicar el patrón de borde asimétrico top/bottom en todos los módulos (2.1)
5. Gradiente de 3 paradas en `window#waybar` (2.2)
6. Estados hover/activo con `text-shadow` glow (2.3)
7. Tematizar el tray menu (2.4) — detalle chico, gran impacto de "todo está pensado"

### Sprint 3 — Rofi con la misma fórmula
8. Reescribir `theme.rasi` con bordes asimétricos + gradiente 3 paradas (2.5)

### Sprint 4 — Funcionalidades tipo end-4 (opcional, después de que looks estén cerrados)
9. Instalar y configurar `wallust` o `matugen` para auto-color-extraction desde wallpaper (Material You-style) — la feature de mayor "wow factor" de todo este plan
10. Script de cheatsheet de keybinds (`Super + /`)
11. `hyprsunset` para ajuste automático día/noche
12. `rofimoji` para emoji picker integrado al launcher existente

### No hacer (evaluado y descartado)
- Migrar a Quickshell/AGS — rompe la filosofía "liviano, sin dependencias pesadas" que definimos desde el principio del proyecto
- Detección de "zona menos ocupada" del wallpaper para el reloj — complejidad/beneficio no vale la pena
- Portar el eww de diinki-aero (dock/gifs flotantes/menu circular) tal cual — es demasiado "maximalista" para lo que pediste ("rico pero curado, no recargado"). Si en algún momento se quiere un dock, evaluarlo como sprint separado, no meterlo de arranque.

---

## Instrucciones para quien ejecute esto

1. Los archivos fuente de diinki-aero (CSS, GTK theme, icon theme, wallpapers) están en el zip `diinki-aero-main.zip` que Valen ya tiene — no hace falta re-descargar nada, se puede extraer directo.
2. Aplicar en el orden de sprints de la Parte 3 — cada sprint es "shippeable" solo (se puede probar y confirmar visualmente antes de seguir al siguiente).
3. Para cada archivo modificado, mostrar el diff antes de aplicar y esperar confirmación — Valen quiere entender cada cambio, no solo recibirlo hecho.
4. Agregar en el README del repo `lens` una sección de créditos citando `diinki-aero` (GPLv3) por el GTK theme, icon theme "Crystal Remix", y la técnica de CSS de bordes asimétricos — es shameless copying pero con atribución correcta, no plagio silencioso.
5. Al terminar cada sprint, pedir a Valen un screenshot o descripción del resultado real en su hardware antes de seguir — la sesión que ejecuta esto no tiene forma de verificar visualmente el resultado.
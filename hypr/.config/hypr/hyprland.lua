-- ~/.config/hypr/hyprland.lua
-- Configuración nativa en Lua para Hyprland 0.55+
-- Corregido contra la API oficial real (ver https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua)

------------------
---- MONITORS ----
------------------
-- hl.monitor() se llama UNA VEZ POR MONITOR, con una tabla plana (no un array anidado)
hl.monitor({ output = "DP-1", mode = "1920x1080@165.00", position = "0x0", scale = 1 })
-- Si tenés un segundo monitor, descomentá y ajustá:
-- hl.monitor({ output = "DP-3", mode = "2560x1440@164.84", position = "1920x0", scale = 1 })

---------------------
---- MY PROGRAMS ----
---------------------
local terminal = "kitty"
local fileManager = "caja"
local menu = "wofi --show drun"
local mainMod = "SUPER"

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_DATA_HOME", os.getenv("HOME") .. "/.local/share")
hl.env("XDG_DATA_DIRS", "/usr/local/share:/usr/share")

-- workaround nvidia (si aplica a tu setup, descomentar)
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("GBM_BACKEND", "nvidia-drm")
-- hl.env("NVD_BACKEND", "direct")
-- hl.env("__GL_GSYNC_ALLOWED", "0")
-- hl.env("__GL_VRR_ALLOWED", "0")

-------------------
---- AUTOSTART ----
-------------------
-- exec-once ya no existe como keyword: se reemplaza suscribiéndose al evento hyprland.start
hl.on("hyprland.start", function()
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("waybar")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/eww/scripts/start.sh")
    os.execute('gsettings set org.gnome.desktop.interface gtk-theme "diinki-aero"')
    os.execute('gsettings set org.gnome.desktop.interface icon-theme "crystal-remix-icon-theme-diinki-version"')

    -- Abrir Calcurse y Ncspot automáticamente en Workspace 1
    hl.exec_cmd("kitty --class calcurse-desktop -e calcurse")
    hl.exec_cmd("kitty --class ncspot-desktop -e ncspot")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    input = {
        kb_layout = "us,se",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity = -0.94,
        repeat_rate = 80,
        repeat_delay = 200,
        accel_profile = "flat",
        touchpad = {
            natural_scroll = false,
        },
    },
    cursor = {
        no_hardware_cursors = true,
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 1,
        col = {
            active_border = "rgba(1a1a1aee)",
            inactive_border = "rgba(1a1a1a88)",
        },
        resize_on_border = true,
        layout = "dwindle",
        allow_tearing = false,
    },
    decoration = {
        rounding = 12,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 16,
            render_power = 5,
            color = "rgba(00000059)",
        },
        blur = {
            enabled = true,
            size = 4,
            passes = 3,
            vibrancy = 0.1696,
        },
    },
    animations = {
        enabled = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { {0, 1}, {0.18, 1.0} } })

hl.animation({ leaf = "windows",     enabled = true, speed = 1.5, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2,   bezier = "myBezier", style = "popin 95%" })
hl.animation({ leaf = "border",      enabled = true, speed = 12,  bezier = "myBezier" })
hl.animation({ leaf = "fade",        enabled = true, speed = 6,   bezier = "myBezier" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,   bezier = "myBezier" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
})

---------------------
---- KEYBINDINGS ----
---------------------

-- 1. Captura RÁPIDA directamente al portapapeles (Super + Shift + S)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))

-- 2. Captura con EDITOR Satty (Super + Alt + S)
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd(
    "grim -g \"$(slurp)\" - | satty --filename - --output-filename " ..
    os.getenv("HOME") .. "/Pictures/screenshots/satty-$(date +'%Y-%m-%d_%H-%M-%S').png"
))

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Abrir/cerrar el launcher con un solo toque de Super.
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("pkill wofi || wofi --show drun"), { release = true })

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

--------------------------------
---- WINDOWS AND LAYER RULES ----
--------------------------------

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- Regla para Calcurse (Workspace 1, flotante)
hl.window_rule({
    name = "calcurse-workspace1",
    match = { class = "^calcurse-desktop$" },
    workspace = 1,
    float = true,
    size = { 500, 400 },
    opacity = 0.85,
})

-- Regla para Ncspot (Workspace 1, flotante)
hl.window_rule({
    name = "ncspot-workspace1",
    match = { class = "^ncspot-desktop$" },
    workspace = 1,
    float = true,
    size = { 650, 450 },
    opacity = 0.85,
})

hl.layer_rule({
    name = "blur-wofi",
    match = { namespace = "wofi" },
    blur = true,
    ignore_alpha = 0.01,
})

hl.layer_rule({
    name = "blur-waybar",
    match = { namespace = "waybar" },
    blur = true,
    blur_popups = true,
    ignore_alpha = 0.01,
})

hl.layer_rule({
    name = "blur-eww",
    match = { namespace = "eww" },
    blur = true,
    blur_popups = true,
    ignore_alpha = 0.01,
})

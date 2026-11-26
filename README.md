<div align="center">

# 🌌 Dotfiles de P4PUNN0 (Dorfiles-P4)

<img width="2171" height="724" alt="Dorfiles P4 Banner" src="assets/banner.png" />

<p align="center">
  <img src="https://img.shields.io/badge/HYPRLAND-0.57-667A82?style=flat&labelColor=101418" height="20" alt="Hyprland">
  <img src="https://img.shields.io/badge/ARCH-LINUX-1793D1?style=flat&logo=archlinux&logoColor=ffffff&labelColor=101418" height="20" alt="Arch Linux">
  <img src="https://img.shields.io/badge/SHELL-ZSH_%2B_STARSHIP-8b9aaf?style=flat&logo=gnubash&logoColor=ffffff&labelColor=101418" height="20" alt="Zsh">
  <img src="https://img.shields.io/badge/TERMINAL-KITTY-FF5555?style=flat&labelColor=101418" height="20" alt="Kitty">
  <img src="https://img.shields.io/badge/BASED%20ON-43PR%20DOTFILES-blue?style=flat&labelColor=101418" height="20" alt="Based on 43PR">
  <img src="https://img.shields.io/badge/LICENSE-MIT-green?style=flat&labelColor=101418" height="20" alt="License">
</p>

> [!NOTE]
> 📌 **Aviso y Créditos**: Esta configuración está basada en los increíbles dotfiles de **[43PR/dotfiles](https://github.com/43PR/dotfiles)**. He realizado adaptaciones y ajustes personales a mi flujo de trabajo diario (atajos de teclado, distribución de teclado, editor predeterminado, opacidades, scripts de fondos animados, arte ASCII en Fastfetch y colección de wallpapers). ¡Todo el mérito de la base original pertenece a [43PR](https://github.com/43PR)!

<b><a href="#-modificaciones-respecto-a-la-base-original">Modificaciones</a> · <a href="#-atajos-de-teclado-keybinds">Atajos</a> · <a href="#-wallpapers">Wallpapers</a> · <a href="#-instalación">Instalación</a> · <a href="#-estructura">Estructura</a></b>

</div>

---

<img width="1920" height="1080" alt="Escritorio Preview" src="assets/desktop.png" />

## 📖 Descripción General

Este repositorio contiene la configuración completa para un entorno de escritorio en **Wayland**, utilizando **Hyprland** como gestor de ventanas tipo mosaico dinámico (tiling window manager) y **Quickshell** para la interfaz de escritorio (barra superior, ajustes, centro de control, selectores y OSDs).

Incluye tematización automática mediante **Matugen** (genera esquemas de colores Material You basados en el fondo de pantalla actual), desenfoque translúcido, terminal Kitty personalizada y atajos de teclado pensados para desarrollo y navegación rápida.

---

## 🛠️ Modificaciones respecto a la base original (43PR)

A continuación se detallan los ajustes personales realizados sobre el proyecto base:

1. **Atajo rápido para VS Code**:
   - `Super + C` abre **Visual Studio Code** (`code`).
2. **Atajo de Ajustes del Sistema**:
   - `Super + S` abre directamente el menú de ajustes (**Settings**).
3. **Navegador Web y Selector de Fondos**:
   - `Super + W` abre el navegador web (**Browser**).
   - `Super + P` abre el selector interactivo de fondos (**Wallpapers Picker**).
4. **Atajo de Panel Lateral**:
   - `Super + N` abre el panel lateral / notificaciones (**Side Panel**).
5. **Captura de Pantalla por Área**:
   - `Super + Shift + S` para selección de área de captura (**Screenshot Area**).
6. **Distribución de teclado**:
   - Cambiado a español latinoamericano (`kb_layout = "latam"`) en `.config/hypr/hyprland.lua`.
7. **Opacidad de ventanas**:
   - Ajustada por defecto a `0.9` en `.config/hypr/rules.lua` para dar un efecto translúcido equilibrado en todas las ventanas activas.
8. **Optimización de Fondos Animados (`live-wallpaper-pause.sh`)**:
   - Script mejorado para verificar si hay ventanas abiertas en el workspace actual y pausar automáticamente `mpvpaper` vía señal `SIGSTOP`/`SIGCONT` para ahorrar uso de CPU/GPU y batería.
9. **Fastfetch Personalizado**:
   - Añadido logo personalizado en arte ASCII (`ascii.txt`) y módulo de información reorganizado con colores en círculos.
10. **Terminal Kitty**:
   - Se añadió padding interno cómodo (`window_padding_width 15`) para separar el texto de los bordes.
11. **Avatar de Disco Personalizado P4**:
   - Disco 3D personalizado con el logo P4 en la página System de Quickshell.
12. **Wallpapers incorporados**:
   - Colección de fondos estáticos (`1.jpg` a `11.jpg`, `wallhaven-k8jvm7.jpg`) incluida directamente en la carpeta `wallpapers/`.
   - Soporte automático en `install.sh` tanto para rutas en español (`~/Imágenes/Wallpapers`) como en inglés (`~/Pictures/Wallpapers`).

---

## ⌨️ Atajos de Teclado (Keybinds)

> [!TIP]
> La tecla **Super** corresponde a la tecla `Windows` de tu teclado.  
> Los atajos se pueden consultar y personalizar visualmente desde la interfaz gráfica de **Quickshell** (`Super + S` → **Keybinds**).

| Función / Elemento | Atajo | Acción / Descripción |
|---|---|---|
| **Terminal** | `Super + T` | Abre la terminal (**Kitty**) |
| **Launcher** | `Super + D` | Lanzador de aplicaciones (**Rofi**) |
| **File Manager** | `Super + E` | Gestor de archivos (**Thunar**) |
| **Visual Studio Code** | `Super + C` | Editor de código (**VS Code**) |
| **Close Active Window** | `Super + Q` | Cierra la ventana activa actual |
| **Settings** | `Super + S` | Abre el menú de ajustes de Quickshell |
| **Browser** | `Super + W` | Abre el navegador web predeterminado |
| **Side Panel** | `Super + N` | Abre la barra lateral / Centro de acciones |
| **Fullscreen** | `Super + F` | Alterna modo de pantalla completa |
| **Floating Window** | `Super + Space` | Alterna modo flotante en la ventana activa |
| **Lock Screen** | `Super + Tab` | Bloquea la pantalla (**Hyprlock**) |
| **Power Menu** | `Super + \`` (Grave) | Menú de apagado, reinicio y cierre de sesión |
| **Opacity** | `Super + O` | Alterna la opacidad de la ventana activa |
| **Clipboard** | `Super + V` | Historial del portapapeles (**Cliphist**) |
| **Notes & Reminders** | `Super + C` | Abre notas y recordatorios rápidos |
| **Color Picker** | `Super + Shift + C` | Selector de color en pantalla |
| **Wallpapers Picker** | `Super + P` | Selector visual de fondos de pantalla |
| **Toggle Screen Recording** | `Super + R` | Inicia o detiene la grabación de pantalla |
| **Toggle Dark/Light Mode** | `Super + .` | Alterna entre tema claro y tema oscuro |
| **Toggle Bar** | `Super + Shift + W` | Oculta o muestra la barra superior |
| **KB Layout** | `Super + X` | Alterna la distribución del teclado |
| **Toggle Mic Mute** | `Super + M` | Silencia o activa el micrófono |
| **Screenshot (Full)** | `Delete` | Captura de pantalla completa |
| **Screenshot (Area)** | `Super + Shift + S` | Captura de pantalla por área seleccionada |
| **Text Extractor (OCR)** | `Shift + F12` | Reconocimiento óptico de caracteres en pantalla |
| **Focus Window** *(Fixed)* | `Super + H / J / K / L` | Mueve el foco entre ventanas en el mosaico |
| **Move Window** *(Fixed)* | `Super + Shift + H / J / K / L` | Mueve la ventana activa en el mosaico |
| **Switch Workspace** *(Fixed)* | `Super + 1 .. 9, 0` | Cambia entre los espacios de trabajo del 1 al 10 |
| **Move Window to Works...** *(Fixed)* | `Super + Shift + 1 .. 9, 0` | Mueve la ventana activa a otro workspace |
| **Zoom In / Out** *(Fixed)* | `Super + Scroll` | Zoom visual en la pantalla |

---

## 🖼️ Wallpapers

El repositorio incluye una carpeta `wallpapers/` con fondos listos para usar:

- **Fondos estáticos incluidos**:
  - `wallhaven-k8jvm7.jpg` (Fondo por defecto)
  - `1.jpg` a `11.jpg` y `2.png` (Anime, paisajes oscuros, estética cyberpunk y minimalista).

### ¿Cómo cambiarlos?
1. Presiona `Super + W` para abrir el selector visual de fondos.
2. Haz clic en el fondo que desees.
3. El sistema aplicará el fondo y **Matugen** regenerará dinámicamente la paleta de colores para Kitty, Hyprland y la interfaz.

### Fondos Animados (Live Wallpapers)
- Puedes colocar videos `.mp4` en `~/Pictures/Wallpapers/Animated/` o `~/Imágenes/Wallpapers/Animated/`.
- El script de fondo animado pausará la reproducción en cuanto tengas ventanas abiertas o activas para ahorrar consumo de procesador y batería.

---

## 🛠️ Instalación

### 📋 Requisitos

- Sistema operativo: **Arch Linux** o distros basadas (**CachyOS**, **EndeavourOS**, **Manjaro**, etc.).
- Tarjeta gráfica compatible con Wayland (Intel, AMD o NVIDIA con drivers actualizados).
- Gestor AUR: `yay` o `paru`.

### 📦 Pasos de Instalación

1. **Instalar Git**:
   ```bash
   sudo pacman -S git
   ```

2. **Clonar este repositorio**:
   ```bash
   git clone https://github.com/P4PUNN0/Dorfiles-P4.git ~/dotfiles
   ```

3. **Ejecutar el script de instalación**:
   ```bash
   cd ~/dotfiles
   chmod +x install.sh
   ./install.sh
   ```

4. **Reiniciar o cerrar sesión**:
   Inicia sesión seleccionando **Hyprland**.

> [!IMPORTANT]
> **No muevas ni elimines la carpeta `~/dotfiles`.**  
> La configuración enlaza simbólicamente desde `~/.config/` hacia `~/dotfiles/.config/`. Si cambias de ubicación el repositorio, ejecuta `./install.sh` nuevamente para actualizar los enlaces.

---

## 📁 Estructura del Repositorio

```text
dotfiles/
├── .config/
│   ├── 43pr/           # Scripts de theming dinámico y plantillas
│   ├── btop/           # Monitor de sistema
│   ├── cava/           # Visualizador de audio
│   ├── fastfetch/      # Info del sistema con arte ASCII
│   ├── gtk-3.0/        # Tema GTK 3
│   ├── gtk-4.0/        # Tema GTK 4
│   ├── hypr/           # Configuración de Hyprland (hyprland.lua, keybinds.lua, rules.lua, scripts)
│   ├── kitty/          # Terminal Kitty con Matugen y padding de 15px
│   ├── matugen/        # Extractor de colores dinámicos
│   ├── quickshell/     # Barra superior, menús, selector de fondos y settings
│   ├── rofi/           # Lanzador de apps y portapapeles
│   ├── spicetify/      # Configuración de tema para Spotify
│   ├── starship.toml   # Prompt de shell Starship
│   └── .zshrc          # Configuración de Zsh
├── wallpapers/         # Colección de wallpapers estáticos listos
├── assets/             # Banners y capturas de pantalla
├── install.sh          # Script de instalación y enlaces simbólicos
├── packages.txt        # Dependencias oficiales y AUR
└── README.md           # Documentación
```

---

## 🤝 Créditos y Reconocimientos

- **Proyecto Base**: Un agradecimiento especial a **[43PR](https://github.com/43PR/dotfiles)** por la creación de este magnífico entorno y sus componentes.
- **Selector de Fondos**: Basado en [hyprquickpaper](https://github.com/iamsurjog/hyprquickpaper) de iamsurjog.
- **Banner**: Por cherry✟ ([@aletiune](https://x.com/aletiune)).

---

<div align="center">
  <sub>Adaptado y mantenido por <a href="https://github.com/P4PUNN0">P4PUNN0</a></sub>
</div>

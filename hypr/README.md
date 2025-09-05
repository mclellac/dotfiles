# Hyprland Configuration

This repository contains a complete and highly customizable configuration for the Hyprland Wayland compositor. It's designed to be modular, themeable, and easy to manage, with a focus on script-based control. This document provides a comprehensive guide to the entire setup.

## Installation

The installation is handled by a single script.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/hypr.git ~/.config/hypr
    ```
2.  **Run the installation script:**
    ```bash
    ~/.config/hypr/install_deps.sh
    ```

### The Installation Script (`install_deps.sh`)

The `install_deps.sh` script automates the setup process. Here's what it does:

1.  **Installs `paru`:** It first checks if `paru` (an AUR helper) is installed. If not, it clones the `paru` repository and installs it.
2.  **Installs Official Packages:** It then uses `pacman` to install a long list of packages from the official Arch Linux repositories.
3.  **Installs AUR Packages:** Finally, it uses `paru` to install a few packages from the Arch User Repository (AUR).

#### Packages Installed

*   **Official Packages (`pacman`):**
    ```
    base-devel btop chromium fcitx5-im fcitx5-gtk fcitx5-qt git hyprland hypridle hyprlock hyprshot jq kitty lazydocker mako nautilus neovim obsidian pamixer playerctl polkit-gnome power-profiles-daemon signal-desktop swaybg swayosd ttf-firacode-nerd ttf-meslo-nerd ttf-victor-mono-nerd waybar wf-recorder wl-clipboard xdg-utils gum xmlstarlet
    ```
*   **AUR Packages (`paru`):**
    ```
    1password spotify uwsm
    ```

## Configuration Structure

The configuration is highly modular, with a central `hyprland.conf` that sources other files.

*   `hyprland.conf`: The main configuration file.
*   `monitors.conf`: Monitor setup.
*   `input.conf`: Input device configuration.
*   `bindings.conf`: User-specific keybindings.
*   `envs.conf`: Environment variables.
*   `autostart.conf`: Startup applications.

### Directories

*   `bin/`: The core scripts for managing the environment.
*   `config/`: Default configurations for various applications.
*   `current/`: Symlinks to the active theme's files.
*   `default/`: The base configuration files.
*   `scripts/`: Helper scripts used by other scripts.
*   `themes/`: All available themes.
*   `applications/`: `.desktop` files.

## Theming

The theming system is powerful and script-based.

### Applying a Theme

To change the theme, run:
```bash
hypr-theme-set <theme-name>
```
You can also use the `hypr-menu` to select a theme.

### Creating a Theme

1.  Copy an existing theme directory in `themes/`.
2.  Customize the files in your new theme's directory.
3.  Apply your theme with `hypr-theme-set`.

## Key Scripts

The `bin/` directory is the heart of this configuration. All scripts are designed to be run from the `hypr-menu`.

### `hypr-menu`

This script, typically bound to `SUPER + SPACE`, opens a searchable menu (using `walker`) that provides access to almost all functionality of the desktop. It's a multi-level menu system with the following structure:

*   **Go:** The main menu.
    *   **Apps:** Opens `walker` to launch an application.
    *   **Learn:** Provides access to documentation and learning resources.
        *   **Keybindings:** Opens a searchable list of keybindings.
        *   **Hypr:** Opens the custom Hypr manual in a web browser.
        *   **Hyprland:** Opens the official Hyprland wiki.
        *   **Arch:** Opens the Arch Linux wiki.
        *   **Bash:** Opens a Bash scripting cheatsheet.
        *   **Neovim:** Opens the LazyVim keymaps documentation.
    *   **Capture:** Tools for capturing the screen.
        *   **Screenshot:** Takes a screenshot.
            *   **Region:** Takes a screenshot of a selected region.
            *   **Window:** Takes a screenshot of the active window.
            *   **Display:** Takes a screenshot of the entire display.
        *   **Screenrecord:** Records the screen.
            *   **Region:** Records a selected region.
            *   **Display:** Records the entire display.
        *   **Color:** Opens a color picker.
    *   **Toggle:** Toggles various system features.
        *   **Screensaver:** Toggles the screensaver on and off.
        *   **Nightlight:** Toggles the nightlight (redshift).
        *   **Idle Lock:** Toggles locking the screen on idle.
        *   **Top Bar:** Toggles the Waybar on and off.
    *   **Style:** Manages the look and feel of the desktop.
        *   **Theme:** Opens a menu to select and apply a new theme.
        *   **Font:** Opens a menu to select and apply a new font.
        *   **Background:** Switches to the next background image for the current theme.
        *   **Screensaver:** Opens the screensaver text file in `nvim`.
        *   **About:** Opens the about text file in `nvim`.
    *   **Setup:** Configures system settings.
        *   **Audio:** Opens `wiremix` to configure audio.
        *   **Wifi:** Opens `impala` to configure wifi.
        *   **Bluetooth:** Opens `blueberry` to configure bluetooth.
        *   **Power Profile:** Opens a menu to select a power profile.
        *   **Monitors:** Opens `monitors.conf` in `nvim`.
        *   **Keybindings:** Opens `bindings.conf` in `nvim`.
        *   **Input:** Opens `input.conf` in `nvim`.
        *   **DNS:** Runs the `hypr-setup-dns` script.
        *   **Config:** Opens a sub-menu to edit various configuration files.
            *   **Hyprland:** Opens `hyprland.conf`.
            *   **Hypridle:** Opens `hypridle.conf`.
            *   **Hyprlock:** Opens `hyprlock.conf`.
            *   **Hyprsunset:** Opens `hyprsunset.conf`.
            *   **Swayosd:** Opens `swayosd/config.toml`.
            *   **Walker:** Opens `walker/config.toml`.
            *   **Waybar:** Opens `waybar/config.jsonc`.
            *   **XCompose:** Opens `~/.XCompose`.
        *   **Fingerprint:** Runs the `hypr-setup-fingerprint` script.
        *   **Fido2:** Runs the `hypr-setup-fido2` script.
    *   **Install:** Installs new software.
        *   **Package:** Installs a package from the official repositories.
        *   **AUR:** Installs a package from the AUR.
        *   **Web App:** Runs the `hypr-webapp-install` script.
        *   **TUI:** Runs the `hypr-tui-install` script.
        *   **Service:** Opens a sub-menu to install services like Dropbox and Tailscale.
        *   **Style:** Opens a sub-menu to install themes, backgrounds, and fonts.
        *   **Development:** Opens a sub-menu to install development environments for various languages.
        *   **Editor:** Opens a sub-menu to install various text editors.
        *   **AI:** Opens a sub-menu to install AI tools.
        *   **Gaming:** Opens a sub-menu to install Steam, RetroArch, and Minecraft.
    *   **Remove:** Removes software.
        *   **Package:** Removes a package.
        *   **Web App:** Runs the `hypr-webapp-remove` script.
        *   **TUI:** Runs the `hypr-tui-remove` script.
        *   **Theme:** Runs the `hypr-theme-remove` script.
        *   **Fingerprint:** Runs the `hypr-setup-fingerprint --remove` script.
        *   **Fido2:** Runs the `hypr-setup-fido2 --remove` script.
    *   **Update:** Manages updates.
        *   **Hypr:** Runs the `hypr-update` script.
        *   **Config:** Opens a sub-menu to refresh configuration files to their defaults.
        *   **Themes:** Runs the `hypr-theme-update` script.
        *   **Process:** Opens a sub-menu to restart various services.
        *   **Hardware:** Opens a sub-menu to restart wifi and bluetooth.
        *   **Timezone:** Runs the `hypr-cmd-tzupdate` script.
    *   **About:** Opens `fastfetch` to display system information.
    *   **System:** Manages the system state.
        *   **Lock:** Locks the screen.
        *   **Screensaver:** Launches the screensaver.
        *   **Suspend:** Suspends the system.
        *   **Relaunch:** Relaunches Hyprland.
        *   **Restart:** Reboots the system.
        *   **Shutdown:** Shuts down the system.

### Other Key Scripts

*   **`hypr-theme-set <theme-name>`:** This script applies a new theme. It works by clearing the `~/.config/hypr/current/theme` directory and then creating new symlinks to the files in the specified theme's directory (`~/.config/hypr/themes/<theme-name>`). It also handles setting the GTK theme, icon theme, and Chromium theme colors. Finally, it restarts key components like Waybar, Swayosd, and Mako to apply the new theme.

*   **`hypr-theme-list`:** This script simply lists the names of all the available themes by listing the directories in `~/.config/hypr/themes`.

*   **`hypr-theme-next`:** This script switches to the next available theme in the `~/.config/hypr/themes` directory. It does this by finding the current theme and then selecting the next one in the list.

*   **`hypr-theme-bg-next`:** This script switches to the next wallpaper in the current theme's `backgrounds` directory. It keeps track of the current wallpaper in a file and cycles through the available images.

*   **`hypr-refresh-config <config-file>`:** This script copies a default configuration file from `~/.config/hypr/config` to the user's config directory (e.g., `~/.config/hypr/config/alacritty/alacritty.toml` to `~/.config/alacritty/alacritty.toml`). It also creates a timestamped backup of the user's old configuration file.

*   **`hypr-lock-screen`:** This script locks the screen using `hyprlock`.

## Keybindings

The keybindings are defined in `bindings.conf` and the `bindings/` directory.

| Keybinding | Action |
|---|---|
| `SUPER + RETURN` | Open terminal (`alacritty`) |
| `SUPER + SPACE` | Open `hypr-menu` |
| `SUPER + Q` | Close active window |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + [1-9]` | Switch to workspace |
| `SUPER + SHIFT + [1-9]` | Move active window to workspace |
| `SUPER + P` | Toggle pseudo-tiling |
| `SUPER + S` | Toggle floating |
| `SUPER + H/J/K/L` | Move focus |
| `SUPER + SHIFT + H/J/K/L` | Move window |
| `PrintScreen` | Screenshot region |
| `SUPER + PrintScreen` | Screenshot window |
| `CTRL + PrintScreen` | Screenshot output |

## Custom and Legacy Components

This configuration includes several custom and potentially legacy components.

### Pacman Repository

The `default/pacman/pacman.conf` file includes a custom pacman repository:

```
[hypr]
SigLevel = Optional TrustAll
Server = https://pkgs.hypr.org/$arch
```

If you don't own or trust this repository, you should remove this section from your `pacman.conf`.

### Plymouth Theme

The `default/plymouth` directory contains a custom plymouth theme. You can customize the images in this directory to create your own boot splash screen.

### `hyprpanel`

The `hyprpanel` directory contains configuration for a custom panel. This component does not appear to be used in the current configuration and is likely a leftover from a previous setup.

### `old.hypr`

The `old.hypr` directory contains a previous version of the configuration. It is not used and can likely be removed.

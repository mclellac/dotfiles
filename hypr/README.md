# Hyprland Configuration Documentation

This document explains the structure and customization of this Hyprland setup.

## Design Philosophy

This Hyprland configuration is designed to be modular, customizable, and easy to manage. It follows a few key principles:

-   **Modularity:** The configuration is broken down into smaller, self-contained files, making it easier to understand and modify. The main `hyprland.conf` file sources these smaller files.
-   **Default and User Overrides:** The configuration uses a `default` directory to store the base settings. Users can then override these settings by creating their own configuration files in the root of the `hypr` directory. This allows for easy customization without modifying the base configuration.
-   **Script-Based Management:** The environment is managed by a collection of shell scripts located in the `hypr/bin` directory. These scripts handle tasks such as theme switching, application launching, and system management.

## Directory Structure

The `hypr` directory contains all the configuration for Hyprland and related applications.

-   `hyprland.conf`: The main entry point for Hyprland's configuration. It sources other configuration files.
-   `monitors.conf`: Defines monitor setups, resolutions, and workspaces.
-   `input.conf`: Configures input devices like keyboards and mice.
-   `bindings.conf`: Contains custom keybindings for applications and scripts.
-   `envs.conf`: Sets environment variables for the Hyprland session.
-   `autostart.conf`: Specifies applications and scripts to run on startup.
-   `theme/`: This directory holds the currently active theme. It contains symlinks to the files of the selected theme from the `themes/` directory. **Do not edit files in this directory directly.**
-   `themes/`: This directory contains all available themes. Each theme has its own subdirectory.
-   `bin/`: Contains various helper scripts for managing the environment, including theme switching, power menus, and application launchers.
-   `scripts/`: Contains scripts that are used by hyprland, but not intended to be run by the user directly.
-   `config/`: Contains configuration files for other applications that are themed, such as alacritty, kitty, rofi, etc.
-   `applications/`: Contains `.desktop` files for applications.

## Installation

To install this configuration, follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone <repository-url> ~/.config
    ```
2.  **Install dependencies:** This configuration depends on a few key packages. You will need to install them using your package manager.
    -   `hyprland`: The Wayland compositor.
    -   `waybar`: The status bar.
    -   `uwsm`: The Universal Wayland Session Manager. This is a crucial dependency for many of the scripts. You can install it from the Arch Linux repositories (`sudo pacman -S uwsm`).
    -   Other dependencies: You may need to install other packages depending on the scripts and applications you use.

## Theming

This setup uses a script-based theming system that applies a consistent look and feel across multiple applications. The core of this system is the `hypr-theme-set` script.

### The `hypr-theme-set` Script

The `hypr-theme-set` script is the heart of the theming system. When you run `hypr-theme-set <theme-name>`, it performs the following actions:

1.  **Symlinking**: The script first clears the `~/.config/hypr/theme/` directory. It then creates new symlinks in this directory that point to all the files in the selected theme's directory (e.g., `~/.config/hypr/themes/<theme-name>/*`). This makes the selected theme's files "active".

2.  **Application Theming**: The script then proceeds to theme various applications:
    *   **GTK/Gnome**: It sets the GTK theme (e.g., to `Adwaita-dark`) and icon theme based on the presence of `light.mode` and `icons.theme` files in the theme directory.
    *   **Chromium**: It sets the browser's color scheme and theme color.
    *   **Alacritty**: It touches the `alacritty.toml` file to trigger a configuration reload.
    *   **Other Applications**: It restarts `btop`, `waybar`, `swayosd`, and `mako` to apply their new themes. Waybar, SwayOSD, and Mako all have configuration files that source the theme's CSS file from `~/.config/hypr/theme/`.
    *   **Hyprland**: It reloads Hyprland, which sources its theme from `~/.config/hypr/theme/hyprland.conf`.
    *   **Background**: It sets a new desktop background from the theme's `backgrounds` directory.

### Themed Applications

The following applications are themed by the `hypr-theme-set` script:

*   Alacritty (terminal)
*   btop (resource monitor)
*   Chromium (web browser)
*   GTK/Gnome applications
*   Hyprland (window manager)
*   Mako (notification daemon)
*   SwayOSD (on-screen display)
*   Waybar (status bar)

**Note**: Some applications, like `walker`, have their own theming mechanism which is not controlled by `hypr-theme-set`. See the "Walker Theming" section for more details.

### Walker Theming

The `walker` application launcher is **not** themed by the `hypr-theme-set` script. It uses its own theming system.

-   **Configuration**: Walker's configuration is located at `~/.config/walker/config.toml`.
-   **Theme Location**: The `theme_location` key in `config.toml` points to `~/.config/hypr/default/walker/themes/`, which contains a set of pre-defined themes (e.g., `dmenu_250`).
-   **Theme Selection**: The `hypr-menu` script launches walker and tells it which theme to use with the `--theme` flag (e.g., `walker --theme dmenu_250`).

The `walker.css` files present in each theme's directory (e.g., `hypr/themes/catppuccin/walker.css`) are currently **not used**.

### Creating a New Theme

To create your own theme, follow these steps:

1.  **Create a Theme Directory**: Copy an existing theme directory from `hypr/themes/` to a new directory with your theme's name (e.g., `my-awesome-theme`).

    ```bash
    cp -r ~/.config/hypr/themes/rose-pine ~/.config/hypr/themes/my-awesome-theme
    ```

2.  **Customize Theme Files**: Edit the files inside your new theme directory (`~/.config/hypr/themes/my-awesome-theme/`) to your liking. You will need to at least provide:
    *   `alacritty.toml`: Alacritty terminal theme.
    *   `btop.theme`: btop resource monitor theme.
    *   `chromium.theme`: Chromium theme color.
    *   `hyprland.conf`: Hyprland window manager theme (borders, gaps, etc.).
    *   `hyprlock.conf`: Hyprlock lock screen theme.
    *   `icons.theme`: GTK icon theme name.
    *   `mako.ini`: Mako notification theme.
    *   `neovim.lua`: Neovim theme.
    *   `swayosd.css`: SwayOSD on-screen display theme.
    *   `waybar.css`: Waybar status bar theme.
    *   A `backgrounds/` directory containing at least one wallpaper image.

3.  **Set the New Theme**: Apply your new theme by running:

    ```bash
    hypr-theme-set my-awesome-theme
    ```

## Key Scripts (`hypr/bin`)

Here are some of the most important scripts in the `hypr/bin` directory:

-   `hypr-theme-set <theme-name>`: Sets the specified theme.
-   `hypr-theme-list`: Lists all available themes.
-   `hypr-theme-next`: Switches to the next available theme.
-   `hypr-theme-bg-next`: Switches to the next background image for the current theme.
-   `hypr-menu`: Opens the main application launcher (a replacement for rofi/wofi, likely `walker`).
-   `hypr-lock-screen`: Locks the screen.
-   `hypr-restart-app <app-name>`: A generic script to restart applications. It uses `uwsm` to manage the application session.

**Note on `uwsm`:** Many of the scripts in this configuration depend on the **Universal Wayland Session Manager (`uwsm`)**. This tool is used to manage application sessions and ensure they are started and stopped correctly. You must have `uwsm` installed for these scripts to work. On Arch Linux, you can install it with `sudo pacman -S uwsm`.

## Suggestions for Improvement

This configuration is already very powerful and well-structured. Here are a few suggestions for further improvement:

-   **Unify Walker Theming**: The `walker` theming is separate from the main `hypr-theme-set` system. It could be beneficial to integrate it, so that `walker`'s theme changes automatically with the system theme. This would likely involve modifying the `hypr-theme-set` script to update `walker`'s configuration.
-   **Pacman Repository:** The configuration includes a custom pacman repository. If you don't own the `pkgs.hypr.org` domain, you should either remove this repository from `hypr/default/pacman/pacman.conf` or set up your own pacman repository.
-   **Plymouth Theme:** The configuration includes a custom plymouth theme. You can customize the images in `hypr/default/plymouth` to create your own boot splash screen.

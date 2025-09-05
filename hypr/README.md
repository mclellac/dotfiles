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

This setup uses a script-based theming system that applies a consistent look and feel across multiple applications.

### How it Works

1.  **Theme Storage**: All themes are located in the `hypr/themes/` directory. Each theme is a directory containing configuration files for different applications (e.g., `hyprland.conf`, `waybar.css`, `alacritty.toml`).
2.  **Theme Activation**: The `hypr-theme-set` script is used to change the active theme. When you run `hypr-theme-set <theme-name>`, the script does the following:
    *   It clears the `hypr/theme/` directory of any existing symlinks.
    *   It creates new symlinks in `hypr/theme/` that point to all the files in the `hypr/themes/<theme-name>/` directory.
3.  **Configuration Sourcing**: The main `hypr/hyprland.conf` file sources `~/.config/hypr/theme/hyprland.conf`. Because of the symlinking, this effectively loads the `hyprland.conf` from the currently active theme. Other applications are reloaded to apply their new theme files.

### Creating a New Theme

To create your own theme, follow these steps:

1.  **Create a Theme Directory**: Copy an existing theme directory from `hypr/themes/` to a new directory with your theme's name. For example:
    ```bash
    cp -r hypr/themes/rose-pine hypr/themes/my-awesome-theme
    ```
2.  **Customize Theme Files**: Edit the files inside your new theme directory (`hypr/themes/my-awesome-theme/`) to your liking. You can change colors, fonts, wallpapers, and other settings. Pay close attention to `hyprland.conf` for window decorations, `waybar.css` for the bar, and the terminal configuration (`alacritty.toml` or `kitty.conf`).
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

-   **Pacman Repository:** The configuration includes a custom pacman repository. If you don't own the `pkgs.hypr.org` domain, you should either remove this repository from `hypr/default/pacman/pacman.conf` or set up your own pacman repository.
-   **Plymouth Theme:** The configuration includes a custom plymouth theme. You can customize the images in `hypr/default/plymouth` to create your own boot splash screen.
-   **Nerd Fonts:** The Waybar configuration uses a custom font to display an icon. A better approach would be to use a Nerd Font, which includes a large collection of icons. This would remove the dependency on the custom font and make it easier to customize the icons.
-   **Review `old.hypr`:** There is an `old.hypr` directory that contains an old configuration. You may want to review this directory and remove it if it's no longer needed.
-   **Review `hyprpanel`:** There is a `hyprpanel` directory that contains a configuration for a panel. It's not clear if this is still being used. You may want to review this and remove it if it's not needed.

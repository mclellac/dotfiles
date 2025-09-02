# Hyprland Configuration Documentation

This document explains the structure and customization of this Hyprland setup.

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

## Theming

This setup uses a script-based theming system that applies a consistent look and feel across multiple applications.

### How it Works

1.  **Theme Storage**: All themes are located in the `hypr/themes/` directory. Each theme is a directory containing configuration files for different applications (e.g., `hyprland.conf`, `waybar.css`, `alacritty.toml`).
2.  **Theme Activation**: The `omarchy-theme-set` script is used to change the active theme. When you run `omarchy-theme-set <theme-name>`, the script does the following:
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
    omarchy-theme-set my-awesome-theme
    ```

## Key Scripts (`hypr/bin`)

Here are some of the most important scripts in the `hypr/bin` directory:

-   `omarchy-theme-set <theme-name>`: Sets the specified theme.
-   `omarchy-theme-list`: Lists all available themes.
-   `omarchy-theme-next`: Switches to the next available theme.
-   `omarchy-theme-bg-next`: Switches to the next background image for the current theme.
-   `omarchy-menu`: Opens the main application launcher (rofi/wofi).
-   `rofi-power.sh`: Shows the power menu (shutdown, reboot, etc.).
-   `idle.sh`: Manages system idling and screen locking.

This documentation should provide a good starting point for understanding and customizing this Hyprland environment.

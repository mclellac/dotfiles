# Hyprland Configuration

This directory contains the configuration for the Hyprland compositor.

## Structure

The configuration is split into two main directories:
- `hyprland/`: Contains the default configuration files.
- `custom/`: Contains user-specific overrides and custom scripts.

Settings in `custom/` will override the default settings in `hyprland/`.

## Plugins

This configuration uses the following plugins:

### hyprpm

`hyprpm` is the Hyprland Plugin Manager. It is used to manage plugins. The command `hyprpm reload` is run on startup to load all enabled plugins.

### hyprexpo

`hyprexpo` is a workspace overview plugin that allows you to see all your workspaces at once. This plugin is currently configured but does not have an active keybinding.

### hyprbars

`hyprbars` is a plugin that provides title bars for windows.

**Configuration:**
This plugin is configured to only show on terminal windows. It uses a blacklist approach, defined in `hypr/hyprland/rules.conf`, to disable the bar for common non-terminal applications.

## Keybindings

Here are some of the most important keybindings in this configuration:

| Keybinding | Description |
| --- | --- |
| `Super + Space` | Launch application launcher (fuzzel) |
| `Super + V` | Show clipboard history |
| `Super + Shift + S` | Take a screen snip |
| `Super + Q` | Close active window |
| `Super + Return` | Launch terminal (kitty) |
| `Super + E` | Launch file manager |
| `Super + W` | Launch web browser |
| `Super + C` | Launch code editor |
| `Super + [0-9]` | Switch to workspace |
| `Super + Alt + [0-9]` | Move window to workspace |
| `Super + D` | Maximize window |
| `Super + F` | Toggle fullscreen |
| `Super + P` | Pin window |
| `Super + Left/Right/Up/Down` | Move focus |
| `Super + Shift + Left/Right/Up/Down` | Move window |

## Theme

This configuration uses a custom color scheme defined in `hypr/hyprland.conf`. The palette is based on a dark background with vibrant blue and cyan accents.

| Variable     | Hex       |
| ------------ | --------- |
| `$active`    | `#028EB6` |
| `$inactive`  | `#1b2e38` |
| `$background`| `#28292e` |
| `$foreground`| `#8c90a1` |
| `$cyan`      | `#9AD7F5` |
| `$orange`    | `#ff9500` |
| `$green`     | `#05876f` |
| `$red`       | `#ad2840` |
| `$magenta`   | `#c259af` |

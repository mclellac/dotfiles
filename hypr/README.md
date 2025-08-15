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

`hyprexpo` is a workspace overview plugin that allows you to see all your workspaces at once.

**Usage:**
The keybinding for `hyprexpo` is `CTRL+SUPER+UP_ARROW`.

### hyprbars

`hyprbars` is a plugin that provides title bars for windows.

**Configuration:**
This plugin is configured to only show on terminal windows. It uses a blacklist approach, defined in `hypr/hyprland/rules.conf`, to disable the bar for common non-terminal applications.

The bar changes color to indicate whether the window is active or inactive. It has one button to close the active window.

## Keybindings

Here are some of the most important keybindings in this configuration:

| Keybinding | Description |
| --- | --- |
| `Super + Space` | Launch application launcher (fuzzel) |
| `Super + V` | Show clipboard history |
| `CTRL + Super + Up` | Show workspace overview (hyprexpo) |
| `Super + Shift + S` | Take a screen snip |
| `Super + Q` | Close active window |
| `Super + L` | Lock the session |
| `Super + Return` | Launch terminal (kitty) |
| `Super + E` | Launch file manager |
| `Super + W` | Launch web browser |
| `Super + C` | Launch code editor |
| `Super + [0-9]` | Switch to workspace |
| `Super + Alt + [0-9]` | Move window to workspace |
| `Super + S` | Toggle special workspace (scratchpad) |
| `Super + D` | Maximize window |
| `Super + F` | Toggle fullscreen |
| `Super + P` | Pin window |
| `Super + Left/Right/Up/Down` | Move focus |
| `Super + Shift + Left/Right/Up/Down` | Move window |

## Theme

This configuration uses a custom theme based on the Tokyo Night color palette.

| Name      | Hex       | RGB             |
| --------- | --------- | --------------- |
| Orange    | `#EA9D34` | `234, 157, 52`  |
| Background| `#1a1b26` | `26, 27, 38`    |
| Foreground| `#c0caf5` | `192, 202, 245` |
| Inactive  | `#414868` | `65, 72, 104`   |
| Blue      | `#7aa2f7` | `122, 162, 247` |
| Cyan      | `#7dcfff` | `125, 207, 255` |
| Green     | `#9ece6a` | `158, 206, 106` |
| Red/Urgent| `#f7768e` | `247, 118, 142` |
| Magenta   | `#ff79c6` | `255, 121, 198` |

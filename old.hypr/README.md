# Hyprland Configuration

This is my personal Hyprland configuration. It's designed to be a simple and efficient setup for my daily workflow.

## Features

*   **Modular Configuration:** The configuration is split into multiple files for easy management.
*   **Wofi Integration:** Uses `wofi` for the application launcher, SSH menu, and power menu.
*   **UWSM Support:** Includes support for the `uwsm` tiling window manager.
*   **Waybar Integration:** A custom Waybar configuration with a power menu.

## Installation

### 1. Install Dependencies

**Arch Linux:**

```bash
sudo pacman -S hyprland wofi waybar kitty uwsm
```

**Fedora:**

```bash
sudo dnf install hyprland wofi waybar kitty uwsm
```

### 2. Clone this repository

```bash
git clone <repository-url> ~/.config
```

### 3. D-Bus Broker Setup

It is highly recommended to use `dbus-broker` as the D-Bus daemon implementation.

**Arch Linux:**

```bash
sudo pacman -S dbus-broker
```

**Fedora:**

```bash
sudo dnf install dbus-broker
```

**Enable the `dbus-broker` service:**

```bash
systemctl --user enable dbus-broker.service
```

**Start the `dbus-broker` service:**

```bash
systemctl --user start dbus-broker.service
```

### 4. UWSM Setup

This configuration uses `uwsm` to manage the Hyprland session.

**Enable the `uwsm` systemd service:**

```bash
systemctl --user enable uwsm.service
```

**Start the `uwsm` service:**

```bash
systemctl --user start uwsm.service
```

Now, you can log in to your Hyprland session from your display manager by selecting the `Hyprland` session.

## Keybindings

| Keybinding          | Action                               |
| ------------------- | ------------------------------------ |
| `SUPER + T`         | Open terminal (kitty)                |
| `SUPER + E`         | Open file manager (nautilus)         |
| `SUPER + C`         | Color picker (hyprpicker)            |
| `SUPER + .`         | Emoji picker (wofimoji)              |
| `SUPER + Space`     | Application launcher (wofi)          |
| `SUPER + S`         | SSH menu (wofi)                      |
| `SUPER + X`         | Power menu (wofi)                    |
| `SUPER + L`         | Lock screen                          |
| `SUPER + P`         | Toggle pseudo tiling                 |
| `SUPER + F`         | Toggle fullscreen                    |
| `SUPER + Q`         | Close active window                  |
| `SUPER + I`         | Toggle UWSM workspace                |
| `SUPER + U`         | Kill active UWSM client              |
| `SUPER + 1-0`       | Switch to workspace 1-10             |
| `SUPER + SHIFT + 1-0` | Move window to workspace 1-10        |

## Scripts

*   `exec_wofi`: A unified script for launching `wofi` with different modes.
*   `wofi-ssh.sh`: A script for selecting an SSH host from `~/.ssh/known_hosts`.
*   `wofi-power.sh`: A script for displaying a power menu with options to logout, reboot, shutdown, and lock the screen.

## Required Packages

*   `hyprland`
*   `wofi`
*   `waybar`
*   `kitty`
*   `uwsm`
*   `nautilus`
*   `hyprpicker`
*   `wofimoji`
*   `cliphist`
*   `grimblast`
*   `dunst`
*   `pipewire`
*   `wireplumber`
*   `polkit-gnome`
*   `gnome-keyring`
*   `dbus`
*   `xwayland`
*   `hyprpaper`
*   `wlsunset`
*   `pamixer`
*   `network-manager-applet`
*   `pavucontrol`
*   `brightnessctl`
*   `playerctl`

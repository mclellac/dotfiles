#!/bin/bash

# Function to print error messages and exit
error() {
    echo "Error: $1" >&2
    exit 1
}

# Detect the OS
if [ -f /etc/arch-release ]; then
    OS="arch"
elif [ -f /etc/fedora-release ]; then
    OS="fedora"
else
    error "Unsupported OS. This script only supports Arch Linux and Fedora."
fi

# Install packages
if [ "$OS" == "arch" ]; then
    # Install yay if it's not already installed
    if ! command -v yay &> /dev/null; then
        echo "yay is not installed. Installing it now..."
        sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
    fi
    yay -S --needed uwsm dbus-broker-units kitty wofi waybar dunst cliphist wl-paste hyprpaper polkit-gnome nautilus wofimoji neovim htop neovide grimblast
elif [ "$OS" == "fedora" ]; then
    sudo dnf install -y kitty wofi waybar dunst cliphist wl-paste hyprpaper polkit-gnome nautilus wofimoji neovim htop neovide grimblast
    # Install uwsm from source, as it's not in the default Fedora repos
    if ! command -v uwsm &> /dev/null; then
        echo "uwsm is not installed. Installing it now from source..."
        sudo dnf install -y meson python3-pyxdg python3-dbus
        git clone https://github.com/Vladimir-csp/uwsm.git
        cd uwsm
        meson setup --prefix=/usr/local -Duuctl=enabled -Dfumon=enabled -Duwsm-app=enabled build
        meson install -C build
        cd ..
        rm -rf uwsm
    fi
fi

# Enable and start dbus-broker
systemctl --user enable --now dbus-broker.service

echo "Hyprland setup complete. Please reboot your system."

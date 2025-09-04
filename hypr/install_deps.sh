#!/bin/bash

# This script installs all necessary dependencies for the Hyprland configuration.
# It uses pacman for official repository packages and paru for AUR packages.

# --- Helper Functions ---
# Function to print colored output
print_info() {
    echo -e "\e[1;34m[INFO]\e[0m $1"
}

print_success() {
    echo -e "\e[1;32m[SUCCESS]\e[0m $1"
}

print_error() {
    echo -e "\e[1;31m[ERROR]\e[0m $1"
}

# --- Package Lists ---
# Official repository packages
PACMAN_PACKAGES=(
    base-devel
    btop
    chromium
    #fastfetch
    fcitx5-im
    fcitx5-gtk
    fcitx5-qt
    git
    hyprland
    hypridle
    hyprlock
    hyprshot
    jq
    kitty
    lazydocker
    mako
    nautilus
    neovim
    obsidian
    pamixer
    playerctl
    polkit-gnome
    power-profiles-daemon
    signal-desktop
    swaybg
    swayosd
    ttf-firacode-nerd
    ttf-meslo-nerd
    ttf-victor-mono-nerd
    waybar
    wf-recorder
    wl-clipboard
    xdg-utils
    gum
    xmlstarlet
)

# AUR packages
PARU_PACKAGES=(
    1password
    spotify
    uwsm
    walker-git
    #satty-bin
)

# --- Installation Logic ---

# Function to install paru if not present
install_paru() {
    if ! command -v paru &>/dev/null; then
        print_info "paru not found. Attempting to install it..."

        # Ensure build dependencies are present
        sudo pacman -S --needed --noconfirm base-devel git
        if [ $? -ne 0 ]; then
            print_error "Failed to install build dependencies for paru. Please install them manually and re-run the script."
            exit 1
        fi

        # Clone and build paru
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        (cd /tmp/paru && makepkg -si --noconfirm)

        # Verify installation
        if ! command -v paru &>/dev/null; then
            print_error "paru installation failed. Please install it manually from the AUR and re-run the script."
            exit 1
        else
            print_success "paru has been successfully installed."
        fi
    else
        print_info "paru is already installed."
    fi
}

# --- Main Script ---

# 1. Install paru
install_paru

# 2. Install official packages
print_info "Installing official repository packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
if [ $? -ne 0 ]; then
    print_error "An error occurred during pacman package installation. Please check the output above."
    exit 1
fi
print_success "Official packages installed successfully."

# 3. Install AUR packages
print_info "Installing AUR packages..."
paru -S --needed --noconfirm "${PARU_PACKAGES[@]}"
if [ $? -ne 0 ]; then
    print_error "An error occurred during paru package installation. Please check the output above."
    exit 1
fi
print_success "AUR packages installed successfully."

print_success "All dependencies have been installed!"

#!/bin/bash
set -e

CONFIG_DIR="$HOME/.config/mutt"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/mutt"

echo "Detected OS: $OSTYPE"

install_arch() {
    echo "Installing dependencies for Arch Linux..."
    # python-vobject python-icalendar python-pytz python-tzlocal are usually in [extra] or [community]
    sudo pacman -S --noconfirm neomutt urlscan w3m pandoc xdg-utils mpv html2text glow \
        python-vobject python-icalendar python-pytz python-tzlocal
    # sc-im might be in AUR. Check if installed, if not, warn.
    if ! command -v sc-im &> /dev/null; then
        echo "sc-im not found. It is recommended to install it from AUR (e.g., yay -S sc-im)."
    fi
}

install_debian() {
    echo "Installing dependencies for Debian/Ubuntu..."
    sudo apt update
    # Need to check if glow is available, if not, user might need charm repo
    # But for now we try to install it.
    # Also installing python deps.
    sudo apt install -y neomutt urlscan w3m pandoc xdg-utils mpv sc-im html2text \
        python3-vobject python3-icalendar python3-pytz python3-tzlocal

    # Check for glow (from charmbracelet)
    if ! command -v glow &> /dev/null; then
        echo "Attempting to install glow via apt (if available)..."
        if ! sudo apt install -y glow; then
             echo "glow not found in apt repositories. Please install it manually (https://github.com/charmbracelet/glow)."
        fi
    fi
}

install_fedora() {
    echo "Installing dependencies for Fedora..."
    sudo dnf install -y neomutt urlscan w3m pandoc xdg-utils mpv sc-im html2text glow \
        python3-vobject python3-icalendar python3-pytz python3-tzlocal
}

install_macos() {
    echo "Installing dependencies for macOS..."
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Please install Homebrew first."
        exit 1
    fi
    brew install neomutt urlscan w3m pandoc mpv sc-im html2text glow

    echo "Installing python dependencies via pip..."
    pip3 install --user vobject icalendar pytz tzlocal

    # xdg-open equivalent on mac is 'open', usually built-in or mapped by neomutt config if configured,
    # but we list xdg-utils just in case user has environment that uses it.
    # Actually macOS doesn't use xdg-utils by default for 'xdg-open' unless installed or aliased.
    # The mailcap config uses `xdg-open`. On macOS, one might need an alias:
    # alias xdg-open="open" or install a shim.
    # We will verify if xdg-open exists.
    if ! command -v xdg-open &> /dev/null; then
        echo "Creating xdg-open alias to open for macOS compatibility..."
        # This is tricky to make persistent without touching shellrc.
        # But for the script execution it's fine.
        # However, neomutt calls xdg-open.
        # Better: create a symlink in a bin dir or user should handle it.
        # Let's assume user might have it or we suggest it.
        echo "Note: Ensure 'xdg-open' is in your PATH. You can alias it to 'open': alias xdg-open='open'"
    fi
}

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/arch-release ]; then
        install_arch
    elif [ -f /etc/debian_version ]; then
        install_debian
    elif [ -f /etc/fedora-release ]; then
        install_fedora
    else
        echo "Unsupported Linux distribution. Please install dependencies manually: neomutt urlscan w3m pandoc xdg-utils sc-im mpv html2text glow python3-vobject python3-icalendar python3-pytz python3-tzlocal"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_macos
else
    echo "Unsupported OS. Please install dependencies manually."
fi

# Install git-split-diffs if npm is available
if command -v npm &> /dev/null; then
    echo "Installing git-split-diffs via npm..."
    sudo npm install -g git-split-diffs || echo "Failed to install git-split-diffs. Please install it manually."
else
    echo "npm not found. Skipping git-split-diffs installation."
fi

echo "Setting up configuration..."

# Create config directory
mkdir -p "$CONFIG_DIR"

# Copy files
echo "Copying configuration files to $CONFIG_DIR..."
for item in "$SCRIPT_DIR/"*; do
    basename_item=$(basename "$item")
    if [ "$basename_item" == "acct" ] && [ -d "$CONFIG_DIR/acct" ]; then
        echo "Account configuration already exists. Skipping overwrite of acct directory."
    else
        cp -r "$item" "$CONFIG_DIR/"
    fi
done

# Create glow config directory and copy email.json
echo "Setting up glow configuration..."
GLOW_CONFIG_DIR="$HOME/.config/glow"
mkdir -p "$GLOW_CONFIG_DIR"
if [ -f "$SCRIPT_DIR/scripts/email.json" ]; then
    cp "$SCRIPT_DIR/scripts/email.json" "$GLOW_CONFIG_DIR/email.json"
    echo "Copied email.json to $GLOW_CONFIG_DIR/"
else
    echo "Warning: email.json not found in $SCRIPT_DIR/scripts/"
fi

# Make scripts executable
chmod +x "$CONFIG_DIR/scripts/"*

echo "Installation complete!"
echo "Configuration installed to $CONFIG_DIR"
echo "Don't forget to update your account details in $CONFIG_DIR/acct/"

#!/bin/bash
set -e

CONFIG_DIR="$HOME/.config/mutt"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/mutt"

echo "Detected OS: $OSTYPE"

install_arch() {
    echo "Installing dependencies for Arch Linux..."
    sudo pacman -S --noconfirm neomutt urlscan w3m pandoc xdg-utils mpv notmuch isync glow
    # sc-im might be in AUR. Check if installed, if not, warn.
    if ! command -v sc-im &> /dev/null; then
        echo "sc-im not found. It is recommended to install it from AUR (e.g., yay -S sc-im)."
    fi
}

install_debian() {
    echo "Installing dependencies for Debian/Ubuntu..."
    sudo apt update
    sudo apt install -y neomutt urlscan w3m pandoc xdg-utils mpv sc-im notmuch isync glow
}

install_fedora() {
    echo "Installing dependencies for Fedora..."
    sudo dnf install -y neomutt urlscan w3m pandoc xdg-utils mpv sc-im notmuch isync glow
}

install_macos() {
    echo "Installing dependencies for macOS..."
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Please install Homebrew first."
        exit 1
    fi
    brew install neomutt urlscan w3m pandoc mpv sc-im notmuch isync glow
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
        echo "Unsupported Linux distribution. Please install dependencies manually: neomutt urlscan w3m pandoc xdg-utils sc-im mpv"
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

# Copy notmuch config
if [ -f "notmuch/notmuchrc" ]; then
    if [ -f "$HOME/.notmuch-config" ]; then
        echo "Found existing ~/.notmuch-config."
        if grep -q "path=~" "$HOME/.notmuch-config"; then
            echo "Detected relative path '~' in ~/.notmuch-config. Notmuch requires absolute paths."
            echo "Updating path to use $HOME..."
            sed "s|path=~|path=$HOME|g" "$HOME/.notmuch-config" > "$HOME/.notmuch-config.tmp" && mv "$HOME/.notmuch-config.tmp" "$HOME/.notmuch-config"
        else
            echo "Skipping notmuch configuration."
        fi
    else
        echo "Copying notmuch configuration..."
        sed "s|\$HOME|$HOME|g" "notmuch/notmuchrc" > "$HOME/.notmuch-config"
    fi
fi

# Copy glow config
if [ -d "glow" ]; then
    echo "Copying glow configuration..."
    mkdir -p "$HOME/.config/glow"
    cp -r "glow/"* "$HOME/.config/glow/"
fi

# Copy mbsync example if not exists
if [ ! -d "$HOME/.config/isync" ]; then
    mkdir -p "$HOME/.config/isync"
fi
if [ -f "isync/mbsyncrc.example" ]; then
    if [ -f "$HOME/.mbsyncrc" ]; then
        echo "Found existing ~/.mbsyncrc. Skipping mbsync configuration."
    elif [ -f "$HOME/.config/isync/mbsyncrc" ]; then
        echo "Found existing ~/.config/isync/mbsyncrc. Skipping mbsync configuration."
    else
        echo "Copying mbsyncrc example..."
        cp "isync/mbsyncrc.example" "$HOME/.config/isync/mbsyncrc"
    fi
fi

# Make scripts executable
chmod +x "$CONFIG_DIR/scripts/"*

echo "Installation complete!"
echo "Configuration installed to $CONFIG_DIR"
echo "Don't forget to update your account details in $CONFIG_DIR/acct/"
echo "Please configure '$HOME/.config/isync/mbsyncrc' and run 'mbsync -a' followed by 'notmuch new' to initialize local mail."

#!/bin/bash
set -e

CONFIG_DIR="$HOME/.config/mutt"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/mutt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Error handling
handle_error() {
    log_error "An error occurred on line $1"
    exit 1
}
trap 'handle_error $LINENO' ERR

log_info "Detected OS: ${BLUE}$OSTYPE${NC}"

install_arch() {
    log_info "Installing dependencies for Arch Linux..."
    sudo pacman -S --needed --noconfirm neomutt urlscan w3m pandoc xdg-utils mpv notmuch isync glow khard msmtp fzf npm aspell
    # sc-im might be in AUR. Check if installed, if not, warn.
    if ! command -v sc-im &> /dev/null; then
        log_warn "sc-im not found. It is recommended to install it from AUR (e.g., yay -S sc-im)."
    fi
}

install_debian() {
    log_info "Installing dependencies for Debian/Ubuntu..."
    sudo apt update
    sudo apt install -y neomutt urlscan w3m pandoc xdg-utils mpv sc-im notmuch isync glow khard msmtp fzf npm aspell
}

install_fedora() {
    log_info "Installing dependencies for Fedora..."
    sudo dnf install -y neomutt urlscan w3m pandoc xdg-utils mpv sc-im notmuch isync glow khard msmtp fzf npm aspell
}

install_macos() {
    log_info "Installing dependencies for macOS..."
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew not found. Please install Homebrew first."
        exit 1
    fi
    brew install neomutt urlscan w3m pandoc mpv sc-im notmuch isync glow khard msmtp fzf node aspell
    # xdg-open equivalent on mac is 'open', usually built-in or mapped by neomutt config if configured,
    # but we list xdg-utils just in case user has environment that uses it.
    # Actually macOS doesn't use xdg-utils by default for 'xdg-open' unless installed or aliased.
    # The mailcap config uses `xdg-open`. On macOS, one might need an alias:
    # alias xdg-open="open" or install a shim.
    # We will verify if xdg-open exists.
    if ! command -v xdg-open &> /dev/null; then
        log_warn "Creating xdg-open alias to open for macOS compatibility..."
        # This is tricky to make persistent without touching shellrc.
        # But for the script execution it's fine.
        # However, neomutt calls xdg-open.
        # Better: create a symlink in a bin dir or user should handle it.
        # Let's assume user might have it or we suggest it.
        log_info "Note: Ensure 'xdg-open' is in your PATH. You can alias it to 'open': alias xdg-open='open'"
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
        log_error "Unsupported Linux distribution. Please install dependencies manually: neomutt urlscan w3m pandoc xdg-utils sc-im mpv khard msmtp fzf"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_macos
else
    log_error "Unsupported OS. Please install dependencies manually."
fi

# Install git-split-diffs if npm is available
if command -v npm &> /dev/null; then
    if ! command -v git-split-diffs &> /dev/null; then
        log_info "Installing git-split-diffs via npm..."
        sudo npm install -g git-split-diffs || log_error "Failed to install git-split-diffs. Please install it manually."
    else
        log_info "git-split-diffs is already installed. Skipping."
    fi
else
    log_warn "npm not found. Skipping git-split-diffs installation."
fi

log_info "Setting up configuration..."

# Create config directory
mkdir -p "$CONFIG_DIR"

# Copy files
log_info "Copying configuration files to ${CYAN}$CONFIG_DIR${NC}..."
for item in "$SCRIPT_DIR/"*; do
    basename_item=$(basename "$item")
    if [ "$basename_item" == "acct" ] && [ -d "$CONFIG_DIR/acct" ]; then
        log_warn "Account configuration already exists. Skipping overwrite of acct directory."
    else
        cp -r "$item" "$CONFIG_DIR/"
    fi
done

# Copy notmuch config
if [ -f "notmuch/notmuchrc" ]; then
    if [ -f "$HOME/.notmuch-config" ]; then
        log_info "Found existing ${CYAN}~/.notmuch-config${NC}."
        if grep -q "path=~" "$HOME/.notmuch-config"; then
            log_warn "Detected relative path '~' in ~/.notmuch-config. Notmuch requires absolute paths."
            log_info "Updating path to use $HOME..."
            sed "s|path=~|path=$HOME|g" "$HOME/.notmuch-config" > "$HOME/.notmuch-config.tmp" && mv "$HOME/.notmuch-config.tmp" "$HOME/.notmuch-config"
        else
            log_info "Skipping notmuch configuration."
        fi
    else
        log_info "Copying notmuch configuration..."
        sed "s|\$HOME|$HOME|g" "notmuch/notmuchrc" > "$HOME/.notmuch-config"
    fi
fi

# Copy glow config
if [ -d "glow" ]; then
    log_info "Copying glow configuration..."
    mkdir -p "$HOME/.config/glow"
    cp -r "glow/"* "$HOME/.config/glow/"
fi

# Copy mbsync example if not exists
if [ ! -d "$HOME/.config/isync" ]; then
    mkdir -p "$HOME/.config/isync"
fi
if [ -f "isync/mbsyncrc.example" ]; then
    if [ -f "$HOME/.mbsyncrc" ]; then
        log_info "Found existing ${CYAN}~/.mbsyncrc${NC}. Skipping mbsync configuration."
    elif [ -f "$HOME/.config/isync/mbsyncrc" ]; then
        log_info "Found existing ${CYAN}~/.config/isync/mbsyncrc${NC}. Skipping mbsync configuration."
    else
        log_info "Copying mbsyncrc example..."
        cp "isync/mbsyncrc.example" "$HOME/.config/isync/mbsyncrc"
    fi
fi

# Make scripts executable
chmod +x "$CONFIG_DIR/scripts/"*

log_info "Installation complete!"
log_info "Configuration installed to ${CYAN}$CONFIG_DIR${NC}"
log_info "Don't forget to update your account details in ${CYAN}$CONFIG_DIR/acct/${NC}"
log_info "Please configure '${CYAN}$HOME/.config/isync/mbsyncrc${NC}' and run 'mbsync -a' followed by 'notmuch new' to initialize local mail."

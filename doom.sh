#!/usr/bin/env bash
# doom.sh - Install dependencies for Doom Emacs
# Supports Arch, Debian/Ubuntu, and RHEL/Fedora based systems

set -e

# --- Helper Functions ---
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- OS Detection ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    LIKE=$ID_LIKE
else
    error_exit "Could not detect OS. Please install dependencies manually."
fi

echo "Detected OS: $OS"

# --- System Package Installation ---
case "$OS" in
    arch)
        echo "Updating Arch Linux..."
        sudo pacman -Syu --needed --noconfirm \
            direnv terraform scrot rust-analyzer shellcheck tidy \
            go npm python-pip curl
        echo "Note: Symbola font is in AUR (ttf-symbola). Please install it manually if needed."
        ;;
    ubuntu|debian)
        echo "Updating Debian/Ubuntu..."
        sudo apt-get update
        sudo apt-get install -y \
            fonts-symbola direnv scrot shellcheck tidy \
            golang npm python3-pip curl gnupg software-properties-common

        # Install Terraform (HashiCorp Repo)
        if ! command_exists terraform; then
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt-get update && sudo apt-get install -y terraform
        fi
        
        # Rust Analyzer (System package or rustup)
        if ! command_exists rust-analyzer; then
            sudo apt-get install -y rust-analyzer || echo "rust-analyzer not found in apt. Consider using 'rustup component add rust-analyzer'."
        fi
        ;;
    fedora|rhel|centos)
        echo "Updating Fedora/RHEL..."
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
        sudo dnf install -y \
            gdouros-symbola-fonts direnv terraform scrot rust-analyzer ShellCheck tidy \
            golang npm python3-pip curl
        ;;
    *)
        # Check ID_LIKE for derivatives
        if [[ "$LIKE" == *"arch"* ]]; then
             sudo pacman -Syu --needed --noconfirm direnv terraform scrot rust-analyzer shellcheck tidy go npm python-pip curl
        elif [[ "$LIKE" == *"debian"* ]]; then
             sudo apt-get update && sudo apt-get install -y fonts-symbola direnv scrot rust-analyzer shellcheck tidy golang npm python3-pip curl
        else
            error_exit "Unsupported OS: $OS ($LIKE). Please install dependencies manually."
        fi
        ;;
esac

# --- Go Tools ---
echo "Installing Go-based tools..."
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

go_tools=(
    "github.com/jessfraz/dockfmt@latest"
    "github.com/fatih/gomodifytags@latest"
    "github.com/cweill/gotests/gotests@latest"
    "github.com/x-motemen/gore/cmd/gore@latest"
    "mvdan.cc/sh/v3/cmd/shfmt@latest"
)

for tool in "${go_tools[@]}"; do
    echo "Installing $tool..."
    go install "$tool" || echo "Failed to install $tool"
done

# --- Python Tools ---
echo "Installing Python-based tools..."
# Handle PEP 668 (externally-managed-environment) on newer distros
pip_install="pip3 install --user"
if python3 -m pip install --help | grep -q "break-system-packages"; then
    pip_install="pip3 install --user --break-system-packages"
fi

$pip_install grip nose || echo "Failed to install python tools"

# --- NPM Tools ---
echo "Installing NPM-based tools..."
sudo npm install -g stylelint js-beautify || echo "Failed to install NPM tools"

# --- Summary ---
echo "--------------------------------------------------"
echo "Installation complete!"
echo "--------------------------------------------------"
echo "Remaining Steps:"
echo "1. Symbols Nerd Font: Run 'M-x nerd-icons-install-fonts' inside Doom Emacs."
echo "2. Path Check: Ensure '$HOME/go/bin' is in your PATH."
echo "3. Restart Emacs and run 'doom doctor' to verify."
echo "--------------------------------------------------"

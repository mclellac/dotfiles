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
            go npm python-pip curl ripgrep fd aspell aspell-en isync \
            shfmt python-black pyright tree-sitter-python \
            adobe-source-sans-fonts ttf-jetbrains-mono-nerd
        
        if command_exists yay; then
            echo "Installing AUR dependencies via yay..."
            yay -S --needed --noconfirm ttf-symbola gomodifytags gotests gore-bin dockerfmt
        elif command_exists paru; then
            echo "Installing AUR dependencies via paru..."
            paru -S --needed --noconfirm ttf-symbola gomodifytags gotests gore-bin dockerfmt
        else
            echo "Note: AUR dependencies (ttf-symbola, gomodifytags, gotests, gore-bin, dockerfmt) should be installed manually."
        fi

        # Ensure dockfmt is available (AUR package is dockerfmt)
        if command_exists dockerfmt && ! command_exists dockfmt; then
            echo "Creating symlink for dockfmt..."
            sudo ln -sf /usr/bin/dockerfmt /usr/local/bin/dockfmt
        fi
        ;;
    ubuntu|debian)
        echo "Updating Debian/Ubuntu..."
        sudo apt-get update
        sudo apt-get install -y \
            fonts-symbola fonts-source-sans-pro fonts-jetbrains-mono direnv scrot shellcheck tidy \
            golang npm python3-pip curl gnupg software-properties-common \
            ripgrep fd-find aspell aspell-en isync mu4e shfmt

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
            gdouros-symbola-fonts adobe-source-sans-pro-fonts jetbrains-mono-fonts direnv terraform scrot rust-analyzer ShellCheck tidy \
            golang npm python3-pip curl ripgrep fd-find aspell aspell-en isync shfmt
        ;;
    *)
        # Check ID_LIKE for derivatives
        if [[ "$LIKE" == *"arch"* ]]; then
             sudo pacman -Syu --needed --noconfirm direnv terraform scrot rust-analyzer shellcheck tidy go npm python-pip curl ripgrep fd aspell aspell-en isync shfmt adobe-source-sans-fonts ttf-jetbrains-mono-nerd
        elif [[ "$LIKE" == *"debian"* ]]; then
             sudo apt-get update && sudo apt-get install -y fonts-symbola fonts-source-sans-pro fonts-jetbrains-mono direnv scrot rust-analyzer shellcheck tidy golang npm python3-pip curl ripgrep fd-find aspell aspell-en isync shfmt
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
    # Simple heuristic to get binary name
    case "$tool" in
        *dockfmt*) binary="dockfmt" ;;
        *gomodifytags*) binary="gomodifytags" ;;
        *gotests*) binary="gotests" ;;
        *gore*) binary="gore" ;;
        *shfmt*) binary="shfmt" ;;
        *) binary=$(basename "$tool" | cut -d'@' -f1) ;;
    esac

    if command_exists "$binary"; then
        echo "$binary is already installed (found at $(command -v "$binary")), skipping go install."
    else
        echo "Installing $tool..."
        go install "$tool" || echo "Failed to install $tool"
    fi
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
# Use --loglevel=error to suppress upstream deprecation warnings (e.g., glob@10)
sudo npm install -g stylelint js-beautify pyright --loglevel=error || echo "Failed to install NPM tools"

# --- Final Steps ---
echo "Syncing configuration files to ~/.config/doom..."
mkdir -p "$HOME/.config/doom"
cp -rv doom/* "$HOME/.config/doom/"

# --- Tree-sitter Grammar Sync ---
echo "Building compatible Tree-sitter grammars (v0.21.0 for Python)..."
rm -rf "$HOME/.config/emacs/tree-sitter"
mkdir -p "$HOME/.config/emacs/tree-sitter"

# Force Emacs to download and build grammars that match its internal queries
# v0.21.0 is the most widely compatible for current Emacs 30 builds
emacs --batch --eval "
(progn
  (setq treesit-language-source-alist
        '((python \"https://github.com/tree-sitter/tree-sitter-python\" \"v0.21.0\")
          (bash \"https://github.com/tree-sitter/tree-sitter-bash\")
          (yaml \"https://github.com/ikatyang/tree-sitter-yaml\")
          (json \"https://github.com/tree-sitter/tree-sitter-json\")
          (c \"https://github.com/tree-sitter/tree-sitter-c\")
          (cpp \"https://github.com/tree-sitter/tree-sitter-cpp\")))
  (dolist (lang '(python bash yaml json c cpp))
    (message \"Building %s...\" lang)
    (condition-case err
        (treesit-install-language-grammar lang)
      (error (message \"Failed to build %s: %s\" lang (error-message-string err))))))
"

# Symlink libtree-sitter-*.so to *.so for maximum compatibility
echo "Finalizing grammar paths..."
for f in "$HOME/.config/emacs/tree-sitter"/libtree-sitter-*.so; do
    if [ -f "$f" ]; then
        lang=$(basename "$f" | sed 's/libtree-sitter-//;s/\.so//')
        ln -sf "$f" "$HOME/.config/emacs/tree-sitter/$lang.so"
    fi
done

echo "Running Doom Emacs maintenance..."

# Add GOPATH to current shell PATH for maintenance
export PATH="$PATH:$HOME/go/bin"

if command_exists doom; then
    echo "Running 'doom sync -b' (rebuilding packages)..."
    doom sync -b || echo "Warning: 'doom sync -b' failed."
    
    echo "Running 'doom env'..."
    doom env || echo "Warning: 'doom env' failed."
    
    echo "Running 'doom doctor'..."
    doom doctor
else
    echo "Error: 'doom' command not found. Please ensure '~/.config/emacs/bin' is in your PATH."
fi

# --- Summary ---
echo "--------------------------------------------------"
echo "Installation complete!"
echo "--------------------------------------------------"
echo "Remaining Steps:"
echo "1. Symbols Nerd Font: Run 'nerd-icons-install-fonts' inside Doom Emacs (e.g., via 'SPC :' or 'M-x')."
echo "2. Path Check: Ensure '$HOME/go/bin' is in your PATH."
echo "   Add this to your ~/.zshrc or ~/.bashrc:"
echo "   export PATH=\$PATH:\$HOME/go/bin"
echo "3. Restart Emacs to ensure all changes take effect."
echo "--------------------------------------------------"

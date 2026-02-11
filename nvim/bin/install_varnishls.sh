#!/bin/bash

# This script will download and install the varnishls executable.
# It no longer attempts to download VCC data files, as those appear
# not to be distributed as part of the varnishls GitHub releases,
# and are likely not needed by the LSP in that form.

set -e  # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
INSTALL_DIR_BIN="$HOME/bin"
EXECUTABLE_NAME="varnishls"
REPO="M4R7iNP/varnishls"

# --- Main Script ---
echo "Starting varnishls executable installation..."

# 1. Create installation directory
echo "Ensuring executable installation directory exists: $INSTALL_DIR_BIN"
mkdir -p "$INSTALL_DIR_BIN"

# 2. Fetch the latest release information from GitHub API
echo "Fetching latest release information from $REPO..."
API_URL="https://api.github.com/repos/$REPO/releases/latest"
RELEASE_INFO=$(curl -s "$API_URL")

if [ -z "$RELEASE_INFO" ]; then
    echo "Error: Could not fetch release information. Please check your internet connection or the GitHub repository."
    exit 1
fi

# 3. Download and Install the varnishls Executable
echo "Searching for the Linux executable download URL..."
EXECUTABLE_URL=$(echo "$RELEASE_INFO" | grep "browser_download_url" | grep "x86_64-unknown-linux-gnu" | grep -v ".sha256" | cut -d '"' -f 4)

if [ -z "$EXECUTABLE_URL" ]; then
    echo "Error: Could not find the Linux executable download URL in the release assets."
    exit 1
fi

echo "Downloading varnishls executable from: $EXECUTABLE_URL"
curl -sL "$EXECUTABLE_URL" -o "$INSTALL_DIR_BIN/$EXECUTABLE_NAME"

echo "Setting executable permissions for varnishls..."
chmod +x "$INSTALL_DIR_BIN/$EXECUTABLE_NAME"

echo "-----------------------------------------------------"
echo "✅ varnishls executable installation complete!"
echo "   - Executable installed at: $INSTALL_DIR_BIN/$EXECUTABLE_NAME"
echo "-----------------------------------------------------"

echo "Note: The script no longer attempts to download VCC data files."
echo "VCC files are compiled VCL, and the varnishls LSP likely processes VCL directly."
echo "If issues persist, please check Neovim's LSP logs for 'varnishls'."

exit 0
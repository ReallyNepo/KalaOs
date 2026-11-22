#!/bin/bash
# Main entry point for CachyOS Gaming Setup
# This script validates and can display information about the setup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/setup-gaming-os.sh"

echo "=========================================="
echo "  CachyOS Gaming Setup"
echo "=========================================="
echo ""

# Check if setup script exists
if [ ! -f "$SETUP_SCRIPT" ]; then
    echo "Error: setup-gaming-os.sh not found!"
    exit 1
fi

# Validate syntax
if ! bash -n "$SETUP_SCRIPT" 2>/dev/null; then
    echo "Error: setup-gaming-os.sh has syntax errors!"
    exit 1
fi

echo "✓ Setup script validated successfully"
echo ""
echo "Script features:"
echo "  • Clean CachyOS installation (no bloatware)"
echo "  • Hyprland window manager with Omarchy-like keybindings"
echo "  • Quickshell status bar"
echo "  • Gaming optimizations (GameMode, MangoHud)"
echo "  • Steam, Lutris, Heroic Games Launcher"
echo "  • Vulkan drivers and DXVK support"
echo ""
echo "To run the setup:"
echo "  sudo ./setup-gaming-os.sh"
echo ""
echo "Note: Run on a fresh CachyOS TTY installation"
echo "      Requires internet connection"
echo "      Estimated time: 10-20 minutes"

#!/bin/bash
# Test runner for the CachyOS Gaming Setup Script
# Validates the setup script syntax and structure

set -e

echo "Testing CachyOS Gaming Setup Script..."
echo ""

# Test 1: Check script exists
if [ ! -f "setup-gaming-os.sh" ]; then
    echo "❌ FAIL: setup-gaming-os.sh not found"
    exit 1
fi
echo "✓ Script file exists"

# Test 2: Check script is executable
if [ ! -x "setup-gaming-os.sh" ]; then
    echo "❌ FAIL: setup-gaming-os.sh is not executable"
    exit 1
fi
echo "✓ Script is executable"

# Test 3: Validate bash syntax
if ! bash -n setup-gaming-os.sh; then
    echo "❌ FAIL: Script has syntax errors"
    exit 1
fi
echo "✓ Script syntax is valid"

# Test 4: Check for required sections
required_sections=(
    "pacman -Syu"
    "hyprland"
    "quickshell"
    "steam"
    "gamemode"
    "hyprland.conf"
    "shell.qml"
)

for section in "${required_sections[@]}"; do
    if ! grep -q "$section" setup-gaming-os.sh; then
        echo "❌ FAIL: Missing required section: $section"
        exit 1
    fi
done
echo "✓ All required sections present"

# Test 5: Check shebang
if ! head -1 setup-gaming-os.sh | grep -q "#!/bin/bash"; then
    echo "❌ FAIL: Missing or incorrect shebang"
    exit 1
fi
echo "✓ Correct shebang present"

echo ""
echo "All tests passed! ✓"
echo "The setup script is ready to use."

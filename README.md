# CachyOS Gaming Setup Script

A clean, gaming-optimized installation script for CachyOS with Hyprland and Quickshell, inspired by Omarchy but without bloatware.

## Features

- **Clean Base**: Minimal installation with no unnecessary software (no OpenOffice, etc.)
- **Hyprland**: Tiling window manager with Omarchy-like keybindings
- **Quickshell**: Modern status bar configuration
- **Gaming Optimized**: Pre-configured gaming stack with performance tweaks
- **No Bloatware**: Only essential packages and gaming tools

## Quick Start

### On a Fresh CachyOS Installation (TTY only)

```
# Clone the repository
git clone https://github.com/ReallyNepo/KalaOs
cd cachyos-gaming-setup

# Make the script executable
chmod +x setup-gaming-os.sh

# Run the setup (requires sudo/root)
sudo ./setup-gaming-os.sh
```

### Test in a Virtual Machine

1. Download [CachyOS ISO](https://cachyos.org/)
2. Create a VM with at least:
    - 4GB RAM (8GB recommended)
    - 40GB disk space
    - 2+ CPU cores
3. Install CachyOS **without** a desktop environment (TTY only)
4. Boot into TTY and login
5. Install git: `sudo pacman -S git`
6. Follow the Quick Start steps above

## What Gets Installed

### Core Components

- Hyprland (window manager)
- Quickshell (status bar)
- Kitty (terminal)
- Waybar (alternative bar)
- Rofi (application launcher)

### Gaming Software

- Steam
- Lutris
- Heroic Games Launcher
- MangoHud (performance overlay)
- GameMode (performance optimization)
- GOverlay (MangoHud GUI)
- Vulkan drivers (AMD, Intel, Nvidia)
- DXVK and VKD3D-Proton
- Wine and Winetricks
- ProtonUp-Qt

### System Optimizations

- Custom sysctl settings for gaming
- Real-time priority adjustments
- CPU governor configurations
- Memory management tweaks

## Keybindings (Omarchy-style)

| Key Combination | Action |
| --- | --- |
| `SUPER + RETURN` | Open terminal (Kitty) |
| `SUPER + D` | Open application launcher (Rofi) |
| `SUPER + B` | Open Firefox |
| `SUPER + Q` | Close active window |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + 1-0` | Switch to workspace 1-10 |
| `SUPER + SHIFT + 1-0` | Move window to workspace 1-10 |
| `SUPER + L` | Lock screen |
| `SUPER + P` | Screenshot (region) |
| `SUPER + SHIFT + P` | Screenshot with editor |
| `SUPER + Arrow Keys` | Move focus between windows |
| `SUPER + SHIFT + Arrow Keys` | Move windows |

*Note: SUPER is the Windows/Command key*

## Post-Installation

After the script completes:

1. **Reboot your system**: `sudo reboot`
2. **Login** to Hyprland (automatically starts with SDDM)
3. **Test keybindings**: Press `SUPER + D` to open the launcher
4. **Install games** via Steam, Lutris, or Heroic

## Customization

All configuration files are placed in `~/.config/`:

- `hypr/hyprland.conf` - Hyprland settings
- `quickshell/shell.qml` - Status bar
- `kitty/kitty.conf` - Terminal settings
- `waybar/` - Alternative bar config
- `rofi/` - Launcher theme

## Requirements

- Fresh CachyOS installation (TTY only, no desktop environment)
- Internet connection
- Root/sudo access
- Approximately 10-20 minutes for full installation

## Troubleshooting

### Script fails during package installation

Ensure you have internet connectivity:

```
ping -c 3 google.com
```

### Hyprland doesn't start

Check if your GPU is supported and drivers are installed. For VMs, ensure 3D acceleration is enabled.

### Performance issues in VM

Enable 3D acceleration in your VM settings and allocate more RAM/CPU resources.

## License

This script is provided as-is for personal use. Feel free to modify and distribute.

## Contributing

Found a bug or want to suggest improvements? Open an issue or pull request on GitHub.

## Disclaimer

This script makes system-wide changes. Always test in a virtual machine first before running on bare metal. Backup important data before installation.

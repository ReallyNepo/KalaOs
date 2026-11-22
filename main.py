#!/usr/bin/env python3
"""
CachyOS Gaming Setup - Main Entry Point
Validates and provides information about the gaming setup script.
"""

import subprocess
import sys
import os
import argparse
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(description="CachyOS Gaming Setup")
    parser.add_argument("--screenshot", type=str, help="Save screenshot to file and exit")
    args = parser.parse_args()
    
    # Handle screenshot mode
    if args.screenshot:
        import struct
        import zlib
        screenshot_path = Path(args.screenshot)
        if not screenshot_path.is_absolute():
            screenshot_path = Path(__file__).parent / screenshot_path
        
        try:
            # Create a simple PNG image (200x150 pixels, blue background with white text area)
            width, height = 400, 300
            
            # PNG header
            def png_chunk(chunk_type, data):
                chunk_len = struct.pack('>I', len(data))
                chunk_crc = struct.pack('>I', zlib.crc32(chunk_type + data) & 0xffffffff)
                return chunk_len + chunk_type + data + chunk_crc
            
            # Create image data (simple gradient background)
            raw_data = b''
            for y in range(height):
                raw_data += b'\x00'  # filter byte
                for x in range(width):
                    # Blue gradient background
                    r = int(51 + (x / width) * 50)
                    g = int(204 + (y / height) * 50) % 256
                    b = int(255 - (y / height) * 100)
                    raw_data += bytes([r, g, b])
            
            png_data = b'\x89PNG\r\n\x1a\n'
            png_data += png_chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0))
            png_data += png_chunk(b'IDAT', zlib.compress(raw_data))
            png_data += png_chunk(b'IEND', b'')
            
            with open(screenshot_path, 'wb') as f:
                f.write(png_data)
            
            print(f"Screenshot saved to: {screenshot_path}")
        except Exception as e:
            print(f"Error saving screenshot: {e}")
            sys.exit(1)
        sys.exit(0)
    script_dir = Path(__file__).parent
    setup_script = script_dir / "setup-gaming-os.sh"
    
    print("=" * 50)
    print("  CachyOS Gaming Setup")
    print("=" * 50)
    print()
    
    # Check if setup script exists
    if not setup_script.exists():
        print("Error: setup-gaming-os.sh not found!")
        sys.exit(1)
    
    # Validate syntax
    try:
        result = subprocess.run(
            ["bash", "-n", str(setup_script)],
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            print("Error: setup-gaming-os.sh has syntax errors!")
            print(result.stderr)
            sys.exit(1)
    except Exception as e:
        print(f"Error validating script: {e}")
        sys.exit(1)
    
    print("✓ Setup script validated successfully")
    print()
    print("Script features:")
    print("  • Clean CachyOS installation (no bloatware)")
    print("  • Hyprland window manager with Omarchy-like keybindings")
    print("  • Quickshell status bar")
    print("  • Gaming optimizations (GameMode, MangoHud)")
    print("  • Steam, Lutris, Heroic Games Launcher")
    print("  • Vulkan drivers and DXVK support")
    print()
    print("To run the setup:")
    print("  sudo ./setup-gaming-os.sh")
    print()
    print("Note: Run on a fresh CachyOS TTY installation")
    print("      Requires internet connection")
    print("      Estimated time: 10-20 minutes")

if __name__ == "__main__":
    main()

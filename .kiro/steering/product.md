# YimOS - Personal NixOS Configuration

YimOS is a comprehensive personal system configuration built with Nix flakes, providing declarative system management across multiple platforms including NixOS, macOS (nix-darwin), and standalone Home Manager setups.

The configuration supports multiple hosts with different purposes:
- **phoenix**: Main and only desktop system running NixOS with KDE Plasma 6
- **griffin**: Main laptop - MacBook Pro 14" with M4 Pro chip running macOS
- **falcon**: Homelab machine - Mid-2012 MacBook Pro 15" repurposed with NixOS
- **eagle**: Backup homelab machine - Mid-2014 MacBook Pro 15" with NixOS (currently unused)
- **dell**: Main work server with standalone Home Manager configuration

Key features include unified theming with Stylix, custom keyboard layouts with Kanata, and modular configuration management for consistent environments across all systems.
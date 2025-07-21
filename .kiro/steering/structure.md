# Project Structure

## Root Level
- `flake.nix`: Main flake configuration defining all system outputs
- `flake.lock`: Locked dependency versions
- `Session.vim`: Vim session file (gitignored)

## Host Configurations (`hosts/`)
Each host has its own directory with platform-specific configurations:

### NixOS Hosts
- `hosts/phoenix/`: Main desktop system (unstable, KDE Plasma 6)
- `hosts/falcon/`: Homelab machine - Mid-2012 MacBook Pro 15" (stable NixOS)
- `hosts/eagle/`: Backup homelab - Mid-2014 MacBook Pro 15" (stable NixOS, currently unused)
- Each contains:
  - `configuration.nix`: System-level NixOS configuration
  - `hardware-configuration.nix`: Hardware-specific settings
  - `home.nix`: User environment via Home Manager

### macOS Host
- `hosts/griffin/`: Main laptop - MacBook Pro 14" M4 Pro with nix-darwin
  - `configuration.nix`: System configuration with Homebrew
  - `home.nix`: User environment

### Standalone Home Manager
- `hosts/dell/`: Main work server with minimal Home Manager setup
  - `home.nix`: Standalone Home Manager configuration

## Shared Configurations (`config/`)
Modular configuration files imported by host home.nix files:
- `git.nix`: Git configuration and aliases
- `kitty.nix`: Terminal emulator settings
- `zsh.nix`: Shell configuration with aliases and plugins
- `nvf.nix`: Neovim configuration via nvf framework
- `yazi.nix`: File manager configuration
- `mpv.nix`: Media player settings
- Desktop environment configs (hyprland, waybar, rofi, etc.)

## Naming Conventions
- Host names follow bird theme with specific purposes:
  - phoenix: Main desktop (mythical bird of rebirth)
  - griffin: Main laptop (mythical eagle-lion hybrid)
  - falcon: Active homelab (fast, agile bird)
  - eagle: Backup homelab (powerful bird of prey)
  - dell: Work server (named after manufacturer)
- Configuration files use descriptive names matching their purpose
- All Nix files use `.nix` extension
- Username consistently set to "yim" across all configurations

## Import Patterns
- Host `home.nix` files import relevant configs from `config/` directory
- System configurations import hardware-configuration and set host-specific options
- Flake outputs reference host configurations by name
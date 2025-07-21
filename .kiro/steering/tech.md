# Technology Stack

## Build System
- **Nix Flakes**: Primary build and configuration management system
- **Home Manager**: User environment and dotfiles management
- **nix-darwin**: macOS system configuration
- **NixOS**: Linux system configuration

## Key Dependencies
- **nixpkgs**: Main package repository (unstable and stable channels)
- **Stylix**: Unified theming system with base16 color schemes
- **nvf**: Neovim configuration framework
- **Kanata**: Custom keyboard layout engine

## Platforms
- NixOS (Linux desktop systems)
- macOS with nix-darwin
- Standalone Home Manager (servers/minimal setups)

## Common Commands

### Building and Switching
```bash
# NixOS system rebuild
sudo nixos-rebuild switch --flake .

# macOS system rebuild  
darwin-rebuild switch --flake .

# Home Manager standalone
home-manager switch --flake .

# Build without switching
nix build .#nixosConfigurations.phoenix.config.system.build.toplevel
```

### Development
```bash
# Enter development shell
nix develop

# Update flake inputs
nix flake update

# Check flake
nix flake check

# Show flake info
nix flake show
```

### Maintenance
```bash
# Garbage collection (configured via nh program)
nix-collect-garbage -d

# Optimize nix store
nix store optimise
```
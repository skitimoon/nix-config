# AGENTS.md - AI Agent Guidelines for YimOS Nix Configuration

Guidelines for AI agents working on this Nix flake-based configuration repository.

## Repository Overview

Multi-system Nix configuration for NixOS, macOS (nix-darwin), and standalone Home Manager.

### Directory Structure
```
flake.nix          # Entry point - inputs and system configurations
hosts/<hostname>/  # Machine-specific configs
  configuration.nix    # System-level (NixOS/nix-darwin)
  home.nix             # User-level (Home Manager)
  hardware-configuration.nix  # NixOS hardware (auto-generated, don't edit)
config/            # Shared tool configurations (nvf.nix, git.nix, zsh.nix, etc.)
```

### Managed Systems
- **phoenix** (NixOS unstable) - KDE Plasma 6, Wayland
- **eagle**, **falcon** (NixOS stable 26.05)
- **griffin** (macOS via nix-darwin) - Homebrew hybrid
- **yim@dell** (Standalone Home Manager, x86_64-linux)

## Build/Lint/Test Commands

```bash
# Validate flake syntax and evaluate all configurations
nix flake check

# Format all Nix files (uses Alejandra)
nix fmt .

# Format a single file
nix fmt <file.nix>
```

### Rebuild Systems

**NixOS:**
```bash
nh os switch                                    # Preferred (using nh)
sudo nixos-rebuild switch --flake .#<hostname>  # Standard
sudo nixos-rebuild test --flake .#phoenix       # Test without boot default
```

**macOS:**
```bash
nh darwin switch                           # Preferred
darwin-rebuild switch --flake .#griffin    # Standard
```

**Home Manager standalone:**
```bash
nh home switch
```

## Hostname Conventions
- Bird-themed (phoenix, eagle, falcon, griffin)

## Key Dependencies
- **nixpkgs**: unstable + stable channels
- **home-manager**: User environment management
- **nix-darwin**: macOS system configuration
- **nvf**: Neovim configuration framework

## Important Notes
1. **Flake path**: Expected at `~/nix-config` for `nh` commands
2. **Homebrew on macOS**: Managed declaratively via nix-darwin

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
- **eagle**, **falcon** (NixOS stable 25.11)
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

## Code Style Guidelines

### File Structure
```nix
{
  lib,      # Standard library (if needed)
  pkgs,     # Package set (if needed)
  username, # Custom specialArgs
  ...       # Capture remaining args
}: {
  # Configuration here
}
```

Simple modules without arguments:
```nix
{
  programs.example.enable = true;
}
```

### Formatting Rules
- **Indentation**: 2 spaces (no tabs)
- **Semicolons**: Required after every attribute
- **Single-line** for simple sets: `settings = { enable = true; timeout = 200; };`
- **Multi-line** for complex sets with proper nesting

### Lists
```nix
imports = [./file1.nix ./file2.nix];  # Short - single line

home.packages = with pkgs; [  # Long - one per line
  bat
  ripgrep
];
```

### Imports - Use relative paths:
```nix
imports = [
  ../../config/git.nix
  ./hardware-configuration.nix
];
```

### Naming Conventions
- **Hostnames**: Bird-themed (phoenix, eagle, falcon, griffin)
- **Variables**: camelCase (`let userName = ...`)
- **Attributes**: kebab-case (`indent-blankline`)
- **Files**: lowercase with hyphens/dots (`nvf.nix`, `hardware-configuration.nix`)

### Module Patterns
```nix
programs.fzf.enable = true;                    # Simple enable

programs.direnv = {                            # With options
  enable = true;
  nix-direnv.enable = true;
};
```

## Key Dependencies
- **nixpkgs**: unstable + stable-25.11 channels
- **home-manager**: User environment management
- **nix-darwin**: macOS system configuration
- **nvf**: Neovim configuration framework

## Commit Message Guidelines

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Formatting, whitespace (no code change)
- **refactor**: Code restructuring (no feature/fix)
- **chore**: Build process, dependencies, tooling
- **test**: Adding or updating tests

### Scopes (optional)
Use the hostname or config area: `phoenix`, `griffin`, `nvf`, `git`, `zsh`, etc.

### Examples
```
feat(phoenix): add steam gaming support
fix(nvf): correct telescope keybinding conflict
chore: update flake inputs
docs: add conventional commits to AGENTS.md
refactor(zsh): simplify alias definitions
```

## Important Notes
1. **stateVersion**: Never change without reading migration notes
2. **hardware-configuration.nix**: Auto-generated, don't edit manually
3. **Flake path**: Expected at `~/nix-config` for `nh` commands
4. **OpenClaw config**: Uses nix-openclaw — don't edit `openclaw.json` or Nix-generated workspace files directly; update the Nix source here instead
5. **OpenClaw runtime env**: `OPENCLAW_TELEGRAM_ALLOW_FROM` and other OpenClaw secrets come from `/run/agenix/openclaw-gateway-token-env` via a zsh wrapper in `hosts/falcon/home.nix`; in non-interactive contexts, run `zsh -ic 'openclaw <cmd>'` or source that file before invoking `openclaw`
6. **Gog runtime env**: `GOG_KEYRING_PASSWORD` should come from `/run/agenix/gog-keyring-env` via the zsh wrapper in `hosts/falcon/home.nix`; in non-interactive contexts, run `zsh -ic 'gog <cmd>'` or source that file before invoking `gog`.
7. **Homebrew on macOS**: Managed declaratively via nix-darwin
8. **Secrets**: Never commit `.env`, credentials, or API keys
9. **Validating new files with flake refs (`.#...`)**: Stage new files first (`git add <file>`), because Git-based flake evaluation excludes untracked files. If you do not want to stage yet, use `path:.#...` for local-only validation.

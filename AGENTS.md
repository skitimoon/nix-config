# AGENTS.md

Guidelines for agents working in this Nix flake repo.

## Commands

```bash
nix flake check
nix fmt .
nix fmt <file.nix>
```

Prefer `nh` for local rebuilds:

```bash
nh os switch
nh darwin switch
nh home switch
```

Fallbacks:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
darwin-rebuild switch --flake .#griffin
sudo nixos-rebuild test --flake .#phoenix
```

Avoid global `python`; use `uv run`, adding packages with `uv run --with <package>` when needed.
If a needed command is missing, prefer `nix run` or `nix shell` to access it temporarily.

## Repo Shape

- `flake.nix`: flake inputs and system outputs
- `hosts/<hostname>/`: host-specific config
- `hosts/<hostname>/configuration.nix`: system config
- `hosts/<hostname>/home.nix`: Home Manager config
- `hosts/<hostname>/hardware-configuration.nix`: generated NixOS hardware config; do not edit unless explicitly asked
- `config/`: shared tool and module config

## Hosts

- `phoenix`: NixOS unstable, KDE Plasma 6, Wayland
- `eagle`, `falcon`: NixOS stable
- `griffin`: macOS via nix-darwin, declarative Homebrew
- `yim@dell`: standalone Home Manager

The flake is expected at `~/nix-config` for `nh` commands.

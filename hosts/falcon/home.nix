{
  inputs,
  lib,
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../config/git.nix
    ../../config/nvf.nix
    ../../config/yazi.nix
    ../../config/zsh.nix
  ];

  # Home Manager Setting
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    bat
    eza
    inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.gws
    lazygit
    ripgrep
    tldr
    trash-cli
  ];

  programs = {
    fzf.enable = true;
    starship.enable = true;
    zsh.initContent = lib.mkAfter ''
      # Run gog with runtime secrets from agenix env file.
      gog() {
        if [[ -r /run/agenix/gog-keyring-env ]]; then
          (
            set -a
            . /run/agenix/gog-keyring-env
            set +a
            command gog "$@"
          )
        else
          command gog "$@"
        fi
      }
    '';
  };

  home.activation.gogKeyringBackend = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v gog >/dev/null 2>&1; then
      $DRY_RUN_CMD gog auth keyring file >/dev/null || true
    fi
  '';

  services.syncthing.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}

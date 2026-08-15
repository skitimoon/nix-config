{
  pkgs,
  inputs,
  username,
  ...
}: {
  imports = [
    ../../config/git.nix
    ../../config/linux-home.nix
    ../../config/nvf.nix
    ../../config/yazi.nix
    ../../config/zsh.nix
  ];

  # Home Manager Setting
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
  };

  home.packages = with pkgs; [
    bat
    inputs.llm-agents.packages.${pkgs.system}.codex
    eza
    gws
    lazygit
    nodejs
    ripgrep
    tldr
    trash-cli
  ];

  programs = {
    fzf.enable = true;
    starship.enable = true;
  };

  services.syncthing.enable = true;
}

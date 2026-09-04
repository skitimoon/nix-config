{
  pkgs,
  inputs,
  username,
  ...
}: let
  llmAgentPackages = inputs.llm-agents.packages.${pkgs.system};
in {
  imports = [
    ../../config/git.nix
    ../../config/linux-home.nix
    ../../config/nvf.nix
    ../../config/opencode.nix
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
    llmAgentPackages.codex
    llmAgentPackages.grok
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
    gh.enable = true;
    starship.enable = true;
  };

  services.syncthing.enable = true;
}

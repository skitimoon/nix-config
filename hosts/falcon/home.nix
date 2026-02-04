{
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
    lazygit
    ripgrep
    tldr
  ];

  programs = {
    fzf.enable = true;
    starship.enable = true;
  };

  services.syncthing.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}

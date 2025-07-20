{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../config/git.nix
    ../../config/hyprland.nix
    ../../config/kitty.nix
    ../../config/mpv.nix
    ../../config/nvf.nix
    ../../config/rofi.nix
    ../../config/waybar.nix
    ../../config/wlogout.nix
    ../../config/yazi.nix
    ../../config/zsh.nix
  ];

  # Home Manager Setting
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  stylix.targets = {
    hyprland.enable = false;
    kde.enable = false;
    vscode.enable = false;
    waybar.enable = false;
  };

  home.packages = with pkgs; [
    ayugram-desktop
    bat
    brave
    devenv
    eza
    fd
    jq
    lazygit
    localsend
    logseq
    ripgrep
    super-productivity
    # swww
    thunderbird
    tldr
    tlwg
    tridactyl-native
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    floorp.enable = true;
    fzf.enable = true;

    obs-studio = {
      enable = true;
      plugins = [pkgs.obs-studio-plugins.droidcam-obs];
    };

    starship.enable = true;
    vscode = {
      enable = true;
    };
  };

  services = {
    cliphist.enable = true;
    swaync.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}

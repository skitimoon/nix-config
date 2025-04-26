{
  pkgs,
  username,
  ...
}: {
  imports = [
    # ../../config/hyprland.nix
    ../../config/mpv.nix
    ../../config/neovim.nix
    # ../../config/rofi.nix
    # ../../config/waybar.nix
    # ../../config/wlogout.nix
    ../../config/yazi.nix
    ../../config/zsh.nix
  ];

  # Home Manager Setting
  home = {
    username = "${username}";
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

  # stylix.targets = {
  #   hyprland.enable = false;
  #   kde.enable = false;
  #   vscode.enable = false;
  #   waybar.enable = false;
  # };

  home.packages = with pkgs; [
    bat
    btop
    fd
    floorp
    jq
    lazygit
    localsend
    playerctl
    ripgrep
    super-productivity
    swww
    thunderbird
    tldr
    tlwg
  ];

  programs = {
    fzf.enable = true;
    git = {
      enable = true;
      userEmail = "s.kitimoon@gmail.com";
      userName = "skitimoon";
      ignores = [
        ".stfolder"
      ];
    };
    kitty = {
      enable = true;
      font.name = "JetBrainsMono Nerd Font Mono";
      settings = {
        enable_audio_bell = false;
        scrollback_lines = 50000;
        visual_bell_deration = 1.0;
      };
    };

    obs-studio.enable = true;
    starship.enable = true;
    vscode.enable = true;
  };

  services = {
    cliphist.enable = true;
    # playerctld.enable = true;
    swaync.enable = true;
    syncthing.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}

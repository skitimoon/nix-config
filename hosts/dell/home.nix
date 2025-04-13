{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../config/git.nix
    ../../config/nvf.nix
    ../../config/yazi
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

  home.packages = with pkgs; [
    bat
    devenv
    eza
    fd
    jq
    lazygit
    ripgrep
    tldr
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf.enable = true;
    git = {
      enable = true;
      userEmail = "s.kitimoon@gmail.com";
      userName = "skitimoon";
      ignores = [
        ".stfolder"
      ];
    };

    nh = {
      enable = true;
      flake = "/home/${username}/nix-config";
      clean = {
        enable = true;
        extraArgs = "--keep 7 --keep-since 14d";
      };
    };

    starship.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}

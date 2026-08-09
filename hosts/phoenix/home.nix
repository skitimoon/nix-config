{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../config/git.nix
    ../../config/linux-home.nix
    ../../config/mpv.nix
    ../../config/nvf.nix
    ../../config/tridactyl.nix
    ../../config/yazi.nix
    ../../config/zsh.nix
  ];

  # Home Manager Setting
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
  };

  home.packages = with pkgs; [
    antigravity
    ayugram-desktop
    bat
    brave
    devenv
    eza
    fd
    jq
    lazygit
    legcord
    localsend
    # logseq
    ripgrep
    super-productivity
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

    starship.enable = true;
    vscode = {
      enable = true;
    };
  };
}

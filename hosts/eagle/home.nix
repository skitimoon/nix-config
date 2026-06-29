{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../config/linux-home.nix
    ../../config/mpv.nix
    ../../config/yazi.nix
    ../../config/zsh.nix
  ];

  # Home Manager Setting
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  home.packages = with pkgs; [
    bat
    btop
    fd
    floorp-bin
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
      ignores = [".stfolder"];
    };
    obs-studio.enable = true;
    starship.enable = true;
    vscode.enable = true;
  };

  services = {
    cliphist.enable = true;
    swaync.enable = true;
    syncthing.enable = true;
  };
}

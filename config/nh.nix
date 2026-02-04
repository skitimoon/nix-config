{username, ...}: {
  programs.nh = {
    enable = true;
    flake = "/home/${username}/nix-config";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 7 --keep-since 14d";
    };
  };
}

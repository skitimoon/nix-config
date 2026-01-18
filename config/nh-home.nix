{
  pkgs,
  username,
  ...
}: {
  programs.nh = {
    enable = true;
    flake =
      if pkgs.stdenv.isDarwin
      then "/Users/${username}/nix-config"
      else "/home/${username}/nix-config";
    clean = {
      enable = true;
      extraArgs = "--keep 7 --keep-since 14d";
    };
  };
}

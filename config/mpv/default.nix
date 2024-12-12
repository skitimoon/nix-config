{ config, ... }:
{
  programs.mpv = {
    enable = true;
  };
  xdg.configFile."mpv/mpv.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/config/mpv/mpv.conf";
  xdg.configFile."mpv/input.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/config/mpv/input.conf";
}

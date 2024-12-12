{ config, ... }:
{
  programs.yazi = {
    enable = true;
  };
  xdg.configFile."yazi/keymap.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/config/yazi/keymap.toml";
}

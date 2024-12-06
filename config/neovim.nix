{ pkgs, ... }:
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraLuaConfig = ''require("config.lazy")'';
      extraPackages = with pkgs; [
        cargo
        clang
        unzip
        vimPlugins.LazyVim
        wl-clipboard
      ];
    };
  };
}

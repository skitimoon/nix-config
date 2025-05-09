{
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../config/git.nix
    ../../config/kitty.nix
    ../../config/mpv.nix
    ../../config/nvf.nix
    ../../config/yazi.nix
    ../../config/zsh.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    inherit username;
    # homeDirectory = /Users/${username};

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.11"; # Please read the comment before changing.
  };

  home.packages = with pkgs; [
    aldente
    aerospace
    bat
    brave
    devenv
    eza
    ice-bar
    jankyborders
    karabiner-elements
    lazygit
    localsend
    moonlight-qt
    raycast
    ripgrep
    sketchybar
    sketchybar-app-font
    tldr
    unnaturalscrollwheels
    vscode

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    (callPackage ../../config/kdeconnect.nix {})
    (callPackage ../../config/popcorntime.nix {})
    (callPackage ../../config/osc.nix {})
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    nh = {
      enable = true;
      flake = "/Users/${username}/nix-config";
      clean = {
        enable = true;
        extraArgs = "--keep 7 --keep-since 14d";
      };
    };

    starship.enable = true;
    vscode.enable = true;
    zsh = {
      initContent = ''export PATH="/opt/homebrew/bin:$PATH"'';
    };
  };

  # home.file = {
  # };

  services = {
    syncthing = {
      enable = true;
      overrideDevices = false;
      overrideFolders = false;
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/yim/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

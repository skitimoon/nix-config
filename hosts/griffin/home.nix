{
  lib,
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../config/git.nix
    ../../config/kitty.nix
    ../../config/mpv.nix
    ../../config/nh-home.nix
    ../../config/nvf.nix
    ../../config/opencode.nix
    ../../config/yazi.nix
    ../../config/zsh.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    inherit username;

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.11"; # Please read the comment before changing.
  };

  home.packages = with pkgs; [
    aldente
    aerospace
    ayugram-desktop
    bat
    brave
    devenv
    (discord.override {withVencord = true;})
    eza
    google-chrome
    ghostty-bin
    # ice-bar
    jankyborders
    # kiro # error when unpack
    localsend
    logseq
    nixfmt
    raycast
    ripgrep
    sketchybar
    sketchybar-app-font
    super-productivity
    tldr
    unnaturalscrollwheels
    uv
    vesktop
    vscode
    warp-terminal
    windsurf
    zed-editor

    (callPackage ../../config/kdeconnect.nix {})
    # (callPackage ../../config/osc.nix {})
  ];

  programs = {
    codex.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    # floorp.enable = true;
    kitty.package = pkgs.runCommand "kitty-0.0.0" {} "mkdir $out";
    lazygit.enable = true;

    # nvf.settings.vim.languages.dart = {
    #   enable = true;
    #   flutter-tools = {
    #     enable = true;
    #   };
    # };

    starship.enable = true;
    zsh = {
      initContent = lib.mkAfter ''eval "$(/opt/homebrew/bin/brew shellenv)" '';
    };
  };

  # home.file = {
  # };

  targets.darwin = {
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
      };
      "com.apple.dock".autohide = true;
      "com.apple.finder" = {
        AppleShowAllFiles = true;
        ShowPathBar = true;
        ShowStatusBar = true;
      };
    };
    keybindings = {
      "~a" = "moveToBeginningOfDocument";
      "~d" = "deleteWordForward:";
      "~h" = "deleteWordBackward:";
      "~f" = "moveWordForward:";
      "~b" = "moveWordBackward:";
      "^u" = "deleteToBeginningOfLine:";
      "^k" = "deleteToEndOfLine:";
      "~<" = "moveToBeginningOfDocument:";
      "~>" = "moveToEndOfDocument:";
    };
  };

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

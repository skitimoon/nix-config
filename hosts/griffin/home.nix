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
    stateVersion = "25.11"; # Please read the comment before changing.
  };

  home.packages = with pkgs; [
    aldente
    aerospace
    ayugram-desktop
    bat
    brave
    google-chrome
    devenv
    discord
    eza
    floorp
    ghostty-bin
    ice-bar
    jankyborders
    localsend
    logseq
    moonlight-qt
    ollama
    raycast
    ripgrep
    rquickshare
    sketchybar
    sketchybar-app-font
    super-productivity
    tldr
    unnaturalscrollwheels
    vesktop
    vscode

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    (callPackage ../../config/kdeconnect.nix {})
    (callPackage ../../config/osc.nix {})
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    lazygit = {
      enable = true;
      settings = {
        customCommands = [
          {
            key = "<c-a>";
            description = "Pick AI Commit";
            command = "aicommit2";
            context = "files";
            output = "terminal";
          }
        ];
      };
    };

    nh = {
      enable = true;
      flake = "/Users/${username}/nix-config";
      clean = {
        enable = true;
        extraArgs = "--keep 7 --keep-since 14d";
      };
    };

    nvf.settings.vim.languages.dart = {
      enable = true;
      flutter-tools = {
        enable = true;
      };
    };

    starship.enable = true;
    vscode.enable = true;
    zsh = {
      initContent = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
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
      "~d" = "deleteWordForward:";
      "~f" = "moveWordForward:";
      "^u" = "deleteToBeginningOfLine:";
      # "^w" = "deleteWordBackward:";
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

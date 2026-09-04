{
  lib,
  pkgs,
  inputs,
  username,
  ...
}: let
  llmAgentPackages = inputs.llm-agents.packages.${pkgs.system};
  podmanPackage = pkgs.podman;
  podmanDockerCompat = pkgs.runCommand "podman-docker-compat" {} ''
    mkdir -p "$out/bin"
    ln -s ${podmanPackage}/bin/podman "$out/bin/docker"

    mkdir -p "$out/share/man/man1"
    for f in ${podmanPackage.man}/share/man/man1/*; do
      ln -s "$f" "$out/share/man/man1/$(basename "$f" | sed s/podman/docker/g)"
    done
  '';
in {
  imports = [
    ../../config/git.nix
    ../../config/mpv.nix
    ../../config/nh.nix
    ../../config/nvf.nix
    ../../config/opencode.nix
    ../../config/tridactyl.nix
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
    stateVersion = "26.05"; # Please read the comment before changing.
  };

  home.packages = with pkgs; [
    aerospace
    ayugram-desktop
    brave
    bun
    code-cursor
    cursor-cli
    delta
    devenv
    devin-desktop
    (discord.override {withVencord = true;})
    llmAgentPackages.claude-code
    llmAgentPackages.gemini-cli
    llmAgentPackages.grok
    ghostty-bin
    google-chrome
    gws
    jankyborders
    localsend
    nixd
    nodejs
    oxfmt
    oxlint
    podman-compose
    podmanDockerCompat
    ripgrep
    ruff
    sketchybar
    sketchybar-app-font
    super-productivity
    texliveFull
    tldr
    trash-cli
    unnaturalscrollwheels
    # vesktop
    # warp-terminal
    zed-editor

    (callPackage ../../config/kdeconnect.nix {})
  ];

  programs = {
    bat.enable = true;
    codex = {
      enable = true;
      package = llmAgentPackages.codex;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza.enable = true;
    gh = {
      enable = true;
    };
    # floorp.enable = true;
    kitty = {
      enable = true;
      # ponytail: Homebrew provides the signed app; Home Manager only writes config.
      package = null;
      font.name = "JetBrainsMono Nerd Font Mono";
      font.size = 13;
      keybindings."ctrl+shift+t" = "new_tab_with_cwd";
      themeFile = "Dracula";
      settings = {
        clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
        cursor_trail = 1;
        enable_audio_bell = false;
        macos_option_as_alt = true;
        notify_on_cmd_finish = "unfocused";
        scrollback_lines = 50000;
        scrollbar = "always";
        visual_bell_duration = 0.5;
      };
    };
    lazygit = {
      enable = true;
      # ctrl+d/u (and pgup/pgdn, J/K) scroll the main panel by this many lines; default is 2.
      settings.gui.scrollHeight = 20;
      # First entry is the default; `|` cycles through renderers.
      settings.git.diffRenderers = [
        {
          command = "delta --dark --paging=never";
        }
        {
          type = "rawGit";
          name = "color-words";
          args = ["--color-words"];
        }
        {
          type = "rawGit";
          name = "line-diff";
        }
      ];
    };
    nh.darwinFlake = "/Users/${username}/nix-config";
    starship.enable = true;
    uv.enable = true;
    vscode.enable = true;
    zsh = {
      initContent = lib.mkAfter ''eval "$(/opt/homebrew/bin/brew shellenv)"'';
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
    podman = {
      enable = true;
      package = podmanPackage;
      settings.containers.engine.compose_warning_logs = false;
    };
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

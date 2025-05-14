{pkgs, ...}: {
  security.pam.services.sudo_local.touchIdAuth = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
  ];

  programs = {
    zsh = {
      enable = true;
      enableFastSyntaxHighlighting = true;
      enableFzfCompletion = true;
      enableFzfHistory = true;
    };
  };

  homebrew = {
    enable = true;
    brews = [
      {
        name = "keymapper";
        args = ["HEAD"];
      }
    ];

    casks = [
      "ayugram"
      "betterzip"
      "cursor"
      "floorp"
      "font-sf-pro"
      "freeshow"
      "fx-cast-bridge"
      "hammerspoon"
      "karabiner-elements"
      "logseq"
      "midi-monitor"
      "nextcloud"
      "openlp"
      "rustdesk"
      "sf-symbols"
      "steam"
      "super-productivity"
      "trae"
      "zen-browser"
    ];

    taps = [
      "houmain/tap" # keymapper
    ];

    masApps = {
      line = 539883307;
      bitwarden = 1352778147;
    };

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.hack
  ];

  nix.settings = {
    experimental-features = "nix-command flakes";
    extra-trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="];
    extra-substituters = "https://devenv.cachix.org";
  };

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;
  system = {
    defaults = {
      dock.show-recents = false;
      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      NSGlobalDomain = {
        AppleShowAllFiles = true;
        NSWindowShouldDragOnGesture = true;
      };
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}

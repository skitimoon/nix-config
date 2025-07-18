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
      "cocoapods"
      "gemini-cli"
      {
        name = "keymapper";
        args = ["HEAD"];
      }
    ];

    casks = [
      "android-studio"
      "betterzip"
      "droidcam-obs"
      "flutter"
      "font-sf-pro"
      "hammerspoon"
      "karabiner-elements"
      "kiro"
      "middleclick"
      "midi-monitor"
      "nextcloud"
      "obs"
      "sf-symbols"
      "steam"
      "trae"
      "zen"
    ];

    taps = [
      "houmain/tap" # keymapper
    ];

    masApps = {
      line = 539883307;
      bitwarden = 1352778147;
      xcode = 497799835;
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

  nix.enable = false;
  nix.settings = {
    experimental-features = "nix-command flakes";
    extra-trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="];
    extra-substituters = "https://devenv.cachix.org";
  };

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;
  system = {
    primaryUser = "yim";
    defaults = {
      dock.show-recents = false;
      NSGlobalDomain = {
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

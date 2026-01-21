{pkgs, ...}: {
  security.pam.services.sudo_local.touchIdAuth = true;

  # environment.systemPackages = [
  # ];

  nixpkgs = {
    config.allowUnfree = true;
  };

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
      "zrok"
    ];

    casks = [
      "antigravity"
      "betterzip"
      "droidcam-obs"
      "floorp"
      "flutter"
      "font-sf-pro"
      "hammerspoon"
      "karabiner-elements"
      "kiro"
      "kitty"
      "middleclick"
      "nextcloud"
      "obs"
      "sf-symbols"
      "steam"
      "trae"
      "wacom-tablet"
      "zen"
    ];

    taps = [
      "houmain/tap" # keymapper
    ];

    masApps = {
      bitwarden = 1352778147;
      line = 539883307;
      sundaykeys = 1615360535;
      # xcode = 497799835;
    };

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
  ];

  nix = {
    enable = true;
    package = pkgs.lixPackageSets.stable.lix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["yim"];
    };
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
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}

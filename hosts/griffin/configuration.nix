{pkgs, ...}: {
  security.pam.services.sudo_local.touchIdAuth = true;

  services.openssh.enable = true;

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "aarch64-darwin";
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
      {
        name = "houmain/tap/keymapper";
        args = ["HEAD"];
      }
    ];

    casks = [
      "affine"
      "aldente"
      "antigravity"
      "beeper"
      "betterzip"
      "claude"
      "cloudflare-warp"
      "codex-app"
      "droidcam-obs"
      "steipete/tap/codexbar"
      "floorp"
      "font-sf-pro"
      "freeshow"
      "hammerspoon"
      "helium-browser"
      "karabiner-elements"
      "kiro"
      "kitty"
      "legcord"
      "logseq"
      "middleclick"
      "nextcloud"
      "obs"
      "opencode-desktop"
      "piphero"
      "protonvpn"
      "raycast"
      "sf-symbols"
      "stats"
      "steam"
      "t3-code"
      "tailscale-app"
      # "thaw"  Requirements: macOS >= 26
      "trae"
      "wacom-tablet"
      "wispr-flow"
      "zcode"
      "zen"
    ];

    taps = [
      # "houmain/tap" # keymapper
      "steipete/tap" # codexbar
    ];

    masApps = {
      bitwarden = 1352778147;
      line = 539883307;
      numbers = 361304891;
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
}

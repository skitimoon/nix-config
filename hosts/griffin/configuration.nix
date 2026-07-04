{pkgs, ...}: {
  security.pam.services.sudo_local.touchIdAuth = true;

  services.openssh.enable = true;

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "aarch64-darwin";
    # overlays = [
    #   (final: prev: {
    #     # Temporary: logseq in nixpkgs currently depends on insecure electron_39.
    #     logseq = prev.logseq.override {electron_39 = final.electron;};
    #   })
    # ];
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
      "sf-symbols"
      "stats"
      "steam"
      "t3-code"
      "tailscale-app"
      "thaw"
      "trae"
      "wacom-tablet"
      "wispr-flow"
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

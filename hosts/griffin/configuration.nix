{
  inputs,
  pkgs,
  ...
}: {
  security.pam.services.sudo_local.touchIdAuth = true;

  # environment.systemPackages = [
  # ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (_final: prev: {
        direnv = prev.direnv.override {
          zsh = inputs.nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system}.zsh;
        };
      })
    ];
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
      "BarutSRB/tap/omniwm"
      "betterzip"
      "cloudflare-warp"
      "codex-app"
      "codexmonitor"
      "droidcam-obs"
      "steipete/tap/codexbar"
      "floorp"
      "font-sf-pro"
      "hammerspoon"
      "helium-browser"
      "karabiner-elements"
      "kitty"
      "kiro"
      "legcord"
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
      "BarutSRB/tap" # omniwm
      "steipete/tap" # codexbar
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

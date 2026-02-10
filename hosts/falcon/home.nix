{
  lib,
  pkgs,
  username,
  ...
}: {
  imports = [
    ../../config/git.nix
    ../../config/nvf.nix
    ../../config/yazi.nix
    ../../config/zsh.nix
  ];

  # Home Manager Setting
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  # Workaround for nix-openclaw managing the same path via home.file and activation.
  home.file.".openclaw/openclaw.json".force = true;

  home.packages = with pkgs; [
    bat
    eza
    lazygit
    ripgrep
    tldr
    trash-cli
  ];

  programs = {
    fzf.enable = true;
    starship.enable = true;
    zsh.initContent = lib.mkAfter ''
      # Run openclaw with runtime secrets from agenix env file.
      openclaw() {
        if [[ -r /run/agenix/openclaw-gateway-token-env ]]; then
          (
            set -a
            . /run/agenix/openclaw-gateway-token-env
            set +a
            command openclaw "$@"
          )
        else
          command openclaw "$@"
        fi
      }
    '';
  };

  programs.openclaw = {
    # Required files: AGENTS.md, SOUL.md, TOOLS.md.
    documents = ./openclaw-documents;

    package = pkgs.openclaw;
    excludeTools = ["ripgrep"];

    instances.default = {
      enable = true;
      config = {
        auth.profiles."google-antigravity:s.kitimoon@gmail.com" = {
          provider = "google-antigravity";
          mode = "oauth";
          email = "s.kitimoon@gmail.com";
        };

        agents.defaults = {
          model.primary = "google-antigravity/gemini-3-pro-high";
          models."google-antigravity/gemini-3-pro-high" = {};
          models."google-antigravity/gemini-3-flash" = {};
          models."google-antigravity/claude-opus-4-5-thinking" = {};
        };

        # Sourced from /run/agenix/openclaw-gateway-token-env
        tools.web.search.apiKey = "\${BRAVE_API_KEY}";

        gateway = {
          mode = "local";
          auth.mode = "token";
        };

        channels.telegram = {
          tokenFile = "/run/agenix/telegram-bot-token";
          # Sourced from /run/agenix/openclaw-gateway-token-env
          allowFrom = ["tg:\${OPENCLAW_TELEGRAM_ALLOW_FROM}"];
        };

        plugins.entries = {
          "google-antigravity-auth" = {
            enabled = true;
          };
          telegram = {
            enabled = true;
          };
        };
      };
    };
  };

  services.syncthing.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  systemd.user.services.openclaw-gateway.Service.EnvironmentFile = [
    "/run/agenix/openclaw-gateway-token-env"
  ];
}

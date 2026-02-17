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
  # Reuse nix-openclaw's pinned source docs in workspace so agent docsPath uses full local docs.
  home.file.".openclaw/workspace/docs".source = "${pkgs.openclaw-gateway.src}/docs";

  home.packages = with pkgs; [
    bat
    eza
    lazygit
    ripgrep
    tldr
    trash-cli
    (callPackage ../../config/gogcli.nix {})
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

      # Run gog with runtime secrets from agenix env file.
      gog() {
        if [[ -r /run/agenix/gog-keyring-env ]]; then
          (
            set -a
            . /run/agenix/gog-keyring-env
            set +a
            command gog "$@"
          )
        else
          command gog "$@"
        fi
      }
    '';
  };

  home.activation.gogKeyringBackend = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v gog >/dev/null 2>&1; then
      $DRY_RUN_CMD gog auth keyring file >/dev/null || true
    fi
  '';

  programs.openclaw = {
    # Required files: AGENTS.md, SOUL.md, TOOLS.md.
    documents = ./openclaw-documents;

    package = pkgs.openclaw;
    excludeTools = ["ripgrep"];

    instances.default = {
      enable = true;
      config = {
        agents.defaults = {
          model.primary = "openai-codex/gpt-5.3-codex";
          models = {
            "openai-codex/gpt-5.3-codex".alias = "codex";
            "qwen-portal/coder-model".alias = "qwen";
            "qwen-portal/vision-model" = {};
            "kimi-coding/k2p5".alias = "kimi";
            "modal-glm5/zai-org/GLM-5-FP8".alias = "glm5";
          };
        };

        # Sourced from /run/agenix/openclaw-gateway-token-env
        tools.web.search.apiKey = "\${BRAVE_API_KEY}";

        models = {
          providers.qwen-portal = {
            baseUrl = "https://portal.qwen.ai/v1";
            auth = "oauth";
            api = "openai-completions";
            models = [
              {
                id = "coder-model";
                name = "Qwen Coder";
              }
              {
                id = "vision-model";
                name = "Qwen Vision";
              }
            ];
          };
          providers.modal-glm5 = {
            baseUrl = "https://api.us-west-2.modal.direct/v1";
            # Sourced from /run/agenix/openclaw-gateway-token-env
            apiKey = "\${MODAL_GLM5_API_KEY}";
            api = "openai-completions";
            models = [
              {
                id = "zai-org/GLM-5-FP8";
                name = "GLM-5 (Modal)";
              }
            ];
          };
        };

        auth.profiles."qwen-portal:default" = {
          provider = "qwen-portal";
          mode = "oauth";
        };
        auth.profiles."openai-codex:default" = {
          provider = "openai-codex";
          mode = "oauth";
        };

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
          telegram = {
            enabled = true;
          };
          qwen-portal-auth = {
            enabled = true;
          };
        };
      };
    };
  };

  services.syncthing.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}

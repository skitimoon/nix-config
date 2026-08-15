{
  pkgs,
  lib,
  username,
  inputs,
  config,
  ...
}: let
  hermesToolPackages = [
    inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.gws
    pkgs.uv
    (pkgs.python3.withPackages (ps: [
      ps.google-api-python-client
      ps.google-auth-httplib2
      ps.google-auth-oauthlib
    ]))
  ];

  hermesAgentPackage = config.services.hermes-agent.package;
in {
  imports = [
    # Include the results of the hardware scan.
    ../../config/nh.nix
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = "nix-command flakes";
  security.sudo.wheelNeedsPassword = false;

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    grub.enable = false;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "falcon";
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };

  # Set your time zone.
  time.timeZone = "Asia/Bangkok";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the Plasma 6 Desktop Environment.
  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    desktopManager.plasma6.enable = true;
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "hermes"];
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs = {
    config.allowUnfree = true;
  };
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };

    zsh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    wget
  ];

  age.secrets = {
    hermes-env = {
      file = ./secrets/hermes-env.age;
      owner = "hermes";
    };
    telegram-bot-token = {
      file = ./secrets/telegram-bot-token.age;
      owner = username;
    };
    gog-keyring-env = {
      file = ./secrets/gog-keyring-env.age;
      owner = username;
    };
    nextcloud-admin-pass = {
      file = ./secrets/nextcloud-admin-pass.age;
      owner = "nextcloud";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.

  # List services that you want to enable:
  services = {
    n8n = {
      enable = true;
      environment = {
        N8N_LISTEN_ADDRESS = "127.0.0.1";
        WEBHOOK_URL = "https://nnn.my.to/";
      };
    };

    hermes-agent = {
      enable = true;
      addToSystemPackages = true;
      environmentFiles = [config.age.secrets.hermes-env.path];
      extraPackages = hermesToolPackages;
      settings = {
        model = {
          provider = "openai-codex";
          default = "gpt-5.5";
          base_url = "https://chatgpt.com/backend-api/codex";
        };

        # NVIDIA NIM free tier as additional switchable models alongside the
        # Codex default. Switch live with e.g.
        #   /model custom:nvidia:z-ai/glm-5.1
        # Requires NVIDIA_API_KEY (nvapi-...) in hermes-env.age. Note: a runtime
        # switch reverts to the Codex default on the next `nixos-rebuild switch`,
        # since the model block above is re-asserted on activation.
        custom_providers = [
          {
            name = "nvidia";
            base_url = "https://integrate.api.nvidia.com/v1";
            key_env = "NVIDIA_API_KEY";
            models = {
              "z-ai/glm-5.1" = {context_length = 203000;};
              "moonshotai/kimi-k2.6" = {context_length = 262000;};
              "deepseek-ai/deepseek-v4-pro" = {context_length = 1000000;};
              "minimaxai/minimax-m3" = {context_length = 1000000;};
            };
          }
        ];

        memory.provider = "holographic";

        display = {
          tool_progress_command = true;
          platforms.telegram = {
            tool_progress = "verbose";
            tool_preview_length = 0;
          };
          platforms.discord = {
            tool_progress = "verbose";
            tool_preview_length = 0;
          };
        };

        # Discord turns itself on when DISCORD_BOT_TOKEN appears in
        # $HERMES_HOME/.env -- there is no enable flag, so the settings below do
        # nothing until the token is added to hermes-env.age. Authorisation is
        # DISCORD_ALLOWED_USERS in that same file, not anything here: with no
        # allowlist the adapter denies every sender (fail-closed), which is the
        # only thing standing between a stranger's DM and an agent holding
        # passwordless root sudo.
        discord = {
          # Never answer an unaddressed message in a server channel. The bot
          # still replies to DMs and to explicit @mentions.
          require_mention = true;
          # Backfill replays surrounding channel scrollback into the prompt when
          # triggered, so messages from people NOT in the allowlist end up in
          # context. Off until you decide that is wanted.
          history_backfill = false;
          missed_message_backfill.enabled = false;
        };

        plugins.hermes-memory-store = {
          db_path = "$HERMES_HOME/memory_store.db";
          auto_extract = false;
          default_trust = 0.5;
          hrr_dim = 1024;
        };
      };
    };

    nextcloud = {
      enable = true;
      package = pkgs.nextcloud33;
      database.createLocally = true;
      hostName = "yim.my.to";
      config = {
        adminpassFile = config.age.secrets.nextcloud-admin-pass.path;
        dbtype = "pgsql";
      };
      settings.trusted_domains = [
        "falcon"
        "falcon.calliope-godzilla.ts.net"
        "falcon.calliope-godzilla.ts.net:8443"
        "100.110.98.106"
      ];
      settings.trusted_proxies = ["127.0.0.1"];
      https = true;
    };

    nginx = {
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      # Origin rewriting for the Hermes dashboard shim below. Two maps rather
      # than one because an absent Origin and a wrong Origin need different
      # answers: Hermes allows the former (non-browser clients) and rejects
      # the latter, so collapsing them into a single default would either
      # break curl or silently accept cross-site handshakes.
      commonHttpConfig = ''
        map $http_origin $hermes_origin_ok {
          default                                   0;
          ""                                        1;
          "https://falcon.calliope-godzilla.ts.net" 1;
        }
        map $http_origin $hermes_origin {
          default                                   "";
          "https://falcon.calliope-godzilla.ts.net" "http://127.0.0.1:9119";
        }
      '';
    };

    nginx.virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = true;
      enableACME = true;
      serverAliases = [
        "falcon"
        "falcon.calliope-godzilla.ts.net"
        "100.110.98.106"
      ];
    };

    nginx.virtualHosts."nextcloud-tailnet.local" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 8444;
        }
      ];
      locations."/" = {
        proxyPass = "https://127.0.0.1";
        recommendedProxySettings = false;
        extraConfig = ''
          proxy_ssl_server_name on;
          proxy_ssl_name ${config.services.nextcloud.hostName};
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host falcon.calliope-godzilla.ts.net:8443;
          proxy_set_header X-Forwarded-Host falcon.calliope-godzilla.ts.net:8443;
          proxy_set_header X-Forwarded-Proto https;
          proxy_set_header X-Forwarded-Ssl on;
        '';
      };
    };

    # The Hermes dashboard binds to loopback and rejects any Host header that
    # isn't a loopback name (anti-DNS-rebinding, GHSA-ppp5-vxwm-4cf7), while
    # `tailscale serve` forwards the original Host. This shim rewrites Host to
    # what the dashboard expects, and re-implements the rejected check here so
    # the rebinding defence isn't simply dropped: anything arriving on this
    # port without the tailnet hostname is refused before it reaches Hermes.
    #
    # WebSocket upgrades need the same treatment for Origin. FastAPI runs no
    # HTTP middleware on WS routes, so Hermes repeats the check inline there
    # and additionally requires Origin to name the bound host. Origin is the
    # only thing standing between a random site the browser visits and
    # /api/console, so it is validated here before being rewritten -- never
    # rewritten unconditionally.
    nginx.virtualHosts."hermes-tailnet.local" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 8445;
        }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:9119";
        proxyWebsockets = true;
        extraConfig = ''
          if ($http_host != "falcon.calliope-godzilla.ts.net") {
            return 421;
          }
          if ($hermes_origin_ok = 0) {
            return 421;
          }
          proxy_set_header Host 127.0.0.1:9119;
          # Empty value means nginx drops the header entirely, which is what
          # the no-Origin case should look like to Hermes.
          proxy_set_header Origin $hermes_origin;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Host falcon.calliope-godzilla.ts.net;
          proxy_set_header X-Forwarded-Proto https;
          proxy_redirect http://127.0.0.1:9119/ https://falcon.calliope-godzilla.ts.net/;
        '';
      };
    };

    nginx.virtualHosts."nnn.my.to" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:5678/";
          proxyWebsockets = true;
        };
      };
    };

    openssh.enable = true;
    tailscale.enable = true;
  };

  systemd.services.hermes-dashboard = {
    description = "Hermes Agent web dashboard";
    after = ["network-online.target" "hermes-agent.service"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    environment = {
      HOME = "/var/lib/hermes";
      HERMES_HOME = "/var/lib/hermes/.hermes";
      HERMES_CONFIG_PATH = "/var/lib/hermes/.hermes/config.yaml";
      HERMES_MANAGED = "true";
      HERMES_SKIP_CHMOD = "1";
    };

    path = with pkgs;
      [
        git
        coreutils
        findutils
        gawk
        gnugrep
        gnused
      ]
      ++ hermesToolPackages;

    serviceConfig = {
      User = "hermes";
      Group = "hermes";
      WorkingDirectory = "/var/lib/hermes/workspace";
      ExecStart = "${hermesAgentPackage}/bin/hermes dashboard --skip-build --no-open --host 127.0.0.1 --port 9119";
      EnvironmentFile = [config.age.secrets.hermes-env.path];
      Restart = "always";
      RestartSec = 5;
      UMask = "0007";
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = false;
      ReadWritePaths = [
        "/var/lib/hermes"
        "/var/lib/hermes/workspace"
        "/home/yim/nix-config"
      ];
    };
  };

  # `tailscale serve` state is otherwise imperative and lives in tailscaled's
  # database, so it silently drifts from this file (e.g. when the Hermes UI
  # moved from 8787 to 9119). This unit is the source of truth: it resets the
  # serve config and re-applies the mappings below on every activation.
  systemd.services.tailscale-serve = {
    description = "Declarative tailscale serve mappings";
    after = ["tailscaled.service" "network-online.target"];
    wants = ["network-online.target"];
    requires = ["tailscaled.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = let
      tailscale = "${config.services.tailscale.package}/bin/tailscale";
    in ''
      # Serve config is rejected until the backend has finished authenticating.
      # The `|| true` matters: `tailscale status` exits non-zero while the
      # daemon socket is still coming up, and a failing command substitution
      # would abort this script under `set -e` before the retry ever happens.
      state=""
      for _ in $(seq 1 60); do
        state=$(${tailscale} status --json 2>/dev/null | ${pkgs.jq}/bin/jq -r .BackendState 2>/dev/null || true)
        [ "$state" = "Running" ] && break
        sleep 2
      done
      if [ "$state" != "Running" ]; then
        echo "tailscaled still in state '$state' after 120s; giving up" >&2
        exit 1
      fi

      ${tailscale} serve reset
      ${tailscale} serve --bg --yes --https=443 http://127.0.0.1:8445 # hermes-dashboard (via nginx Host shim)
      ${tailscale} serve --bg --yes --https=5678 http://127.0.0.1:5678 # n8n
      ${tailscale} serve --bg --yes --https=8443 http://127.0.0.1:8444 # nextcloud
    '';
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      ${config.services.nextcloud.hostName}.email = "s.kitimoon+letsencrypt@gmail.com";
      "nnn.my.to".email = "s.kitimoon+letsencrypt@gmail.com";
    };
  };

  nix.settings.trusted-users = ["yim"];

  systemd.services.n8n.path = with pkgs; [
    nodejs
    python3
  ];

  systemd.services.hermes-agent.serviceConfig.NoNewPrivileges = lib.mkForce false;

  security.sudo.extraRules = [
    {
      users = ["hermes"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  system.activationScripts.hermesNixConfigAccess.text = ''
    ${pkgs.acl}/bin/setfacl -m u:hermes:x /home/yim

    if [ -d /home/yim/nix-config ]; then
      ${pkgs.acl}/bin/setfacl -m u:hermes:rwx /home/yim/nix-config

      # Skip symlinks: setfacl follows them, and a `result` symlink left by
      # `nixos-rebuild build` points into the read-only store, which fails the
      # whole snippet and so fails activation.
      ${pkgs.findutils}/bin/find /home/yim/nix-config \
        -path /home/yim/nix-config/.git -prune -o \
        ! -type l -exec ${pkgs.acl}/bin/setfacl -m u:hermes:rwX {} +

      ${pkgs.findutils}/bin/find /home/yim/nix-config \
        -path /home/yim/nix-config/.git -prune -o \
        -type d -exec ${pkgs.acl}/bin/setfacl -d -m u:hermes:rwX {} +
    fi
  '';

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [80 443];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.11"; # Did you read the comment?
}

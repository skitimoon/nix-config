{
  pkgs,
  lib,
  username,
  inputs,
  config,
  ...
}: let
  hermesWebuiSrc = pkgs.fetchFromGitHub {
    owner = "nesquena";
    repo = "hermes-webui";
    rev = "306dd2bf09ecdc988cbc41e932591feea12a8d72";
    hash = "sha256-SVTk2zEUKpTkL5pVmrYajpq+ISqBofo0eg4Z3Et5XHg=";
  };

  hermesWebuiStart = pkgs.writeShellScript "hermes-webui-start" ''
    set -euo pipefail

    project=$(/run/current-system/sw/bin/hermes --version 2>&1 | ${pkgs.gawk}/bin/awk -F': ' '/^Project:/{print $2; exit}')
    if [ -z "$project" ] || [ ! -f "$project/run_agent.py" ]; then
      echo "Could not resolve Hermes Agent site-packages directory containing run_agent.py" >&2
      exit 1
    fi

    python_env="''${project%/lib/python*/site-packages}"
    python="$python_env/bin/python3"
    if [ ! -x "$python" ]; then
      echo "Could not resolve executable Hermes Python at $python" >&2
      exit 1
    fi

    export HERMES_WEBUI_AGENT_DIR="$project"
    export HERMES_WEBUI_PYTHON="$python"

    cd ${hermesWebuiSrc}
    exec "$python" ${hermesWebuiSrc}/bootstrap.py --foreground --no-browser --skip-agent-install
  '';
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
      environment.WEBHOOK_URL = "https://nnn.my.to/";
    };

    hermes-agent = {
      enable = true;
      addToSystemPackages = true;
      environmentFiles = [config.age.secrets.hermes-env.path];
      extraPackages = with pkgs; [
        inputs.nixpkgs.legacyPackages.${stdenv.hostPlatform.system}.gws
        uv
        (python3.withPackages (ps: [
          ps.google-api-python-client
          ps.google-auth-httplib2
          ps.google-auth-oauthlib
        ]))
      ];
      settings = {
        model = {
          provider = "openai-codex";
          default = "gpt-5.5";
          base_url = "https://chatgpt.com/backend-api/codex";
        };

        custom_providers = [
          {
            name = "The Claw Bay";
            base_url = "https://api.theclawbay.com/v1";
            model = "gpt-5.5";
            key_env = "THECLAWBAY_API_KEY";
            api_mode = "chat_completions";
          }
        ];

        memory.provider = "holographic";

        display = {
          tool_progress_command = true;
          platforms.telegram = {
            tool_progress = "verbose";
            tool_preview_length = 0;
          };
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
      https = true;
    };

    nginx = {
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };

    nginx.virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = true;
      enableACME = true;
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

    nginx.virtualHosts."gym.my.to" = {
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

  systemd.services.hermes-webui = {
    description = "Hermes WebUI";
    after = ["network-online.target" "hermes-agent.service"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    environment = {
      HOME = "/var/lib/hermes";
      HERMES_HOME = "/var/lib/hermes/.hermes";
      HERMES_CONFIG_PATH = "/var/lib/hermes/.hermes/config.yaml";
      HERMES_MANAGED = "true";
      HERMES_SKIP_CHMOD = "1";
      HERMES_WEBUI_STATE_DIR = "/var/lib/hermes/.hermes/webui";
      HERMES_WEBUI_DEFAULT_WORKSPACE = "/var/lib/hermes/workspace";
      HERMES_WEBUI_HOST = "127.0.0.1";
      HERMES_WEBUI_PORT = "8787";
      HERMES_WEBUI_SKIP_ONBOARDING = "1";
    };

    path = with pkgs; [
      git
      coreutils
      findutils
      gawk
      gnugrep
      gnused
      uv
      inputs.nixpkgs.legacyPackages.${stdenv.hostPlatform.system}.gws
      (python3.withPackages (ps: [
        ps.google-api-python-client
        ps.google-auth-httplib2
        ps.google-auth-oauthlib
      ]))
    ];

    serviceConfig = {
      User = "hermes";
      Group = "hermes";
      WorkingDirectory = "/var/lib/hermes/workspace";
      ExecStart = hermesWebuiStart;
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

  security.acme = {
    acceptTerms = true;
    certs = {
      ${config.services.nextcloud.hostName}.email = "s.kitimoon+letsencrypt@gmail.com";
      "nnn.my.to".email = "s.kitimoon+letsencrypt@gmail.com";
      "gym.my.to".email = "s.kitimoon+letsencrypt@gmail.com";
    };
  };

  nix.settings.trusted-users = ["yim"];

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

      ${pkgs.findutils}/bin/find /home/yim/nix-config \
        -path /home/yim/nix-config/.git -prune -o \
        -exec ${pkgs.acl}/bin/setfacl -m u:hermes:rwX {} +

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
  system.stateVersion = "25.11"; # Did you read the comment?
}

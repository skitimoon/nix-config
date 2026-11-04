{
  pkgs,
  username,
  config,
  ...
}: {
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
    extraGroups = ["wheel"];
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

    # uv's downloaded CPython and manylinux wheels are generic-Linux binaries.
    nix-ld.enable = true;

    zsh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    wget
  ];

  # ppm-odoo scripts call `docker compose`; rootless Podman serves it, as on griffin.
  virtualisation = {
    containers.containersConf.settings.engine.compose_warning_logs = false;
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  age.secrets = {
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
      # TODO: drop once nixpkgs fixes the n8n pnpmDeps hash mismatch (2026-11-02)
      package = pkgs.n8n.overrideAttrs (old: {
        pnpmDeps = old.pnpmDeps.overrideAttrs {
          outputHash = "sha256-kSv/8YxvwCFxrSRTqYHP+TAmDgu5OPbcwolHVIqCGDA=";
        };
      });
      environment = {
        N8N_LISTEN_ADDRESS = "127.0.0.1";
        WEBHOOK_URL = "https://nnn.my.to/";
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

  # `tailscale serve` state is otherwise imperative and lives in tailscaled's
  # database, so it silently drifts from this file. This unit is the source of
  # truth: it resets the serve config and re-applies the mappings below on
  # every activation.
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
      ${tailscale} serve --bg --yes --https=443 http://127.0.0.1:3773 # t3code
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

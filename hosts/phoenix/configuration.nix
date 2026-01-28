{
  pkgs,
  username,
  ...
}: {
  imports = [../../config/nh-system.nix ./hardware-configuration.nix];
  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    extraOptions = ''
      extra-substituters = https://devenv.cachix.org
      extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
    '';
  };

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 7;
      };
      efi.canTouchEfiVariables = true;
    };
    tmp = {
      useTmpfs = true;
      # tmpfsSize = "30%";
    };
  };

  networking.hostName = "phoenix";
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Bangkok";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    supportedLocales = ["en_GB.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" "th_TH.UTF-8/UTF-8"];
  };
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  services = {
    blueman.enable = true;
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  programs = {
    kdeconnect.enable = true;

    zsh.enable = true;
  };

  services = {
    kanata = {
      enable = true;
      keyboards."all" = {
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          (defsrc
            f1             f3                 f4             f5         f6         f7
            1       2          3       4       5       6       7       8       9       0       ScrollLock
            tab     q          w       e
                    a          s       d               h       j       k       l
          )
          (deflayer default
            MediaPlayPause MediaTrackPrevious MediaTrackNext VolumeMute VolumeDown VolumeUp
            _       _          _       _       _       _       _       _       _       _       NumLock
            @tab    _          _       _
                    _          _       _               _       _       _       _
          )
          (deflayer nav
            f1             f3                 f4             f5         f6         f7
            Numpad1 Numpad2    Numpad3 Numpad4 Numpad5 Numpad6 Numpad7 Numpad8 Numpad9 Numpad0 NumLock
            _       VolumeDown up      VolumeUp
                    left       down    right           left down up  right
          )
          (defalias
            tab (tap-hold-press 200 200 tab (layer-while-held nav))
          )
        '';
      };
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    printing = {
      enable = true;
      drivers = [pkgs.epson-escpr];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    git
    neovim
    pwvucontrol
    wget
    wl-clipboard
  ];

  fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.syncthing = {
    enable = true;
    user = username;
    dataDir = "/home/${username}";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
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
  system.stateVersion = "25.05"; # Did you read the comment?
}

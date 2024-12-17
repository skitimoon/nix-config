# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

# let
#   # Create an overlay to access unstable packages
#   unstable = import (fetchTarball "channel:nixos-unstable") {
#     config = config.nixpkgs.config;
#   };
# in
{
  imports =
    [ # Include the results of the hardware scan.
      # <nixos-hardware/apple/macbook-pro/10-1>
      # <nixos-hardware/common/gpu/nvidia/disable>
      ./macbook-pro.nix
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 7;
    };
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "eagle"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Bangkok";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    supportedLocales = [
      "en_GB.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "th_TH.UTF-8/UTF-8"
    ];
  };
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  # Enable the Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    # autoLogin.user = "yim";
    defaultSession = "plasma";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
  programs.kdeconnect.enable = true;
  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
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
      # keyboards."all".config = ''
      #   (defsrc           esc grv tab  caps 8
      #                                          h    j    k  l)
      #   (deflayer default grv esc @tab lctl 8
      #                                          _    _    _  _)
      #   (deflayer multi     _   _   _    _    pp
      #                                          left down up right)
      #   (defalias tab (tap-hold 200 200 tab (layer-while-held multi)))
      # '';
      # keyboards."all".extraDefCfg = "process-unmapped-keys yes";
    };

    # Enable sound.
    # hardware.pulseaudio.enable = true;
    # OR
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  security = {
    pam.services.login.kwallet = {
      enable = true;
    };
    sudo.wheelNeedsPassword = false;
  };

  users.defaultUserShell = pkgs.zsh;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.yim = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    # packages = with pkgs; [
    #   firefox
    #   tree
    # ];
  };

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    _64gram
    btop
    cargo
    clang
    cliphist
    dropbox
    eza
    fd
    floorp
    git
    gnumake
    jq
    kitty
    lazygit
    localsend
    logseq
    libreoffice-qt-fresh
    mpv
    neovim
    nodePackages.npm
    pciutils
    python3
    ripgrep
    super-productivity
    thunderbird
    tldr
    tlwg
    unzip
    vscode
    wget
    yazi
    yt-dlp
  ];

  # Temporary fix for logseq
  nixpkgs.config.permittedInsecurePackages = [
    "electron-27.3.11"
  ];

  fonts.packages = with pkgs; [
    nerdfonts
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs = {
    nh = {
      enable = true;
    };
    zsh = {
      enable = true;
      histSize = 50000;
      autosuggestions.enable = true;
      shellAliases = {
        nix = "noglob nix";
      };
    };
    starship.enable = true;
    fzf.keybindings = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  
  services.syncthing = {
    enable = true;
    user = "yim";
    dataDir = "/home/yim";
  };

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
  system.stateVersion = "24.05"; # Did you read the comment?

}


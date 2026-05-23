{ config, pkgs, user, inputs, ... }:

{
  #region Enable Lix
  nixpkgs.overlays = [ (final: prev: {
    inherit (prev.lixPackageSets.stable)
      nixpkgs-review
      nix-eval-jobs
      nix-fast-build
      colmena;
  }) ];

  nix.package = pkgs.lixPackageSets.stable.lix;
  #endregion

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 5;
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };


  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking = {
    hostName = "nixos"; # Define your hostname

    networkmanager.enable = false; # Enabling WPA instead

    # static ip
    interfaces.wlo1 = {
      ipv4.addresses = [{
        address = "192.168.1.50";
        prefixLength = 24;
      }];
    };

    defaultGateway = {
      address = "192.168.1.1";
      interface = "wlo1";
    };

    nameservers = ["1.1.1.1" "8.8.8.8"];

    wireless = {
      enable = true; # Enables wireless support via wpa_supplicant
      networks = {
        "Vybe_Nest Co Space_5B_5G" = {
          pskRaw = "a0717ae84e962d2a15d56a930d4262ed07b4b66c92ae381ce7bd0703b22b1b00";
        };
      };
    };
  };


  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Disable GNOME application suite
  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = true;
  services.gnome.games.enable = false;
  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable VSCode Server
  programs.nix-ld.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable Flatpak service
  services.flatpak.enable = true;

  # Automatically add Flathub repository
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Non GNOME distros - Flatpak
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Disable sleep
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernate=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "sea vuh";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    # gnomeExtensions.gjs-osk
    #  thunderbird
    ];
  };

  # User does not need to give password when using sudo
  security = {
    sudo.wheelNeedsPassword = false;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Nix Flakes
  # nix.settings.experimental-features = ["nix-command" "flakes"];

  # Enable Auto Garbage Collect
  nix = {
    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    flake = inputs.self.outPath;
    flags = [
      "--print-build-logs"
      "--commit-lock-file"
    ];
    dates = "04:40";
    randomizedDelaySec = "45min";
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}

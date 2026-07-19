# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  user,
  inputs,
  ...
}:

{

  # Enable Lix
  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];

  nix.package = pkgs.lixPackageSets.stable.lix;

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./flatpak.nix
  ];

  ## Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 5;
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable Intel hardware acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell (Gen 8) and newer (VAAPI)
      intel-compute-runtime # OpenCL support
      vpl-gpu-rt # Intel Video Processing Library (Intel Quick Sync Video)
    ];
  };

  # Set environment variables for hardware acceleration
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # Load the Apple HID module
  boot.kernelModules = [ "hid_apple" ];

  # Configure behavior for Apple Keyboards
  boot.extraModprobeConfig = "options hid_apple fnmode=2";

  ## Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        FastConnectable = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to 'false'.
        Experimental = true;
        # Forces BR/EDR mode to prevent crashes and dropouts with AirPods/Apple peripherals
        ControllerMode = "bredr";
        # Disable autosuspend on the Bluetooth controller to prevent input dropouts
        JustWorksRepairing = "always";
      };
      Input = {
        # Allows userspace to handle HID devices (fixes unresponsive Apple Magic Trackpads)
        UserspaceHID = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };

  # Define your hostname.
  networking.hostName = "nixos";

  # Enable network manager
  networking = {
    # Disable DHCP so it doesn't overwrite your static configuration
    useDHCP = false;
    interfaces.wlo1 = {
      ipv4.addresses = [
        {
          address = "192.168.1.50";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = "192.168.1.1";
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];

    networkmanager = {
      enable = true;
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

  ## Disable GNOME application suite
  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;

  # Disable Xterm from your system
  services.xserver.excludePackages = with pkgs; [ xterm ];
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
  ];

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

  # Enable touchpad support
  services.libinput = {
    enable = true;
    # Trackpad behavior
    touchpad = {
      naturalScrolling = true; # Matches macOS natural scroll
      disableWhileTyping = true; # Prevents jumping cursor when typing
      clickMethod = "clickfinger"; # Two-finger click for right-click, three-finger for middle-click
      tapping = true; # Tap-to-click
      scrollMethod = "twofinger"; # Optional: Adjust scrolling or acceleration if the trackpad is still jumpy
      tappingDragLock = false; # Can cause jumpy behavior when dragging items
      accelProfile = "flat"; # Disables Wayland/libinput mouse acceleration for a 1:1 Mac feel
    };
  };

  # Enable Flatpak service
  services.flatpak.enable = true;
  # Automatically add Flathub repository
  # systemd.services.flatpak-repo = {
  #   wantedBy = [ "multi-user.target" ];
  #   path = [ pkgs.flatpak ];
  #   script = ''
  #     flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  #   '';
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "${user}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "render"
      "incus-admin" # incus
    ];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  # SUDO no password
  security.sudo.wheelNeedsPassword = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    librewolf
    alacritty # Terminal
    neovim
    nixfmt # Nix - Official RFC-style formatter (Recommended)
    zsh
    git
  ];

  # Set Alacritty as the default terminal
  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [ "alacritty.desktop" ];
    };
  };

  # Enable Auto Garbage Collect
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Optimize store
  nix.settings.auto-optimise-store = true;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  ## Enable auto upgrade
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

  # List services that you want to enable:

  # Enable incus
  virtualisation.incus.enable = true;
  networking.nftables.enable = true;
  # Firewall settings
  networking.firewall.trustedInterfaces = [ "incusbr0" ];

  # Enable Git system-wide
  programs.git.enable = true;

  #Enable zsh system-wide
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  system.stateVersion = "26.05"; # Did you read the comment?

}

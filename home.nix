{
  config,
  pkgs,
  user,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # Enable fontconfig to manage fonts and improve font rendering
  fonts.fontconfig.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # gnome core apps
    gnome-software # software store
    gnome-clocks # clock
    nautilus # File Manager
    # gnome-tweaks # Advanced Customization Tool
    gnome-calculator # Calculator
    gnome-system-monitor # system monitor
    gnome-disk-utility # Udisks UI
    baobab # disk usage
    gnome-font-viewer # font viewer
    gnome-logs # logs viewer
    gnome-text-editor # text editor
    loupe # image viewer
    papers # document viewer

    epiphany # browser
    brave # browser

    # gnome extensions
    gnomeExtensions.gjs-osk
    gnomeExtensions.forge
    gnomeExtensions.blur-my-shell
    gnomeExtensions.vitals

    # terminal
    nvtopPackages.intel

    # utilities
    obsidian # markdown note-taking app
    speedtest-cli # okla speed test

    # shell fix
    nix-your-shell

    # fonts
    nerd-fonts.jetbrains-mono

    # proton
    # proton-pass
    # protonmail-desktop

    # bitwarden
    # insecure electron pkg
    # bitwarden-desktop

  ];

  # GNOME Desktop Configuration
  dconf = {
    enable = true;

    settings = {
      # Auto enable gnome extensions
      "org/gnome/shell" = {
        enabled-extensions = [
          "gjsosk@vishram1123.com"
          "forge@jmmaranan.com"
          "blur-my-shell@aunetx"
          "Vitals@CoreCoding.com"
        ];
      };

      # Appearance
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      # touchpad scrolling
      "org/gnome/desktop/peripherals/touchpad" = {
        natural-scroll = false;
      };

    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {

  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Ensure htop is installed and configured
  programs.htop = {
    enable = true;
    settings = {
      color_scheme = 6; # 6 corresponds to a popular dark/monokai theme
      delay = 15; # Update frequency in tenths of a second (1.5 seconds)
      show_cpu_temperature = 1; # Display CPU temperature next to CPU meters
      show_program_path = 0; # Show only the program basename
      detailed_cpu_time = 1; # Show detailed time (user, system, steal, etc.)

      # Customize Left Metersh
      leftMeters = [
        "AllCPUs2"
        "Memory"
        "Swap"
      ];

      # Customize Right Meters
      rightMeters = [
        "Tasks"
        "LoadAverage"
        "Uptime"
        "Systemd"
      ];
    };
  };

  # nix-my-shell
  programs.nix-your-shell = {
    enable = true;

    # Optional: Enable for selected shells. Default: `home.shell.enable<Shell>Integration`.
    # enableFishIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;

    # Optional: Whether to pipe the build output through nix-output-monitor. Default: false.
    # nix-output-monitor.enable = true;
  };
  # generate the nix-your-shell.nu file
  home.file."${config.xdg.configHome}/nushell/nix-your-shell.nu".source =
    pkgs.nix-your-shell.generate-config "nu";

  # Nushell Configuration
  programs.nushell = {
    enable = true;

    # Set your shell environment variables
    extraEnv = ''
      $env.PATH = ($env.PATH | split row (char esep) | prepend ~/.nix-profile/bin)
    '';

    # Set Nushell configuration variables
    extraConfig = ''
      $env.config = {
        show_banner: false,
        completions: {
          case_sensitive: false,
          quick: true,
          partial: true,
          algorithm: "fuzzy"
        }
      }
    '';

    # Define shell aliases
    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
      nix-switch = "sudo nixos-rebuild switch --flake .";
      nix-test = "sudo nixos-rebuild test --flake .";
    };
  };

  # Workaround: Use Bash as the login shell and automatically launch Nushell
  # programs.bash = {
  #   enable = true;
  #   initExtra = ''
  #     if [[ $- == *i* ]] && [[ -z "$TMUX" ]]; then
  #       exec nu
  #     fi
  #   '';
  # };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
      theme = "robbyrussell";
    };
    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
      nix-switch = "sudo nixos-rebuild switch --flake .";
      nix-test = "sudo nixos-rebuild test --flake .";
    };
    history.size = 10000;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "full";
        opacity = 0.9;
      };
      font = {
        size = 12.0;
        normal.family = "JetBrainsMono Nerd Font";
      };
      colors = {
        primary = {
          background = "0x1e1e2e";
          foreground = "0xcdd6f4";
        };
      };
    };
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      nix_shell = {
        format = "[$symbol(\\($name\\))]($style) ";
      };
    };
  };

  # Example integration for a great prompt and auto-suggestions
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  #VS Code
  programs.vscode = {
    enable = true;

    profiles.default = {
      # Declarative extensions from nixpkgs
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        # arrterian.nix-env-selector
        dracula-theme.theme-dracula
        jnoortheen.nix-ide
        vscode-icons-team.vscode-icons
      ];
    };
  };

  #git
  programs.git = {
    enable = true;
    settings = {
      # Optional: useful for setting default branch or other global configs
      init.defaultBranch = "main";

      user = {
        name = "${user}";
        email = "${user}@git.com";
      };
    };
  };

  ## librewolf
  programs.librewolf = {
    enable = true;
    profiles = {
      personal = {
        id = 0;
        name = "personal";
        isDefault = true;

        search = {
          force = true;
          default = "google"; # Or your preferred engine
          engines = {
            "Nix Packages" = {
              urls = [ { template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; } ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "Nix Options" = {
              urls = [ { template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}"; } ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
            };
          };
        };

        settings = {
          # show bookmarks bar 0 never, 1 always, 2 on new tab
          "browser.toolbars.bookmarks.visibility" = "1";

          # Smooth youtube playback
          "media.ffmpeg.vaapi.enabled" = true;
          "media.ffvpx.enabled" = false;
          "media.rdd-vpx.enabled" = false;
          "media.navigator.mediadatadecoder_vpx_enabled" = true;

          # Disable av1 support
          "media.av1.enabled" = false;

          # Optional: Hide the PiP toggle button from playing videos
          "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
          # Keep PiP playing when switching tabs
          "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = true;
          # (Optional) Auto-open PiP automatically when switching tabs
          # Note: This experimental feature has moved between Firefox Labs and default based on your Firefox version
          "media.videocontrols.picture-in-picture.auto-open.enabled" = true;
        };
      };
    };

    policies = {

      SearchEngines = {
        Remove = [
          "Bing"
          "Amazon.com"
          "eBay"
          "Twitter"
          "Perplexity"
        ];
        Default = "Google";
      };

      # Extensions
      ExtensionSettings =
        let
          moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
        in
        {
          # Improve YouTube
          "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}" = {
            install_url = moz "youtube-addon";
            installation_mode = "normal_installed";
          };

          # bitwarden
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = moz "bitwarden-password-manager";
            installation_mode = "normal_installed";
          };

          # dark reader
          "addon@darkreader.org" = {
            install_url = moz "darkreader";
            installation_mode = "normal_installed";
          };

          # privacy badger
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = moz "privacy-badger17";
            installation_mode = "normal_installed";
          };

          # Proton Pass
          "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
            install_url = moz "proton-pass";
            installation_mode = "normal_installed";
          };

          # Proton VPN
          "vpn@proton.ch" = {
            install_url = moz "proton-vpn-firefox-extension";
            installation_mode = "normal_installed";
          };

          # Sponsor Blocker
          "sponsorBlocker@ajay.app" = {
            install_url = moz "sponsorblock";
            installation_mode = "normal_installed";
          };

          # uBlock origin
          "uBlock0@raymondhill.net" = {
            install_url = moz "ublock-origin";
            installation_mode = "force_installed";
          };

        };

    };
  };

}

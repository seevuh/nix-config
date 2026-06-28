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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # gnome core apps
    gnome-software # software store

    # gnome extensions
    # gnomeExtensions.gjs-osk
    gnomeExtensions.forge
    gnomeExtensions.blur-my-shell
    gnomeExtensions.vitals

    # terminal
    nvtopPackages.intel

    # browsers
    brave
  ];

  # GNOME Desktop Configuration
  dconf = {
    enable = true;

    settings = {
      # Auto enable gnome extensions
      "org/gnome/shell" = {
        enabled-extensions = [
          "forge@jmmaranan.com"
          "blur-my-shell@aunetx"
          "Vitals@CoreCoding.com"
        ];
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

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # Ensure htop is installed and configured
    htop = {
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

    ## librewolf
    librewolf = {
      enable = true;
      profiles = {
        personal = {
          id = 0;
          name = "Personal";
          isDefault = true;

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
            # uBlock origin
            "uBlock0@raymondhill.net" = {
              install_url = moz "ublock-origin";
              installation_mode = "force_installed";
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

            # bitwarden
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = moz "bitwarden-password-manager";
              installation_mode = "normal_installed";
            };

            # Sponsor Blocker
            "sponsorBlocker@ajay.app" = {
              install_url = moz "sponsorblock";
              installation_mode = "normal_installed";
            };

            # Improve YouTube
            "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}" = {
              install_url = moz "youtube-addon";
              installation_mode = "normal_installed";
            };

          };

      };
    };

    #VS Code
    vscode = {
      enable = true;

      profiles.default = {
        # Declarative extensions from nixpkgs
        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          dracula-theme.theme-dracula
          jnoortheen.nix-ide
          vscode-icons-team.vscode-icons
        ];

        userSettings = {
          "telemetry.telemetryLevel" = "off";
          "workbench.colorTheme" = "Monokai Pro (Filter Spectrum)";
          "workbench.iconTheme" = "vscode-icons";
          "git.confirmSync" = false;
        };
      };
    };

    #git
    git = {
      enable = true;
      userName = "seavuh";
      userEmail = "sea@vuh.com";

      # Optional: useful for setting default branch or other global configs
      extraConfig = {
        init.defaultBranch = "main";
      };
    };

  };

}

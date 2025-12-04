{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Add home-manager input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-qmk = {
      url = "github:qmk/homebrew-qmk";
      flake = false;
    };

    homebrew-avr = {
      url = "github:osx-cross/homebrew-avr";
      flake = false;
    };

    homebrew-arm = {
      url = "github:osx-cross/homebrew-arm";
      flake = false;
    };

    homebrew-tap-nikita = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };

    homebrew-tap-sketchybar = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-qmk,
    homebrew-avr,
    homebrew-arm,
    homebrew-tap-nikita,
    homebrew-tap-sketchybar,
    ...
  }: let
    username = "tm";
    finnerPath = "${finnerKeyboardLayout}/Finner.keylayout";
    targetDir = "/Library/Keyboard Layouts";
    targetPath = "${targetDir}/Finner.keylayout";
    configuration = {pkgs, ...}: {
      users = {
        # Create a user with the specified username
        users."${username}" = {
          home = "/Users/${username}";
          name = "${username}";
        };
      };
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        # pkgs.neovim
        finnerKeyboardLayout
        inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
        pkgs.alejandra
        pkgs.atuin
        pkgs.btop
        pkgs.cmake
        pkgs.eza
        pkgs.fd
        pkgs.fish
        pkgs.fnm
        pkgs.fzf
        pkgs.gh
        pkgs.git
        pkgs.mise
        pkgs.ncdu
        pkgs.nixd
        pkgs.pandoc
        pkgs.pipx
        pkgs.pipx
        pkgs.ripgrep
        pkgs.starship
        pkgs.topgrade
        pkgs.wget
        pkgs.zoxide
        pkgs.yazi
      ];

     fonts.packages = with pkgs; [
	nerd-fonts.jetbrains-mono
	nerd-fonts.hack
	nerd-fonts.iosevka-term
	nerd-fonts.iosevka
	iosevka-bin
      ];

      homebrew = {
        enable = true;
        onActivation = {
          cleanup = "uninstall";
          autoUpdate = true;
          upgrade = true;
        };
        brews = [
          "blueutil"
          "croc"
          "dotnet"
          "elixir"
          "exercism"
          "iperf3"
          "jj"
          "mono-libgdiplus"
          "mpv"
          "pandoc"
          "pipx"
          "qmk/qmk/qmk"
          "swiftformat"
          "swiftlint"
          "xcodegen"
          "xcode-build-server"
          "yadm"
          "portaudio"
          "tree-sitter"
          "tree-sitter-cli"
          "zsh-vi-mode"
          "xcbeautify"
          "ruby"
          "coreutils"
          "sketchybar"
        ];
        casks = [
          "1password-cli"
          "aerospace"
          "container"
          "1password"
          "alt-tab"
          "betterdisplay"
          "domzilla-caffeine"
          "font-hack-nerd-font"
          "ghostty"
          "hammerspoon"
          "hiddenbar"
          "jetbrains-toolbox"
          "leader-key"
          "middleclick"
          "mos"
          "netnewswire"
          "obsidian"
          "omnidisksweeper"
          "openmtp"
          "orbstack"
          "plex"
          "qmk-toolbox"
          "rustdesk"
          "sanesidebuttons"
          "signal"
          "spotify"
          "tailscale-app"
          "visual-studio-code@insiders"
          "wezterm@nightly"
          "whatsapp"
          "zed"
        ];
      };

      #nix.nixPath = ["nixpkgs=${nixpkgs}"];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;
      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      system.primaryUser = "tm";

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToEscape = false;

      system.defaults.CustomUserPreferences = {
        "com.apple.finder" = {
          AppleShowAllFiles = true;
          ShowStatusBar = true;
          ShowPathbar = true;
          ShowSidebar = true;
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = false;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          FXPreferredViewStyle = "Nlsv"; # List view
          FXDefaultSearchScope = "SCcf"; # Current folder
          FXEnableExtensionChangeWarning = false;
          DisableAllAnimations = true;
          NewWindowTarget = "PfLo"; # Open new windows in the home directory
          NewWindowTargetPath = "~/"; # Path to the home directory
          AppleShowAllExtensions = true;
          WarnOnEmptyTrash = false;
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true; # Don't create .DS_Store files on network volumes
          DontWriteUSBStores = true; # Don't create .DS_Store files on USB volumes
        };
        "com.apple.dock" = {
          autohide = true;
          autohide-delay = 0;
          autohide-time-modifier = 0;
          orientation = "bottom";
          tilesize = 36;
          show-recents = false; # Disable recent applications in the dock
          show-process-indicators = true; # Show indicators for running applications
        };
        "com.apple.activitymonitor" = {
          OpenInMainWindow = true; # Open Activity Monitor in the main window
          IconType = 5; # Show CPU usage in the dock icon
          SortColumn = "CPUUsage"; # Sort by CPU usage
          SortDirection = 0; # Sort in descending order
        };
        "com.apple.safari" = {
          UniversalSearchEnabled = false; # Disable universal search
          SuppressSearchSuggestions = true; # Disable search suggestions
          ShowFullURLInSmartSearchField = true; # Show full URL in the address bar
        };
        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true; # Enable automatic update checks
          ScheduleFrequency = 1; # Check for updates daily
          AutomaticDownload = true; # Automatically download updates
          CriticalUpdateInstall = true; # Install critical updates
        };
      };

      security.pam.services.sudo_local.touchIdAuth = true;

      system.activationScripts.postActivation.text = ''
        if [ ! -d "${targetDir}" ]; then
          echo "Creating ${targetDir} directory..."
          $DRY_RUN_CMD mkdir -p "${targetDir}"
        fi

        # Check if the Finner keyboard layout file exists
        if [ ! -f "${finnerPath}" ]; then
          echo "Finner keyboard layout file not found at ${finnerPath}. Please ensure it is built correctly."
          exit 1
        fi

        echo "Linking Finner keyboard layout to ${targetPath}..."
        if [ -L "${targetPath}" ]; then
          $DRY_RUN_CMD rm "${targetPath}"
        fi
        $DRY_RUN_CMD ln -sf "${finnerPath}" "${targetPath}"
      '';
    };
    # Create a derivation for the Finner keyboard layout using fetchurl
    finnerKeyboardLayout = let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      finnerFile = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/ruohola/finner/master/Finner.keylayout";
        sha256 = "sha256-IidFnfJseN2XP5MPN3pjBptftgHyGNmDKwPZwmJxfgo=";
      };
    in
      pkgs.stdenv.mkDerivation {
        name = "finner-keyboard-layout";

        # No src needed as we're using the fetchurl result directly
        dontUnpack = true;

        # Just install the file
        installPhase = ''
          mkdir -p $out
          cp ${finnerFile} $out/Finner.keylayout
        '';
      };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Timos-MacBook-Air
    darwinConfigurations."Timos-MacBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        ({config, ...}: {
          homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
        })
        # Add home-manager module
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users."${username}" = {pkgs, ...}: {
              # Your home-manager configuration
              home.stateVersion = "24.11"; # Adjust accordingly

              # Example configurations
              home.packages = with pkgs; [
                # Add user-specific packages here
              ];

              # Programs that can be managed by home-manager
              programs.git = {
                enable = true;
                settings = {
                  user = {
                    name = "tmyllymaki";
                    email = "tmyllymaki@fastmail.com";
                  };
                };
              };

              # Create symbolic link for Finner keyboard layout
              home.activation = {
              };

              # Fish shell configuration
              # programs.fish = {
              #   enable = true;
              #   interactiveShellInit = ''
              #     # Fish shell initialization commands here
              #     set fish_greeting # Disable greeting
              #   '';
              #   plugins = [
              #     # Fish plugins can be added here
              #   ];
              # };
            };
          };
        }
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "tm";

            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "qmk/homebrew-qmk" = homebrew-qmk;
              "osx-cross/homebrew-avr" = homebrew-avr;
              "osx-cross/homebrew-arm" = homebrew-arm;
              "nikitabobko/tap" = homebrew-tap-nikita;
              "FelixKratz/formulae" = homebrew-tap-sketchybar;
            };
            mutableTaps = true;
          };
        }
      ];
    };

    # Make the keyboard layout available as a package
    packages.aarch64-darwin.finnerKeyboardLayout = finnerKeyboardLayout;
  };
}

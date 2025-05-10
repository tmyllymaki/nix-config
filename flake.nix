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

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    homebrew-emacs-plus = {
      url = "github:d12frosted/homebrew-emacs-plus";
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

    nvf.url = "github:notashelf/nvf";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    homebrew-emacs-plus,
    homebrew-qmk,
    homebrew-avr,
    homebrew-arm,
    nvf,
    ...
  }: let
    username = "tm";
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
        customNeovim.neovim
        pkgs.git
        pkgs.fish
        pkgs.ripgrep
        pkgs.fzf
        pkgs.btop
        pkgs.eza
        pkgs.zoxide
        pkgs.starship
        pkgs.pipx
        pkgs.nixd
        pkgs.ncdu
        pkgs.gh
        pkgs.alejandra
        finnerKeyboardLayout
      ];

      homebrew = {
        enable = true;
        onActivation = {
          cleanup = "none";
          upgrade = true;
        };
        brews = [
          "jj"
          "croc"
          "dotnet"
          "elixir"
          "emacs-plus@30"
          "exercism"
          "iperf3"
          "mono-libgdiplus"
          "mpv"
          "pipx"
          "python@3.13"
          "qmk/qmk/qmk"
          "swiftformat"
          "swiftlint"
          "xcodegen"
          "yadm"
          "zsh-vi-mode"
        ];
        casks = [
          "1password-cli"
          "1password"
          "alt-tab"
          "discord"
          "docker"
          "easy-move+resize"
          "flashspace"
          "font-jetbrains-mono-nerd-font"
          "garmin-express"
          "hammerspoon"
          "hiddenbar"
          "jetbrains-toolbox"
          "leader-key"
          "middleclick"
          "orbstack"
          "qmk-toolbox"
          "signal"
          "spotify"
          "tailscale"
          "visual-studio-code"
          "warp"
          "wezterm@nightly"
          "whatsapp"
          "zed"
          "zen-browser"
        ];
      };

      #nix.nixPath = ["nixpkgs=${nixpkgs}"];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToEscape = true;
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
    customNeovim = inputs.nvf.lib.neovimConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [./nvf-configuration.nix];
    };
  in {
    packages.aarch64-darwin.default = customNeovim.neovim;

    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Timos-MacBook-Air
    darwinConfigurations."Timos-MacBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nvf.nixosModules.default
        nix-homebrew.darwinModules.nix-homebrew
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
                userName = "tmyllymaki"; # Change this to your name
                userEmail = "tmyllymaki@fastmail.com"; # Change this to your email
              };

              # Create symbolic link for Finner keyboard layout
              home.activation = {
                linkFinnerKeyboardLayout = let
                  finnerPath = "${finnerKeyboardLayout}/Finner.keylayout";
                  targetDir = "/Library/Keyboard Layouts";
                  targetPath = "${targetDir}/Finner.keylayout";
                in
                  home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
                    if [ ! -d "${targetDir}" ]; then
                      echo "Creating ${targetDir} directory..."
                      $DRY_RUN_CMD mkdir -p "${targetDir}"
                    fi

                    echo "Linking Finner keyboard layout to ${targetPath}..."
                    if [ -L "${targetPath}" ]; then
                      $DRY_RUN_CMD rm "${targetPath}"
                    fi
                    $DRY_RUN_CMD ln -sf "${finnerPath}" "${targetPath}"
                  '';
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
              "homebrew/homebrew-bundle" = homebrew-bundle;
              "d12frosted/homebrew-emacs-plus" = homebrew-emacs-plus;
              "qmk/homebrew-qmk" = homebrew-qmk;
              "osx-cross/homebrew-avr" = homebrew-avr;
              "osx-cross/homebrew-arm" = homebrew-arm;
            };
            mutableTaps = false;
          };
        }
      ];
    };

    # Make the keyboard layout available as a package
    packages.aarch64-darwin.finnerKeyboardLayout = finnerKeyboardLayout;
    packages.aarch64-darwin.customNeovim = customNeovim;
  };
}

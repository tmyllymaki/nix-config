{
  flake.nixosMachineModules.laptop = {inputs, ...}: {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = "aarch64-darwin";

    nixpkgs.overlays = [
      (final: prev: {
        mpv-unwrapped = prev.mpv-unwrapped.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [final.llvmPackages.lld];
          preConfigure =
            (old.preConfigure or "")
            + ''
              export LDFLAGS="-fuse-ld=lld $LDFLAGS"
            '';
        });
      })
    ];

    system.stateVersion = 6;
    system.primaryUser = "tm";
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    security.pam.services.sudo_local.touchIdAuth = true;

    nix = {
      optimise.automatic = true;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        substituters = [
          "https://nix-community.cachix.org/"
          "https://cache.nixos.org/"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    environment.variables.NH_FLAKE = "/etc/nix-darwin";

    # Enable system modules
    custom.quickenable.system.modules = [
      "homebrew"
      "defaults"
      "shell"
      # "omniwm"
    ];

    # Restart Raycast after darwin-rebuild switch to fix Hyper Key / Escape
    # The activation reloads launchd and modifies /Applications, which invalidates
    # Raycast's CGEventTap (used for Hyper Key) due to macOS TCC permission anchoring.
    # Killing and reopening Raycast re-registers the event tap.
    # Must use postActivation (not a custom key) — nix-darwin only executes hardcoded
    # script names listed in activation-scripts.nix (see nix-darwin#663).
    system.activationScripts.postActivation.text = ''
      if pkill -x "Raycast Beta" 2>/dev/null; then
        sleep 2
      fi
      su - tm -c "open -a 'Raycast Beta'" 2>/dev/null || true
    '';

    # nix-homebrew declarative tap management
    nix-homebrew = {
      enable = true;
      enableRosetta = true;
      user = "tm";
      taps = {
        "homebrew/homebrew-core" = inputs.homebrew-core;
        "homebrew/homebrew-cask" = inputs.homebrew-cask;
        "qmk/homebrew-qmk" = inputs.homebrew-qmk;
        "osx-cross/homebrew-avr" = inputs.homebrew-avr;
        "osx-cross/homebrew-arm" = inputs.homebrew-arm;
        "nikitabobko/homebrew-tap" = inputs.homebrew-tap-nikita;
        "felixkratz/homebrew-formulae" = inputs.homebrew-tap-sketchybar;
        "johnsideserf/homebrew-siggy" = inputs.homebrew-tap-siggy;
        "junian/homebrew-dotnet" = inputs.homebrew-tap-dotnet;
      };
      trust = {
        taps = [
          "homebrew/homebrew-core"
          "homebrew/homebrew-cask"
          "qmk/homebrew-qmk"
          "osx-cross/homebrew-avr"
          "osx-cross/homebrew-arm"
          "nikitabobko/homebrew-tap"
          "felixkratz/homebrew-formulae"
          "johnsideserf/homebrew-siggy"
          "junian/homebrew-dotnet"
        ];
      };
      mutableTaps = false;
    };
  };
}

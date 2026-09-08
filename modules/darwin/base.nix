{
  flake.darwinModules.base = {
    config,
    inputs,
    lib,
    ...
  }: {
    options.custom.system.base.enable = lib.mkEnableOption "system.base";

    config = lib.mkIf config.custom.system.base.enable {
      nixpkgs.config.allowUnfree = true;
      # Both Macs are Apple Silicon.
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
          extra-substituters = ["https://cache.numtide.com"];
          extra-trusted-public-keys = [
            "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
          ];
        };
      };

      # nix-homebrew declarative tap management. `user` defaults to
      # config.custom.user.name via modules/options/user.nix.
      nix-homebrew = {
        enable = true;
        enableRosetta = true;
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
          "guria/homebrew-tap" = inputs.homebrew-tap-guria;
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
            "guria/homebrew-tap"
          ];
        };
        mutableTaps = false;
      };
    };
  };
}

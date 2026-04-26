{
  flake.nixosMachineModules.laptop = {inputs, ...}: {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = "aarch64-darwin";

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
      "omniwm"
    ];

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
      };
      mutableTaps = false;
    };
  };
}

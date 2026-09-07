{
  flake.nixosMachineModules.laptop = {
    custom.user.name = "tm";

    environment.variables.NH_FLAKE = "/etc/nix-darwin";

    custom.system.homebrew = {
      extraBrews = [
        "qmk/qmk/qmk"
        "swiftlint"
      ];
      # Apple's container CLI ships as a cask here; work uses the formula.
      extraCasks = ["container"];
    };

    # Enable system modules
    custom.quickenable.system.modules = [
      "base"
      "homebrew"
      "defaults"
      "shell"
    ];
  };
}

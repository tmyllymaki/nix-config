{
  flake.nixosMachineModules.laptop = {
    custom.user.name = "tm";

    environment.variables.NH_FLAKE = "/etc/nix-darwin";

    custom.system.homebrew = {
      extraBrews = [
        "qmk/qmk/qmk"
        "swiftlint"
        "exercism"
        "elixir"
        "portaudio"
        "sketchybar"
      ];
      # Apple's container CLI ships as a cask here; work uses the formula.
      extraCasks = [
        "container"
        "zed"
        "plex"
      ];
    };

    # Enable system modules
    custom.quickenable.system.modules = [
      "base"
      "homebrew"
      "defaults"
      "shell"
      "paneru"
    ];
  };
}

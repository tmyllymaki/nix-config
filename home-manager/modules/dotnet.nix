{
  pkgs,
  lib,
  config,
  ...
}: let
  dotnet-package = pkgs.dotnet-sdk_8;
in {
  # nixpkgs.overlays = [(import ../../programs/rider-overlay.nix)];
  home.packages = [
    dotnet-package
  ];

  home = {
    sessionVariables = {
      DOTNET_ROOT = "${dotnet-package}";
      LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${lib.makeLibraryPath [pkgs.icu]}";
    };
  };
}

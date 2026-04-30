{
  flake.hjemModules.dotnet = {
    config,
    lib,
    pkgs,
    ...
  }: let
    dotnet-package = pkgs.dotnet-sdk_8;
  in {
    options.custom.home.dotnet.enable = lib.mkEnableOption "home.dotnet";

    config = lib.mkIf config.custom.home.dotnet.enable {
      packages = [dotnet-package];

      environment.sessionVariables = {
        DOTNET_ROOT = "${dotnet-package}";
        LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${lib.makeLibraryPath [pkgs.icu]}";
      };
    };
  };
}

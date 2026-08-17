{
  flake.hjemModules.dotnet = {
    config,
    lib,
    pkgs,
    ...
  }: let
    dotnet-package = pkgs.dotnet-sdk_11;
  in {
    options.custom.home.dotnet.enable = lib.mkEnableOption "home.dotnet";

    config = lib.mkIf config.custom.home.dotnet.enable {
      packages = [dotnet-package];

      environment.sessionVariables = {
        # nixpkgs dotnet packages are laid out as $out/share/dotnet; DOTNET_ROOT
        # must point at the dir containing the dotnet binary and shared/ runtime.
        DOTNET_ROOT = "${dotnet-package}/share/dotnet";
        LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:${lib.makeLibraryPath [pkgs.icu]}";
      };
    };
  };
}

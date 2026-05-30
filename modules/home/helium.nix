{
  flake.hjemModules.helium = {
    config,
    lib,
    extras,
    ...
  }: {
    options.custom.home.helium.enable = lib.mkEnableOption "home.helium";
    config = lib.mkIf config.custom.home.helium.enable {
      packages = [
        extras.mypkgs.helium
      ];
    };
  };
}

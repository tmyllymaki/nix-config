{
  flake.hjemModules.siggy = {
    config,
    lib,
    pkgs,
    extras,
    ...
  }: {
    options.custom.home.siggy.enable = lib.mkEnableOption "home.siggy";
    config = lib.mkIf config.custom.home.siggy.enable {
      packages = [
        extras.mypkgs.siggy
        pkgs.signal-cli
      ];
    };
  };
}

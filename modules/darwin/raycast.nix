{
  flake.hjemModules.raycast = {
    config,
    lib,
    extras,
    ...
  }: {
    options.custom.home.raycast.enable = lib.mkEnableOption "home.raycast";
    config = lib.mkIf config.custom.home.raycast.enable {
      packages = [
        extras.mypkgs.raycast
      ];
    };
  };
}

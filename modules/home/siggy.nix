{
  flake.hjemModules.siggy = { config, lib, pkgs, ... }: {
    options.custom.home.siggy.enable = lib.mkEnableOption "home.siggy";
    config = lib.mkIf config.custom.home.siggy.enable {
      packages = [ pkgs.siggy ];
    };
  };
}

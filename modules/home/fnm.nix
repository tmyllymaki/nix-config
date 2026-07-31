{
  flake.hjemModules.fnm = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.home.fnm.enable = lib.mkEnableOption "home.fnm";
    config = lib.mkIf config.custom.home.fnm.enable {
      packages = [ pkgs.fnm ];
    };
  };
}

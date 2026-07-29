{
  flake.hjemModules.mise = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.home.mise.enable = lib.mkEnableOption "home.mise";
    config = lib.mkIf config.custom.home.mise.enable {
      packages = [pkgs.mise];
      xdg.config.files."mise" = {
        clobber = true;
        source = ../../dotfiles/mise;
      };
    };
  };
}

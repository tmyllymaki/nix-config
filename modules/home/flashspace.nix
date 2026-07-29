{
  flake.hjemModules.flashspace = {
    config,
    lib,
    ...
  }: {
    options.custom.home.flashspace.enable = lib.mkEnableOption "home.flashspace";
    config = lib.mkIf config.custom.home.flashspace.enable {
      xdg.config.files."flashspace" = {
        clobber = true;
        source = ../../dotfiles/flashspace;
      };
    };
  };
}

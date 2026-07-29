{
  flake.hjemModules.ghostty = {
    config,
    lib,
    ...
  }: {
    options.custom.home.ghostty.enable = lib.mkEnableOption "home.ghostty";
    config = lib.mkIf config.custom.home.ghostty.enable {
      xdg.config.files."ghostty" = {
        clobber = true;
        source = ../../dotfiles/ghostty;
      };
    };
  };
}

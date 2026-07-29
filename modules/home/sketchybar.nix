{
  flake.hjemModules.sketchybar = {
    config,
    lib,
    ...
  }: {
    options.custom.home.sketchybar.enable = lib.mkEnableOption "home.sketchybar";
    config = lib.mkIf config.custom.home.sketchybar.enable {
      xdg.config.files."sketchybar" = {
        clobber = true;
        source = ../../dotfiles/sketchybar;
      };
    };
  };
}

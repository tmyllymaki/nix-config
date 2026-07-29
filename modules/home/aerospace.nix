{
  flake.hjemModules.aerospace = {
    config,
    lib,
    ...
  }: {
    options.custom.home.aerospace.enable = lib.mkEnableOption "home.aerospace";

    config = lib.mkIf config.custom.home.aerospace.enable {
      xdg.config.files."aerospace/aerospace.toml" = {
        clobber = true;
        source = ../../dotfiles/.config/aerospace/aerospace.toml;
      };
    };
  };
}

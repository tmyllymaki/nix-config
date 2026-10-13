{
  flake.hjemModules.dinky = {
    config,
    lib,
    ...
  }: {
    options.custom.home.dinky.enable = lib.mkEnableOption "home.dinky";
    config = lib.mkIf config.custom.home.dinky.enable {
      # Link only the file: dinky writes a default dinky.toml on first run,
      # and clobber replaces that copy.
      xdg.config.files."dinky/dinky.toml" = {
        clobber = true;
        source = ../../dotfiles/dinky/dinky.toml;
      };
    };
  };
}

{
  flake.hjemModules.wezterm = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.home.wezterm.enable = lib.mkEnableOption "home.wezterm";
    config = lib.mkIf config.custom.home.wezterm.enable {
      packages = [pkgs.wezterm];
      environment.sessionVariables.TERM = "wezterm";
      xdg.config.files."wezterm" = {
        clobber = true;
        source = ../../dotfiles/wezterm;
      };
    };
  };
}

{
  flake.hjemModules.wezterm = {
    config,
    lib,
    pkgs,
    ...
  }: let
    dir = ../../dotfiles/.config/wezterm;
    mkSource = path: {
      clobber = true;
      source = dir + "/${path}";
    };
  in {
    options.custom.home.wezterm.enable = lib.mkEnableOption "home.wezterm";

    config = lib.mkIf config.custom.home.wezterm.enable {
      packages = [pkgs.wezterm];

      environment.sessionVariables.TERM = "wezterm";

      xdg.config.files = {
        "wezterm/wezterm.lua" = mkSource "wezterm.lua";
        "wezterm/appearance.lua" = mkSource "appearance.lua";
        "wezterm/projects.lua" = mkSource "projects.lua";
        "wezterm/util.lua" = mkSource "util.lua";
      };
    };
  };
}

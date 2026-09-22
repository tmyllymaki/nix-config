{
  flake.hjemModules.wezterm = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.home.wezterm = {
      enable = lib.mkEnableOption "home.wezterm";
      theme = lib.mkOption {
        type = lib.types.enum ["kanso" "kanagawa-paper" "github"];
        default = "kanso";
        description = ''
          Color theme family shared by WezTerm, fish and Neovim. Written to
          ~/.config/color-theme, which each of them reads at startup.
        '';
      };
    };
    config = lib.mkIf config.custom.home.wezterm.enable {
      packages = [pkgs.wezterm];
      environment.sessionVariables.TERM = "wezterm";
      xdg.config.files."color-theme".text = config.custom.home.wezterm.theme + "\n";
      xdg.config.files."wezterm" = {
        clobber = true;
        source = ../../dotfiles/wezterm;
      };
    };
  };
}

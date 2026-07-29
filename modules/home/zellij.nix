{
  flake.hjemModules.zellij = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.home.zellij.enable = lib.mkEnableOption "home.zellij";
    config = lib.mkIf config.custom.home.zellij.enable {
      packages = [pkgs.zellij];
      xdg.config.files."zellij" = {
        clobber = true;
        source = ../../dotfiles/zellij;
      };
    };
  };
}

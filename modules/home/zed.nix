{
  flake.hjemModules.zed = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.home.zed.enable = lib.mkEnableOption "home.zed";

    config = lib.mkIf config.custom.home.zed.enable {
      packages = [pkgs.zed-editor-fhs];
    };
  };
}

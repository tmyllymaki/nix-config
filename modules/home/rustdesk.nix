{
  flake.hjemModules.rustdesk = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.home.rustdesk.enable = lib.mkEnableOption "home.rustdesk";

    config = lib.mkIf config.custom.home.rustdesk.enable {
      packages = with pkgs; [
        rustdesk-flutter
      ];
    };
  };
}

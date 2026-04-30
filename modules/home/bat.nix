{
  flake.hjemModules.bat = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.home.bat.enable = lib.mkEnableOption "home.bat";

    config = lib.mkIf config.custom.home.bat.enable {
      packages = [pkgs.bat];

      xdg.config.files."bat/config".text = ''
        --theme="ansi"
      '';
    };
  };
}

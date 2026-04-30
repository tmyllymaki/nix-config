{
  flake.hjemModules.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: let
    desktopFiles = ../../machines/desktop/home/files;
    mkSource = path: {
      clobber = true;
      source = path;
    };
  in {
    options.custom.home.desktop.enable = lib.mkEnableOption "home.desktop";

    config = lib.mkIf config.custom.home.desktop.enable {
      packages = with pkgs; [
        faugus-launcher
        umu-launcher
	discord
	teamspeak3
	teamspeak6-client
      ];

      xdg.config.files = {
        "faugus-launcher/config.ini" = mkSource (desktopFiles + "/faugus-launcher/config.ini");
        "faugus-launcher/games.json" = mkSource (desktopFiles + "/faugus-launcher/games.json");
        "mimeapps.list" = mkSource (desktopFiles + "/mimeapps.list");
        "niri/config.kdl" = mkSource (desktopFiles + "/niri/config.kdl");
        "niri/toggle_mute.sh" = mkSource (desktopFiles + "/niri/toggle_mute.sh");
        "noctalia/colors.json" = mkSource (desktopFiles + "/noctalia/colors.json");
        "noctalia/plugins.json" = mkSource (desktopFiles + "/noctalia/plugins.json");
        "noctalia/settings.json" = mkSource (desktopFiles + "/noctalia/settings.json");
        "xkb/symbols/finner" = mkSource (desktopFiles + "/xkb/symbols/finner");
      };
    };
  };
}

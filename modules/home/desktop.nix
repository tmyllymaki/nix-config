{
  flake.hjemModules.desktop = {
    config,
    lib,
    pkgs,
    ...
  }: let
    desktopFiles = ../../machines/desktop/home/files;
    toggleSounds = pkgs.runCommand "toggle-sounds" {nativeBuildInputs = [pkgs.sox];} ''
      mkdir -p $out
      sox "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/dialog-error.oga" \
        -b 16 "$out/mute.wav" vol 5
      sox "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/bell.oga" \
        -b 16 "$out/unmute.wav" vol 5
    '';
    mkSource = path: {
      clobber = true;
      source = path;
    };
  in {
    options.custom.home.desktop.enable = lib.mkEnableOption "home.desktop";

    config = lib.mkIf config.custom.home.desktop.enable {
      packages = with pkgs; [
        umu-launcher
        discord
        teamspeak6-client
        lxqt.lxqt-policykit
      ];

      xdg.config.files = {
        # "faugus-launcher/config.ini" = mkSource (desktopFiles + "/faugus-launcher/config.ini");
        # "faugus-launcher/games.json" = mkSource (desktopFiles + "/faugus-launcher/games.json");
        "mimeapps.list" = mkSource (desktopFiles + "/mimeapps.list");
        "niri/config.kdl" = mkSource (desktopFiles + "/niri/config.kdl");
        "niri/toggle_mute.sh" = {
          clobber = true;
          source = pkgs.writeShellScript "toggle_mute.sh" ''
            muted=$(${pkgs.pamixer}/bin/pamixer --default-source --get-mute)
            ${pkgs.pamixer}/bin/pamixer --default-source --toggle-mute
            if [ "$muted" = "true" ]; then
              pw-play "${toggleSounds}/unmute.wav" &
            else
              pw-play "${toggleSounds}/mute.wav" &
            fi
          '';
        };
        "noctalia/colors.json" = mkSource (desktopFiles + "/noctalia/colors.json");
        "noctalia/plugins.json" = mkSource (desktopFiles + "/noctalia/plugins.json");
        "noctalia/settings.json" = mkSource (desktopFiles + "/noctalia/settings.json");
        "xkb/symbols/finner" = mkSource (desktopFiles + "/xkb/symbols/finner");
      };
    };
  };
}

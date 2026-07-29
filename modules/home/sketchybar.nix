{
  flake.hjemModules.sketchybar = {
    config,
    lib,
    ...
  }: let
    dir = ../../dotfiles/.config/sketchybar;
    mkSource = path: {
      clobber = true;
      source = dir + "/${path}";
    };
  in {
    options.custom.home.sketchybar.enable = lib.mkEnableOption "home.sketchybar";

    config = lib.mkIf config.custom.home.sketchybar.enable {
      xdg.config.files = {
        "sketchybar/sketchybarrc" = mkSource "sketchybarrc";
        "sketchybar/plugins/aerospace.sh" = mkSource "plugins/aerospace.sh";
        "sketchybar/plugins/battery.sh" = mkSource "plugins/battery.sh";
        "sketchybar/plugins/clock.sh" = mkSource "plugins/clock.sh";
        "sketchybar/plugins/front_app.sh" = mkSource "plugins/front_app.sh";
        "sketchybar/plugins/ip_address.sh" = mkSource "plugins/ip_address.sh";
        "sketchybar/plugins/network.sh" = mkSource "plugins/network.sh";
        "sketchybar/plugins/slack.sh" = mkSource "plugins/slack.sh";
        "sketchybar/plugins/space.sh" = mkSource "plugins/space.sh";
        "sketchybar/plugins/volume.sh" = mkSource "plugins/volume.sh";
      };
    };
  };
}

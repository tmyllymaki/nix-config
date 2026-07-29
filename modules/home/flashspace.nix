{
  flake.hjemModules.flashspace = {
    config,
    lib,
    ...
  }: let
    dir = ../../dotfiles/.config/flashspace;
    mkSource = path: {
      clobber = true;
      source = dir + "/${path}";
    };
  in {
    options.custom.home.flashspace.enable = lib.mkEnableOption "home.flashspace";

    config = lib.mkIf config.custom.home.flashspace.enable {
      xdg.config.files = {
        "flashspace/profiles.json" = mkSource "profiles.json";
        "flashspace/settings.json" = mkSource "settings.json";
      };
    };
  };
}

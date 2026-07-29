{
  flake.hjemModules.ghostty = {
    config,
    lib,
    pkgs,
    ...
  }: let
    dir = ../../dotfiles/.config/ghostty;
    mkSource = path: {
      clobber = true;
      source = dir + "/${path}";
    };
  in {
    options.custom.home.ghostty.enable = lib.mkEnableOption "home.ghostty";

    config = lib.mkIf config.custom.home.ghostty.enable {
      xdg.config.files = {
        "ghostty/config" = mkSource "config";
        "ghostty/themes/modus_operandi" = mkSource "themes/modus_operandi";
        "ghostty/themes/modus_vivendi" = mkSource "themes/modus_vivendi";
      };
    };
  };
}

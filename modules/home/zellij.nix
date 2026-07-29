{
  flake.hjemModules.zellij = {
    config,
    lib,
    pkgs,
    ...
  }: let
    dir = ../../dotfiles/.config/zellij;
    mkSource = path: {
      clobber = true;
      source = dir + "/${path}";
    };
  in {
    options.custom.home.zellij.enable = lib.mkEnableOption "home.zellij";

    config = lib.mkIf config.custom.home.zellij.enable {
      packages = [pkgs.zellij];

      xdg.config.files = {
        "zellij/config.kdl" = mkSource "config.kdl";
        "zellij/layouts/my-custom.kdl" = mkSource "layouts/my-custom.kdl";
        "zellij/layouts/naked.kdl" = mkSource "layouts/naked.kdl";
        "zellij/layouts/zcompact.kdl" = mkSource "layouts/zcompact.kdl";
        "zellij/layouts/zjstatus.kdl" = mkSource "layouts/zjstatus.kdl";
        "zellij/themes/modus_operandi.kdl" = mkSource "themes/modus_operandi.kdl";
        "zellij/themes/modus_vivendi.kdl" = mkSource "themes/modus_vivendi.kdl";
        "zellij/plugins/room.wasm" = mkSource "plugins/room.wasm";
        "zellij/plugins/zellij_forgot.wasm" = mkSource "plugins/zellij_forgot.wasm";
        "zellij/plugins/zellij-sessionizer.wasm" = mkSource "plugins/zellij-sessionizer.wasm";
        "zellij/plugins/zjstatus.wasm" = mkSource "plugins/zjstatus.wasm";
      };
    };
  };
}

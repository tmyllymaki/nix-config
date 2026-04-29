{
  flake.hjemModules.atuin = {
    config,
    lib,
    ...
  }: {
    options.custom.home.atuin.enable = lib.mkEnableOption "home.atuin";

    config = lib.mkIf config.custom.home.atuin.enable {
      xdg.config.files."atuin/config.toml" = {
        text = ''
          search_mode = "fuzzy"

          [keybindings]
          enter = "edit"
        '';
      };
    };
  };
}


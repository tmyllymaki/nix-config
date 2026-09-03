{
  flake.hjemModules.atuin = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.home.atuin.enable = lib.mkEnableOption "home.atuin";

    config = lib.mkIf config.custom.home.atuin.enable {
      packages = [pkgs.atuin];

      # Source of truth for atuin settings. Previous versions of this config
      # were kept in the real file on disk (which hjem refused to clobber);
      # clobber = true makes hjem own it again.
      xdg.config.files."atuin/config.toml" = {
        text = ''
          workspaces = true
          filter_mode_shell_up_key_binding = "session"
          search_mode_shell_up_key_binding = "daemon-fuzzy"
          style = "compact"
          inline_height = 20
          ctrl_n_shortcuts = true
          enter_accept = false
          search_mode = "daemon-fuzzy"

          [daemon]
          enabled = true
          autostart = true

          [sync]
          # sync v2
          records = true
        '';
        clobber = true;
      };
    };
  };
}

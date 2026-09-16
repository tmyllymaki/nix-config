{
  flake.darwinModules.paneru = {
    config,
    lib,
    ...
  }: {
    options.custom.system.paneru.enable = lib.mkEnableOption "system.paneru";

    config = lib.mkIf config.custom.system.paneru.enable {
      # Upstream ships a flake with a nix-darwin module (package + launchd agent),
      # but that package builds paneru from source with crane and isn't in
      # nixpkgs, so the formula stays the install path for now.
      custom.system.homebrew.extraBrews = ["paneru"];

      # paneru reads $XDG_CONFIG_HOME/paneru/init.lua, and an init.lua wins
      # outright over any paneru.toml. hjem links that path at dotfiles/paneru,
      # so edits here hot-reload the running daemon; enabling the module itself
      # needs `nh darwin switch . -H <machine>`. The daemon that runs the brew
      # binary is the hand-written
      # ~/Library/LaunchAgents/com.github.karinushka.paneru.plist, which already
      # sets XDG_CONFIG_HOME -- nothing here touches it.
      hjem.users.${config.custom.user.name}.xdg.config.files."paneru/init.lua" = {
        clobber = true;
        source = ../../dotfiles/paneru/init.lua;
      };
    };
  };
}

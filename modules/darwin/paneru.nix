{
  flake.darwinModules.paneru = {
    config,
    inputs,
    lib,
    ...
  }: {
    # Upstream's darwin module installs the package, passes dotfiles/paneru/init.lua
    # in via `PANERU_LUA` and runs paneru as the primary user's launchd agent
    # (it needs `system.primaryUser`, which modules/options/user.nix sets).
    imports = [inputs.paneru.darwinModules.paneru];

    options.custom.system.paneru.enable = lib.mkEnableOption "system.paneru";

    config = lib.mkIf config.custom.system.paneru.enable {
      services.paneru = {
        enable = true;
        config = ../../dotfiles/paneru/init.lua;
      };
    };
  };
}

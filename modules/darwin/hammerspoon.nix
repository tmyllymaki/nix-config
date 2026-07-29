{
  flake.hjemModules.hammerspoon = {
    config,
    lib,
    extras,
    ...
  }: {
    options.custom.home.hammerspoon.enable = lib.mkEnableOption "home.hammerspoon";
    config = lib.mkIf config.custom.home.hammerspoon.enable {
      packages = [
        extras.mypkgs.hammerspoon
      ];

      files.".hammerspoon" = {
        clobber = true;
        source = ../../dotfiles/.hammerspoon;
      };
    };
  };
}

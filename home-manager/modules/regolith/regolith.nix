{
  config,
  pkgs,
  lib,
  ...
}: {
  #xdg.configFile."regolith3".source = ./config;
  # This is a hack to make files editable outside of home-manager
  xdg.configFile."regolith3".source = config.lib.file.mkOutOfStoreSymlink "/home/tm/nixos/home-manager/modules/regolith/config";
}

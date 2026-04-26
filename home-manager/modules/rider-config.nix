{
  config,
  pkgs,
  lib,
  ...
}: let
  intellimacs = pkgs.fetchgit {
    url = "https://github.com/tmyllymaki/intellimacs.git";
    rev = "116e566bafb4c7fe9a2962a746281053e59b1f49";
    sha256 = "Aomn1sS2ZlruWy8UMKkPLn1bOX3kLThRTgLgzFUo/yk=";
  };
in {
  # This is a hack to make .ideavimrc editable outside of home-manager
  #home.file.".ideavimrc".source = config.lib.file.mkOutOfStoreSymlink "/home/tm/nixos/home-manager/modules/.ideavimrc";
  home.file.".ideavimrc".source = ./.ideavimrc;
  home.file.".intellimacs".source = intellimacs;
}

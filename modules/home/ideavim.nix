{
  flake.hjemModules.ideavim = {
    config,
    lib,
    ...
  }: {
    options.custom.home.ideavim.enable = lib.mkEnableOption "home.ideavim";

    config = lib.mkIf config.custom.home.ideavim.enable {
      files.".ideavimrc" = {
        clobber = true;
        source = ../../dotfiles/.ideavimrc;
      };
    };
  };
}

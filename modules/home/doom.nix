{
  flake.hjemModules.doom = {
    config,
    lib,
    ...
  }: let
    dir = ../../dotfiles/.config/doom;
    mkSource = path: {
      clobber = true;
      source = dir + "/${path}";
    };
  in {
    options.custom.home.doom.enable = lib.mkEnableOption "home.doom";

    config = lib.mkIf config.custom.home.doom.enable {
      xdg.config.files = {
        "doom/config.el" = mkSource "config.el";
        "doom/init.el" = mkSource "init.el";
        "doom/packages.el" = mkSource "packages.el";
        "doom/lisp/mise-tasks.el" = mkSource "lisp/mise-tasks.el";
        "doom/lisp/razor-ts-mode.el" = mkSource "lisp/razor-ts-mode.el";
        "doom/lisp/roslyn-razor.el" = mkSource "lisp/roslyn-razor.el";
      };
    };
  };
}

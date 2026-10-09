{
  # NOTE: doom uses individual file symlinks instead of a directory symlink
  # because doom's package manager (straight.el) writes to .config/doom/ at
  # runtime. A directory symlink would send those writes into the repo.
  #
  # The symlinks point at the repo checkout rather than the nix store, so edits
  # made from Emacs take effect immediately without a rebuild. An absolute path
  # given as a string is not copied into the store by the `path` option type.
  flake.hjemModules.doom = {
    config,
    lib,
    ...
  }: let
    cfg = config.custom.home.doom;
    mkSource = path: {
      clobber = true;
      source = "${cfg.repoDir}/dotfiles/doom/${path}";
    };
  in {
    options.custom.home.doom = {
      enable = lib.mkEnableOption "home.doom";

      repoDir = lib.mkOption {
        type = lib.types.str;
        default = "${config.directory}/nix-darwin";
        description = "Absolute path of this repository's checkout on the machine.";
      };
    };

    config = lib.mkIf cfg.enable {
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

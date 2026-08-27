{
  flake.hjemModules.git = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.custom.home.git;
  in {
    options.custom.home.git = {
      enable = lib.mkEnableOption "home.git";

      userName = lib.mkOption {
        type = lib.types.str;
        default = "tmyllymaki";
        description = "Value for git's user.name.";
      };

      userEmail = lib.mkOption {
        type = lib.types.str;
        default = "tmyllymaki@fastmail.com";
        example = "timo.myllymaki@paretosoftware.fi";
        description = "Value for git's user.email.";
      };
    };

    config = lib.mkIf cfg.enable {
      packages = [pkgs.git];

      xdg.config.files."git/config" = {
        generator = lib.generators.toGitINI;
        clobber = true;
        value = {
          user = {
            name = cfg.userName;
            email = cfg.userEmail;
          };
          init.defaultBranch = "main";
          rerere = {
            enabled = true;
            autoUpdate = true;
          };
        };
      };
    };
  };
}

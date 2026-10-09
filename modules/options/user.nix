{
  flake.darwinModules.user = {
    config,
    lib,
    ...
  }: let
    cfg = config.custom.user;
  in {
    # The primary (and only) human user of a Darwin machine. Machines differ in
    # login name - `tm` personally, `tmyllymaki` for work - so shared modules
    # read this instead of hardcoding either.
    options.custom.user = {
      name = lib.mkOption {
        type = lib.types.str;
        example = "tm";
        description = "Login name of the machine's primary user.";
      };

      home = lib.mkOption {
        type = lib.types.str;
        default = "/Users/${cfg.name}";
        defaultText = lib.literalExpression ''"/Users/''${config.custom.user.name}"'';
        description = "Home directory of the machine's primary user.";
      };

      # Additional login users managed by hjem. They share the system config
      # (Homebrew, fonts, system.defaults) with the primary user, which alone
      # owns Homebrew and receives system.primaryUser settings. The macOS
      # account itself must be created in System Settings first.
      extraUsers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["tm"];
        description = "Login names of additional users, each with a home in /Users/<name>.";
      };
    };

    config = lib.mkMerge [
      {
        users.users.${cfg.name} = {
          inherit (cfg) name home;
        };

        system.primaryUser = cfg.name;
        nix-homebrew.user = lib.mkDefault cfg.name;
        hjem.users.${cfg.name}.directory = cfg.home;
      }
      {
        users.users = lib.genAttrs cfg.extraUsers (name: {
          inherit name;
          home = "/Users/${name}";
        });
        hjem.users = lib.genAttrs cfg.extraUsers (name: {
          directory = "/Users/${name}";
        });
      }
    ];
  };
}

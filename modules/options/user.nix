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
    };

    config = {
      users.users.${cfg.name} = {
        inherit (cfg) name home;
      };

      system.primaryUser = cfg.name;
      nix-homebrew.user = lib.mkDefault cfg.name;
      hjem.users.${cfg.name}.directory = cfg.home;
    };
  };
}

{
  flake.nixosMachineModules.laptop =
    { config, pkgs, ... }:
    {
      users.users.tm = {
        home = "/Users/tm";
        name = "tm";
      };

      hjem.users.tm = {
        directory = config.users.users.tm.home;

        custom.quickenable.hjem.modules = [
          "git"
          "omniwm"
        ];

        packages = [
          pkgs.supersonic
        ];
      };
    };
}

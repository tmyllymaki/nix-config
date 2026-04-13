{
  flake.hjemModules.git =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.custom.home.git.enable = lib.mkEnableOption "home.git";

      config = lib.mkIf config.custom.home.git.enable {
        packages = [ pkgs.git ];

        xdg.config.files."git/config" = {
          generator = lib.generators.toGitINI;
          value = {
            user = {
              name = "tmyllymaki";
              email = "tmyllymaki@fastmail.com";
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

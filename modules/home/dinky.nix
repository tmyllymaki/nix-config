{
  flake.hjemModules.dinky = {
    config,
    lib,
    pkgs,
    ...
  }: let
    maximize-toggle = pkgs.writeShellApplication {
      name = "dinky-maximize-toggle";
      runtimeInputs = [pkgs.coreutils pkgs.jq];
      # dinky comes from Homebrew, which apps launched at login lack on PATH.
      text = ''
        PATH="/opt/homebrew/bin:$PATH"
        ${builtins.readFile ../../dotfiles/dinky/maximize-toggle.sh}
      '';
    };
  in {
    options.custom.home.dinky.enable = lib.mkEnableOption "home.dinky";
    config = lib.mkIf config.custom.home.dinky.enable {
      # Link only the file: dinky writes a default dinky.toml on first run,
      # and clobber replaces that copy.
      xdg.config.files."dinky/dinky.toml" = {
        clobber = true;
        source = ../../dotfiles/dinky/dinky.toml;
      };
      xdg.config.files."dinky/maximize-toggle".source = lib.getExe maximize-toggle;
    };
  };
}

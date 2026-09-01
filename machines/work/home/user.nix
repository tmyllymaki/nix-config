{
  flake.nixosMachineModules.work = {
    config,
    pkgs,
    extras,
    ...
  }: {
    # users.users.<name> and hjem.users.<name>.directory come from
    # modules/options/user.nix; only per-machine app selection lives here.
    hjem.users.${config.custom.user.name} = {
      custom.home.git.userEmail = "timo.myllymaki@paretosoftware.fi";

      custom.quickenable.hjem.modules = [
        "git"
        "mpv"
        "llm-agents"
        "raycast"
        "hammerspoon"
        "wezterm"
        "doom"
        "aerospace"
        "flashspace"
        "sketchybar"
        "atuin"
        "mise"
        "fnm"
        "fish"
        "ghostty"
        "bat"
      ];

      packages = [
        pkgs.devenv
        pkgs.pandoc
        pkgs.typst
        # harlequin with the Databricks adapter (see packages/harlequin.nix);
        # plain pkgs.harlequin ships only the Postgres and BigQuery adapters.
        extras.mypkgs.harlequin
      ];
    };
  };
}

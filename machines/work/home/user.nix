{
  flake.nixosMachineModules.work = {
    config,
    pkgs,
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
      ];
    };
  };
}

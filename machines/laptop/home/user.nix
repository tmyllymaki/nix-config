{
  flake.nixosMachineModules.laptop = {config, ...}: {
    # users.users.<name> and hjem.users.<name>.directory come from
    # modules/options/user.nix; only per-machine app selection lives here.
    hjem.users.${config.custom.user.name} = {
      custom.quickenable.hjem.modules = [
        "git"
        "ssh"
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
        # pkgs.supersonic broken atm
      ];
    };
  };
}

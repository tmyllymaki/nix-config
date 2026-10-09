{
  flake.nixosMachineModules.work = {config, ...}: let
    # Personal login on the work Mac. Create the macOS account in System
    # Settings before switching; nix-darwin does not create it.
    name = "tm";
  in {
    custom.user.extraUsers = [name];

    # Copied from machines/laptop/home/user.nix as a starting point.
    hjem.users.${name} = {
      custom.quickenable.hjem.modules = [
        "git"
        "ssh"
        "mpv"
        "llm-agents"
        "raycast"
        "hammerspoon"
        "wezterm"
        "atuin"
        "mise"
        "fnm"
        "fish"
        "ghostty"
        "bat"
      ];

      packages = [
      ];
    };
  };
}

{
  flake.nixosMachineModules.laptop = {
    config,
    pkgs,
    ...
  }: {
    users.users.tm = {
      home = "/Users/tm";
      name = "tm";
    };

    hjem.users.tm = {
      directory = config.users.users.tm.home;

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
        "ideavim"
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

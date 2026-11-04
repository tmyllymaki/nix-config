{
  flake.nixosModules.shadps4 = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.system.shadps4.enable = lib.mkEnableOption "system.shadps4";

    config = lib.mkIf config.custom.system.shadps4.enable {
      # shadPS4 needs Vulkan 1.3; hardware.graphics.enable puts the NVIDIA ICD
      # at /run/opengl-driver/share/vulkan/icd.d where the loader looks.
      assertions = [
        {
          assertion = config.hardware.graphics.enable;
          message = "custom.system.shadps4.enable requires hardware.graphics.enable (Vulkan 1.3).";
        }
      ];

      environment.systemPackages = with pkgs; [
        # Emulator core (CLI: `shadps4 -g <eboot.bin>`). The Qt launcher below
        # spawns this exact binary — nixpkgs patches the launcher's version
        # manager to point at it instead of downloading builds.
        shadps4

        # Qt6 GUI front-end. Ships its own .desktop entry + hicolor icons
        # ("shadPS4 Qt Launcher"), so no custom desktop item is needed.
        shadps4-qtlauncher
      ];

      # Per-user emulator state, firmware modules and config.toml live in
      # ~/.local/share/shadPS4 (XDG_DATA_HOME). That is runtime data, not a
      # store path, so it stays outside this repo.
    };
  };
}

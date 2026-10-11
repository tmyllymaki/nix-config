{
  flake.nixosModules.keyd = {
    config,
    lib,
    ...
  }: {
    options.custom.system.keyd.enable = lib.mkEnableOption "system.keyd";

    config = lib.mkIf config.custom.system.keyd.enable {
      # Caps Lock as a Raycast-style hyper key: held it emulates
      # Ctrl+Alt+Shift+Meta (⌃⌥⇧⌘), tapped it emits Escape. keyd sits below the
      # display server (evdev + uinput), so this works in Plasma Wayland, niri
      # and on a TTY alike.
      services.keyd = {
        enable = true;
        keyboards.default = {
          ids = ["*"];
          settings.main.capslock = "overload(hyper, esc)";
          # The layer must be named: `overload(C-M-A-S, esc)` is rejected
          # ("C-M-A-S is not a valid layer"). C/M/A/S = Ctrl/Meta/Alt/Shift.
          extraConfig = ''
            [hyper:C-M-A-S]
          '';
        };
      };
    };
  };
}

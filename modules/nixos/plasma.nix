{
  flake.nixosModules.plasma = { config, lib, pkgs, ... }: {
    options.custom.system.plasma.enable = lib.mkEnableOption "system.plasma";

    config = lib.mkIf config.custom.system.plasma.enable {
      services.desktopManager.plasma6.enable = true;
      services.displayManager.sddm.enable = true;
      services.displayManager.sddm.wayland.enable = true;
      services.displayManager.defaultSession = "plasma";

      # SDDM replaces greetd (which is enabled in desktop.nix)
      services.greetd.enable = lib.mkForce false;

      # Auto-login as tm (matching current greetd initial_session behavior)
      services.displayManager.autoLogin = {
        enable = true;
        user = "tm";
      };

      # Exclude some KDE apps we don't need
      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        konsole
        okular
        elisa
      ];
    };
  };
}

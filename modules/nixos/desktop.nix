{
  flake.nixosModules.desktop = {
    config,
    inputs,
    lib,
    pkgs,
    extras,
    ...
  }: {
    options.custom.system.desktop.enable = lib.mkEnableOption "system.desktop";

    config = lib.mkIf config.custom.system.desktop.enable {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      services.xserver.videoDrivers = ["nvidia"];
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = false;
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };

      programs.dconf.enable = true;
      programs.niri.enable = true;
      programs.xwayland.enable = true;

      security.pam.services.swaylock = {};
      services.gnome.gnome-keyring.enable = true;

      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${lib.getExe pkgs.tuigreet} --remember --time --cmd ${lib.getExe' config.programs.niri.package "niri-session"}";
          user = "greeter";
        };
      };

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
        config = {
          common.default = ["gtk"];
          niri."org.freedesktop.impl.portal.FileChooser" = ["gtk"];
        };
      };

      environment.systemPackages =
        [
          inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
          pkgs.quickshell
        ]
        ++ (with pkgs; [
          swaylock
          xwayland-satellite
        ])
        ++ lib.optionals (extras.zen-browser != null) [extras.zen-browser];
    };
  };
}

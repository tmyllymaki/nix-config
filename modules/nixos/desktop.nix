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
      environment.etc = lib.mkIf (extras.zen-browser != null) {
        "1password/custom_allowed_browsers" = {
          text = ''
            zen
          '';
          mode = "0755";
        };
      };

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
        # package = config.boot.kernelPackages.nvidiaPackages.stable;
        package = config.boot.kernelPackages.nvidiaPackages.latest;
      };

      programs.dconf.enable = true;
      programs.niri.enable = true;
      programs.xwayland.enable = true;

      # Keyboard: Finner layout + Caps Lock as Escape
      services.xserver.xkb = {
        extraLayouts.finner = {
          description = "Finnish with US improvements (Finner)";
          languages = ["eng" "fin"];
          symbolsFile = ../../machines/desktop/home/files/xkb/symbols/finner;
        };
        layout = "finner";
        variant = "custom";
        options = "caps:escape";
      };

      security.pam.services.swaylock = {};
      services.gnome.gnome-keyring.enable = true;

      # Use greetd when Plasma is not enabled; SDDM takes over when Plasma is active.
      services.greetd = lib.mkIf (!config.custom.system.plasma.enable) {
        enable = true;
        settings = {
          initial_session = {
            command = "${lib.getExe' config.programs.niri.package "niri-session"}";
            user = "tm";
          };
          default_session = {
            command = "${lib.getExe pkgs.tuigreet} --remember --time --cmd ${lib.getExe' config.programs.niri.package "niri-session"}";
            user = "greeter";
          };
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
          pkgs.spotify
          (pkgs.symlinkJoin {
            name = "vivaldi";
            paths = [pkgs.vivaldi];
            buildInputs = [pkgs.makeWrapper];
            postBuild = ''
              wrapProgram $out/bin/vivaldi \
                --add-flags "--enable-blink-features=MiddleClickAutoscroll"
              for f in $out/share/applications/*.desktop; do
                if [ -L "$f" ]; then
                  target=$(readlink "$f")
                  rm "$f"
                  cp "$target" "$f"
                  chmod +w "$f"
                fi
                substituteInPlace "$f" \
                  --replace-fail "${pkgs.vivaldi}/bin/vivaldi" "$out/bin/vivaldi"
              done
            '';
          })
        ]
        ++ (with pkgs; [
          swaylock
          xwayland-satellite
        ])
        ++ lib.optionals (extras.zen-browser != null) [extras.zen-browser];
    };
  };
}

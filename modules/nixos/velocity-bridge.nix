{
  flake.nixosModules.velocity-bridge = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs) python3;
    pythonDeps = ps: with ps; [
      fastapi
      uvicorn
      python-multipart
      slowapi
    ];
    pythonWithDeps = python3.withPackages pythonDeps;
    cfg = config.custom.system.velocity-bridge;
  in {
    options.custom.system.velocity-bridge = {
      enable = lib.mkEnableOption "system.velocity-bridge";
      gui = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Use the Tauri GUI app instead of the headless systemd service.";
      };
    };

    config = lib.mkIf cfg.enable {
      networking.firewall = {
        allowedTCPPorts = [8080];
        trustedInterfaces = ["tailscale0"];
      };

      environment.systemPackages = (with pkgs; [
        wl-clipboard
        xclip
        libnotify
      ]) ++ (if cfg.gui then [
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.velocity-bridge
      ] else [
        pythonWithDeps
      ]);

      systemd.user.services.velocity = lib.mkIf (!cfg.gui) {
        description = "Velocity Bridge - iOS to Linux Clipboard Sync";
        after = ["network.target"];
        wantedBy = ["default.target"];

        path = with pkgs; [
          wl-clipboard
          xclip
          libnotify
        ];

        serviceConfig = {
          Type = "simple";
          WorkingDirectory = "%h/tools/Velocity-Bridge/systemd";
          ExecStart = "${pythonWithDeps}/bin/python3 -m uvicorn main:app --host 0.0.0.0 --port 8080";
          Restart = "always";
          RestartSec = "5s";
          # PassEnvironment only forwards vars from systemd --user's own process
          # environment, which typically lacks WAYLAND_DISPLAY/DISPLAY. Set them
          # explicitly so wl-copy/xclip can connect to the display server.
          Environment = [
            "WAYLAND_DISPLAY=wayland-0"
            "DISPLAY=:0"
            "XDG_SESSION_TYPE=wayland"
          ];
          PassEnvironment = [
            "DBUS_SESSION_BUS_ADDRESS"
            "XDG_RUNTIME_DIR"
          ];
        };
      };
    };
  };
}

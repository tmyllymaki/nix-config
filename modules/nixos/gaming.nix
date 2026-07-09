{
  flake.nixosModules.gaming = {
    config,
    lib,
    pkgs,
    extras,
    ...
  }: {
    options.custom.system.gaming.enable = lib.mkEnableOption "system.gaming";

    config = lib.mkIf config.custom.system.gaming.enable {
      programs.gamemode.enable = true;
      programs.gamescope.enable = true;

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };

      environment.systemPackages = with pkgs; [
        faugus-launcher
        mangohud
        protonup-qt
        umu-launcher
        pkgs.wineWow64Packages.stagingFull
        winetricks
        extras.mypkgs.penguin-burner
      ];

      # PenguinBurner hardware daemon: runs as root to access NVML/GPU.
      # The GUI communicates with it via /run/penguin-burnerd.sock.
      systemd.services.penguin-burnerd = let
        penguin = extras.mypkgs.penguin-burner;
      in {
        description = "PenguinBurner hardware daemon";
        after = ["multi-user.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "simple";
          WorkingDirectory = "/";
          Restart = "on-failure";
          RestartSec = "2";
          StandardOutput = "journal";
          StandardError = "journal";
          SyslogIdentifier = "penguin-burnerd";
          ExecStart = "${penguin}/bin/penguin-burner-cli --daemon-api /run/penguin-burnerd.sock";
        };
        # Inherit LD_LIBRARY_PATH from the package wrapper for NVML / Q2RTX libs
        environment = {
          SDL_DYNAMIC_API = "${pkgs.SDL2}/lib/libSDL2.so";
        };
      };

      # Kill Battle.net sockets on network reconnect to force re-auth
      networking.networkmanager.dispatcherScripts = [
        {
          source = pkgs.writeShellScript "99-bnet-socket-fix" ''
            if [ "$2" = "up" ]; then
                sleep 2
                ${pkgs.iproute2}/bin/ss -K dport = :1119
                ${pkgs.iproute2}/bin/ss -K dport = :443
                ${pkgs.iproute2}/bin/ss -K dport = :5222
                ${pkgs.procps}/bin/pkill -9 -f "Agent.exe"
            fi
          '';
        }
      ];
    };
  };
}

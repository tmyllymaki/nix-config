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
        python = pkgs.python3Packages.python;
        scanPython = python.withPackages (ps: with ps; [pyside6 colorama pyqtgraph]);
        uid = config.users.users.tm.uid;
      in {
        description = "PenguinBurner hardware daemon";
        after = ["multi-user.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "notify";
          WatchdogSec = 30;
          WorkingDirectory = "/";
          Restart = "on-failure";
          RestartSec = "2";
          StandardOutput = "journal";
          StandardError = "journal";
          SyslogIdentifier = "penguin-burnerd";
          ExecStart = "${extras.mypkgs.penguin-burnerd}/bin/penguin-burnerd --socket /run/penguin-burnerd.sock";
        };
        environment = {
          # Scan worker (Python CLI) the daemon spawns during Auto-UV scans,
          # dropped to the desktop user. Mirrors upstream's generated unit.
          PENGUIN_BURNER_DAEMON_PROGRAM_FILE = "${penguin}/${python.sitePackages}/penguin_burner.py";
          PENGUIN_BURNER_DAEMON_PYTHON = "${scanPython}/bin/python3";
          PENGUIN_BURNER_DAEMON_ALLOWED_UID = toString uid;
          PENGUIN_BURNER_Q2RTX_UID = toString uid;
          # Driver libs (libnvidia-ml / libnvidia-api) for the daemon's dlopen
          LD_LIBRARY_PATH = "/run/opengl-driver/lib";
          # Q2RTX is a manylinux binary: resolve its libs through nix-ld
          # (libvulkan comes from programs.nix-ld.libraries).
          NIX_LD = "/run/current-system/sw/share/nix-ld/lib/ld.so";
          NIX_LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
          # ldd/ps and friends for the scan child's runtime checks (default
          # systemd PATH + procps + glibc tools)
          PATH = lib.mkForce "/run/current-system/sw/bin:${pkgs.coreutils}/bin:${pkgs.findutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:${pkgs.systemd}/bin:${pkgs.procps}/bin:${pkgs.glibc.bin}/bin";
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

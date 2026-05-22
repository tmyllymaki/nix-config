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

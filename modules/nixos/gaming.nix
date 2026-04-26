{
  flake.nixosModules.gaming = {
    config,
    lib,
    pkgs,
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
      ];
    };
  };
}

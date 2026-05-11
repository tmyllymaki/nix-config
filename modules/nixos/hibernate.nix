{
  flake.nixosModules.hibernate = {
    config, lib, pkgs, ...
  }: {
    options.custom.system.hibernate.enable = lib.mkEnableOption "system.hibernate";

    config = lib.mkIf config.custom.system.hibernate.enable {
      fileSystems."/swap" = {
        device = "/dev/disk/by-uuid/446d69d0-2ec1-4c5c-b34f-596666f8260d";
        fsType = "btrfs";
        options = [ "subvol=@swap" "nodatacow" "noatime" ];
      };

      swapDevices = [{
        device = "/swap/swapfile";
        size = 32768;
      }];

      boot.resumeDevice = "/dev/disk/by-uuid/446d69d0-2ec1-4c5c-b34f-596666f8260d";

      boot.kernelParams = [ "resume_offset=56368384" ];
    };
  };
}

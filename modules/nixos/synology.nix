{
  flake.nixosModules.synology = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.system.synology.enable = lib.mkEnableOption "system.synology";

    config = lib.mkIf config.custom.system.synology.enable {
      environment.systemPackages = with pkgs; [
        nfs-utils
      ];

      boot.initrd = {
        availableKernelModules = ["nfs"];
        kernelModules = ["nfs"];
      };

      services.rpcbind.enable = true;

      systemd.mounts = let
        commonMountOptions = {
          type = "nfs";
          mountConfig.Options = "noatime,nolock,rw,soft,nfsvers=3";
        };
      in [
        (commonMountOptions
          // {
            what = "10.0.0.200:/volume1/media";
            where = "/mnt/media";
          })
        (commonMountOptions
          // {
            what = "10.0.0.200:/volume1/backups";
            where = "/mnt/backups";
          })
        (commonMountOptions
          // {
            what = "10.0.0.200:/volume1/homes";
            where = "/mnt/homes";
          })
      ];

      systemd.automounts = let
        commonAutoMountOptions = {
          wantedBy = ["multi-user.target"];
          automountConfig.TimeoutIdleSec = "600";
        };
      in [
        (commonAutoMountOptions // {where = "/mnt/media";})
        (commonAutoMountOptions // {where = "/mnt/backups";})
        (commonAutoMountOptions // {where = "/mnt/homes";})
      ];
    };
  };
}

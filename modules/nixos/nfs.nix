{
  flake.nixosModules.nfs = { config, lib, pkgs, ... }: {
    options.custom.system.nfs.enable = lib.mkEnableOption "system.nfs";

    config = lib.mkIf config.custom.system.nfs.enable {
      boot.supportedFilesystems = [ "nfs" ];

      # Ensure rpcbind is available (required for NFS mounts)
      services.rpcbind.enable = true;

      # nfs-utils provides mount.nfs, showmount, etc.
      environment.systemPackages = [ pkgs.nfs-utils ];

      # Allow unprivileged users to mount NFS shares
      programs.fuse.userAllowOther = true;

      # Ensure NFS kernel modules are loaded early (avoid mount failures at boot)
      boot.initrd = {
        availableKernelModules = ["nfs"];
        kernelModules = ["nfs"];
      };

      # Synology NAS NFS mounts
      systemd.mounts = let
        commonMountOptions = {
          type = "nfs";
          mountConfig.Options = "noatime,nolock,rw,soft,nfsvers=3";
        };
      in [
        (commonMountOptions // {
          what = "10.0.0.200:/volume1/media";
          where = "/hdd/downloads";
        })
        (commonMountOptions // {
          what = "10.0.0.200:/volume1/backups";
          where = "/mnt/backups";
        })
        (commonMountOptions // {
          what = "10.0.0.200:/volume1/homes";
          where = "/mnt/homes";
        })
      ];

      # Auto-unmount after 10 minutes of inactivity
      systemd.automounts = let
        commonAutoMountOptions = {
          wantedBy = ["multi-user.target"];
          automountConfig.TimeoutIdleSec = "600";
        };
      in [
        (commonAutoMountOptions // { where = "/hdd/downloads"; })
        (commonAutoMountOptions // { where = "/mnt/backups"; })
        (commonAutoMountOptions // { where = "/mnt/homes"; })
      ];
    };
  };
}

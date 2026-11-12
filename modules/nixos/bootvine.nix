{
  flake.nixosModules.bootvine = {
    config,
    inputs,
    lib,
    ...
  }: {
    imports = [
      inputs.bootvine.nixosModules.default
    ];

    options.custom.system.bootvine.enable = lib.mkEnableOption "system.bootvine";

    config = lib.mkIf config.custom.system.bootvine.enable {
      # The initrd is always systemd-based on current nixpkgs, so bootvine
      # also shows the boot from the initrd.
      services.bootvine.enable = true;
    };
  };
}

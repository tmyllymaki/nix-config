{
  flake.nixosModules.cachyos = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: {
    options.custom.system.cachyos.enable = lib.mkEnableOption "system.cachyos";

    config = lib.mkIf config.custom.system.cachyos.enable {
      nixpkgs.overlays = [
        inputs.nix-cachyos-kernel.overlays.pinned
      ];

      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;
    };
  };
}

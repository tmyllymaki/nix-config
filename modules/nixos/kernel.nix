{
  flake.nixosModules.kernel = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.system.kernel = {
      enable = lib.mkEnableOption "system.kernel";

      flavor = lib.mkOption {
        type = lib.types.enum [
          "default"
          "latest"
          "zen"
          "xanmod"
          "xanmod-latest"
        ];
        default = "zen";
        description = ''
          Kernel shipped by nixpkgs and built by Hydra (cache.nixos.org), so no
          third-party binary cache is needed:
            - default         mainline LTS (pkgs.linuxPackages)
            - latest          newest mainline (pkgs.linuxPackages_latest)
            - zen             desktop/gaming config: full preempt, BFQ, HZ=1000,
                              NTSYNC, ZEN_INTERACTIVE (pkgs.linuxPackages_zen)
            - xanmod          XanMod stable (pkgs.linuxPackages_xanmod_stable)
            - xanmod-latest   XanMod latest (pkgs.linuxPackages_xanmod_latest)
        '';
      };
    };

    config = lib.mkIf config.custom.system.kernel.enable {
      boot.kernelPackages =
        {
          default = pkgs.linuxPackages;
          latest = pkgs.linuxPackages_latest;
          zen = pkgs.linuxPackages_zen;
          xanmod = pkgs.linuxPackages_xanmod_stable;
          xanmod-latest = pkgs.linuxPackages_xanmod_latest;
        }.${
          config.custom.system.kernel.flavor
        };
    };
  };
}

{
  flake.nixosModules.secureboot = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
    ];

    options.custom.system.secureboot.enable = lib.mkEnableOption "system.secureboot";

    config = lib.mkIf config.custom.system.secureboot.enable {
      # Lanzaboote replaces the systemd-boot module (enabled in desktop.nix).
      boot.loader.systemd-boot.enable = lib.mkForce false;
      # Needed to enroll keys from Linux via sbctl.
      boot.loader.efi.canTouchEfiVariables = true;

      boot.lanzaboote = {
        enable = true;
        # Keys created via `sudo sbctl create-keys` (see
        # https://nix-community.github.io/lanzaboote/getting-started/prepare-your-system.html)
        pkiBundle = "/var/lib/sbctl";
        # UKIs are bigger than plain .conf entries; keep the ESP from filling up.
        # `nh clean` already keeps 3 generations, so 5 is plenty.
        configurationLimit = 5;
      };

      environment.systemPackages = [
        # For troubleshooting and key enrollment (`sbctl status`, `sbctl enroll-keys`).
        pkgs.sbctl
      ];

      # Lanzaboote signs the fwupd binary when fwupd is enabled.
      services.fwupd.enable = true;
    };
  };
}

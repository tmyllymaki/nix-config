{
  flake.nixosMachineModules.desktop = {inputs, ...}: {
    imports = [
      ./_hardware-configuration.nix
    ];

    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = "x86_64-linux";

    nixpkgs.overlays = [
      inputs.ts3-noweb.overlays.default
      (final: prev: {
        _1password-gui = prev._1password-gui.overrideAttrs (oldAttrs: {
          src = final.fetchurl {
            url = "https://downloads.1password.com/linux/tar/stable/x86_64/1password-8.12.21.x64.tar.gz";
            hash = "sha256-JwiMi2iozP6jWSIUtgXla86aSAhuUob7snqtUbeXPpI=";
          };
        });
      })
    ];

    system.stateVersion = "23.05";
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    custom.quickenable.system.modules = [
      "base"
      "cachyos"
      "desktop"
      "gaming"
      "hibernate"
      "nfs"
      "rclone"
      "plasma"
      "velocity-bridge"
    ];
  };
}

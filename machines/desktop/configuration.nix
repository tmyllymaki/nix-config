{
  flake.nixosMachineModules.desktop = {inputs, ...}: {
    imports = [
      ./_hardware-configuration.nix
    ];

    nixpkgs.config.allowUnfree = true;
    nixpkgs.hostPlatform = "x86_64-linux";

    nixpkgs.overlays = [
      inputs.ts3-noweb.overlays.default
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
      "plasma"
      "secureboot"
      "velocity-bridge"
    ];
  };
}

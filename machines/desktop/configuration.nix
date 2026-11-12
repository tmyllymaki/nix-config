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
      "audio"
      "base"
      "bootvine"
      "desktop"
      "gaming"
      "hibernate"
      "kernel"
      "keyd"
      "nfs"
      "plasma"
      "secureboot"
      "shadps4"
      "velocity-bridge"
    ];

    # zen: desktop/gaming-tuned config from nixpkgs (full preempt, BFQ, HZ=1000,
    # NTSYNC). Swapped in for the old nix-cachyos-kernel flake, whose attic cache
    # was compromised. Alternatives: "default", "latest", "xanmod",
    # "xanmod-latest" — see modules/nixos/kernel.nix.
    custom.system.kernel.flavor = "zen";
  };
}

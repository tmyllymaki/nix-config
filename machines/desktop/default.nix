{
  config,
  inputs,
  mkExtras,
  ...
}: let
  machine = "desktop";
  hostname = "nix-desktop";
  system = "x86_64-linux";
in {
  flake.nixosConfigurations.${machine} = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs.extras = mkExtras system;
    specialArgs.inputs = inputs;
    modules = [
      {
        imports = [
          config.flake.nixosModules.all
        ];
        hjem.specialArgs = {
          inherit inputs;
          extras = mkExtras system;
        };
        hjem.extraModules = [
          config.flake.hjemModules.all
        ];
      }
      config.flake.nixosMachineModules.${machine}
      {
        networking.hostName = hostname;
      }
      inputs.hjem.nixosModules.default
    ];
  };
}

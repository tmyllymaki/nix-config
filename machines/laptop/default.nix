{
  config,
  inputs,
  mkExtras,
  ...
}: let
  machine = "laptop";
  hostname = "Timos-MacBook-Air";
  system = "aarch64-darwin";
in {
  flake.darwinConfigurations.${machine} = inputs.nix-darwin.lib.darwinSystem {
    inherit system;
    specialArgs.extras = mkExtras system;
    specialArgs.inputs = inputs;
    modules = [
      {
        imports = [
          config.flake.darwinModules.all
        ];
        hjem.specialArgs = {
          inherit inputs;
        };
        hjem.extraModules = [
          config.flake.hjemModules.all
        ];
      }
      config.flake.nixosMachineModules.${machine}
      {
        networking.hostName = hostname;
        networking.computerName = hostname;
      }
      inputs.hjem.darwinModules.default
      inputs.nix-homebrew.darwinModules.nix-homebrew
    ];
  };
}

# Builds a darwinConfiguration from the pieces that actually differ between
# Macs. Everything shared lives in darwinModules.all / hjemModules.all; the
# per-machine specifics live in machines/<machine>/.
{
  config,
  inputs,
  mkExtras,
  machine,
  hostname,
  system ? "aarch64-darwin",
}: {
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
          extras = mkExtras system;
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

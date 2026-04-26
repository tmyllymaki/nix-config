{lib, ...}: let
  inherit (lib) mkOption;
  inherit (lib.types) attrsOf deferredModule;
in {
  options.flake = {
    # Machine modules are separate from system modules to avoid unintended
    # evaluation - they're only pulled in by the specific machine that needs them.
    nixosMachineModules = mkOption {
      type = attrsOf deferredModule;
      default = {};
      description = "Machine configuration modules (used for both NixOS and nix-darwin)";
    };

    hjemModules = mkOption {
      type = attrsOf deferredModule;
      default = {};
      description = "Hjem modules for user-level configuration";
    };

    # Not defined by flake-parts (it's nix-darwin specific), so we declare it here.
    darwinModules = mkOption {
      type = attrsOf deferredModule;
      default = {};
      description = "Nix-darwin modules for system-level configuration";
    };
  };
}

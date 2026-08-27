{lib, ...}: let
  inherit (lib) mkOption;
  inherit (lib.types) attrsOf deferredModule raw;
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

    # Not defined by flake-parts (they're nix-darwin specific), so we declare
    # them here. darwinConfigurations in particular needs a declared option so
    # more than one machine can contribute to it.
    darwinConfigurations = mkOption {
      type = attrsOf raw;
      default = {};
      description = "Nix-darwin system configurations, one per Mac";
    };

    darwinModules = mkOption {
      type = attrsOf deferredModule;
      default = {};
      description = "Nix-darwin modules for system-level configuration";
    };
  };
}

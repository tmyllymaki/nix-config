{
  description = "Timo's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "nix-darwin";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Homebrew taps
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-qmk = {
      url = "github:qmk/homebrew-qmk";
      flake = false;
    };
    homebrew-avr = {
      url = "github:osx-cross/homebrew-avr";
      flake = false;
    };
    homebrew-arm = {
      url = "github:osx-cross/homebrew-arm";
      flake = false;
    };
    homebrew-tap-nikita = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    homebrew-tap-sketchybar = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };
    homebrew-tap-siggy = {
      url = "github:johnsideserf/homebrew-siggy";
      flake = false;
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    llama-cpp.url = "github:ggerganov/llama.cpp";

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }: let
    inherit (inputs.nixpkgs) lib;
    shouldImport = file: file.hasExt "nix" && !(lib.hasPrefix "_" file.name);
    import-tree = path:
      lib.pipe path [
        (lib.fileset.fileFilter shouldImport)
        (lib.fileset.toList)
      ];
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      _module.args.mkExtras = system: {
        neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.default;
        mypkgs = self.packages.${system};
        zen-browser = lib.attrByPath [system "default"] null (inputs.zen-browser.packages or {});
      };

      perSystem = {system, ...}: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ ];
        };
      };

      imports = lib.flatten [
        (import-tree ./modules)
        (import-tree ./machines)
	(import-tree ./packages)
      ];
    };
}

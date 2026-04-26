{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    (import (builtins.fetchurl {
      url = "https://gist.githubusercontent.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa/raw/41e569ba110eb6ebbb463a6b1f5d9fe4f9e82375/mutability.nix";
      sha256 = "4b5ca670c1ac865927e98ac5bf5c131eca46cc20abf0bd0612db955bfc979de8";
    }) {inherit config lib;})

    (import (builtins.fetchurl {
      url = "https://gist.githubusercontent.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa/raw/41e569ba110eb6ebbb463a6b1f5d9fe4f9e82375/vscode.nix";
      sha256 = "fed877fa1eefd94bc4806641cea87138df78a47af89c7818ac5e76ebacbd025f";
    }) {inherit config lib pkgs;})
  ];

  programs.vscode = {
    #    package = (pkgs.vscode.override {isInsiders = true;}).overrideAttrs (oldAttrs: rec {
    #      src = builtins.fetchTarball {
    #        url = "https://update.code.visualstudio.com/latest/linux-x64/insider";
    #        sha256 = "1adkx05hicgzsx3l2a7x29ciyswk7q9jl2gni5ss385ia3m82hk5";
    #      };
    #      version = "latest";
    #    });
    enable = true;
    mutableExtensionsDir = true;

    extensions = with pkgs.vscode-extensions; [
      asvetliakov.vscode-neovim
      eamodio.gitlens
      github.copilot
      github.copilot-chat
      golang.go
      jnoortheen.nix-ide
      ms-azuretools.vscode-docker
      ms-vsliveshare.vsliveshare
      rust-lang.rust-analyzer
      svelte.svelte-vscode
      bradlc.vscode-tailwindcss
      jdinhlife.gruvbox
    ];
    userSettings = {
      "editor.fontFamily" = "Iosevka";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 16;
      "explorer.confirmDragAndDrop" = false;
      "workbench.colorTheme" = "Gruvbox Dark Hard";
      "keyboard.dispatch" = "keyCode";
      "extensions.autoCheckUpdates" = false;
      "extensions.autoUpdate" = false;
      "svelte.enable-ts-plugin" = true;
      "workbench.sideBar.location" = "right";
      "nix.formatterPath" = "/etc/profiles/per-user/tm/bin/alejandra";
      "extensions.experimental.affinity" = {
        "asvetliakov.vscode-neovim" = 1;
      };
      "alejandra.program" = "${pkgs.alejandra}/bin/alejandra";
      "customLocalFormatters.formatters" = [
        {
          command = "${pkgs.nodePackages.prettier}/bin/prettier --parser css";
          languages = ["css"];
        }
        {
          command = "${pkgs.nodePackages.prettier}/bin/prettier --parser html";
          languages = ["html"];
        }
        {
          command = "${pkgs.google-java-format}/bin/google-java-format -";
          languages = ["java"];
        }
        {
          command = "${pkgs.nodePackages.prettier}/bin/prettier --parser babel";
          languages = ["javascript"];
        }
        {
          command = "${pkgs.jq}/bin/jq -S";
          languages = ["json" "jsonc"];
        }
        {
          command = "${pkgs.nodePackages.prettier}/bin/prettier --parser markdown";
          languages = ["markdown"];
        }
        {
          command = "${pkgs.rustfmt}/bin/rustfmt";
          languages = ["rust"];
        }
        {
          command = "${pkgs.nodePackages.prettier}/bin/prettier --parser scss";
          languages = ["scss"];
        }
        {
          command = "${pkgs.shfmt}/bin/shfmt -bn -ci -i 2 -s -sr -";
          languages = ["shellscript"];
        }
        {
          command = "${pkgs.nodePackages.sql-formatter}/bin/sql-formatter";
          languages = ["sql"];
        }
        {
          command = "${pkgs.terraform}/bin/terraform fmt -";
          languages = ["terraform"];
        }
        {
          command =
            (pkgs.writeShellScript "toml-fmt" ''
              NODE_PATH=${pkgs.nodePackages.prettier-plugin-toml}/lib/node_modules \
              ${pkgs.nodePackages.prettier}/bin/prettier \
                --parser toml \
                --plugin prettier-plugin-toml
            '')
            .outPath;
          languages = ["toml"];
        }
        {
          command = "${pkgs.nodePackages.prettier}/bin/prettier --parser html";
          languages = ["xml"];
        }
        {
          command = "${pkgs.nodePackages.prettier}/bin/prettier --parser yaml";
          languages = ["yaml"];
        }
      ];
    };
  };
}

{
  flake.darwinModules.homebrew = {
    config,
    lib,
    ...
  }: {
    options.custom.system.homebrew = {
      enable = lib.mkEnableOption "system.homebrew";

      extraBrews = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["qmk/qmk/qmk"];
        description = ''
          Formulae wanted on this machine only, appended to the shared set.
          `homebrew.onActivation.cleanup = "uninstall"` means anything absent
          from the combined list is removed, so machine-specific tools belong
          here rather than in the shared list.
        '';
      };

      extraCasks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["container"];
        description = "Casks wanted on this machine only, appended to the shared set.";
      };
    };

    config = lib.mkIf config.custom.system.homebrew.enable {
      homebrew = {
        enable = true;
        onActivation = {
          cleanup = "uninstall";
          autoUpdate = false;
          upgrade = true;
        };
        taps = [
          "homebrew/core"
          "homebrew/cask"
          # Homebrew 6.0 enables HOMEBREW_REQUIRE_TAP_TRUST by default; non-official
          # taps must be declared trusted or `brew bundle --force-cleanup` wipes
          # their trust entries and activation fails loading formulae/casks from them.
          {
            name = "qmk/homebrew-qmk";
            trusted = true;
          }
          {
            name = "osx-cross/homebrew-avr";
            trusted = true;
          }
          {
            name = "osx-cross/homebrew-arm";
            trusted = true;
          }
          {
            name = "nikitabobko/homebrew-tap";
            trusted = true;
          }
          {
            name = "felixkratz/homebrew-formulae";
            trusted = true;
          }
          {
            name = "johnsideserf/homebrew-siggy";
            trusted = true;
          }
          {
            name = "junian/homebrew-dotnet";
            trusted = true;
          }
          {
            name = "guria/homebrew-tap";
            trusted = true;
          }
          {
            name = "d12frosted/homebrew-emacs-plus";
            trusted = true;
          }
          {
            name = "mikker/homebrew-tap";
            trusted = true;
          }
        ];
        brews =
          [
            "blueutil"
            "croc"
            "mole"
            "swiftformat"
            "xcodegen"
            "xcode-build-server"
            "tree-sitter"
            "tree-sitter-cli"
            "zsh-vi-mode"
            "xcbeautify"
            "ruby"
            "coreutils"
            "signal-cli"
            "herdr"
            "johnsideserf/siggy/siggy"
          ]
          ++ config.custom.system.homebrew.extraBrews;
        casks =
          [
            "dotnet-sdk@10.0"
            "1password"
            "1password-cli"
            "aerospace"
            "alt-tab"
            "betterdisplay"
            "domzilla-caffeine"
            "ghostty"
            "hammerspoon"
            "middleclick"
            "mos"
            "netnewswire"
            "obsidian"
            "omnidisksweeper"
            "openmtp"
            "orbstack"
            "qmk-toolbox"
            "rustdesk"
            "sanesidebuttons"
            "signal"
            "spotify"
            "tailscale-app"
            "visual-studio-code@insiders"
            "vivaldi"
            "whatsapp"
          ]
          ++ config.custom.system.homebrew.extraCasks;
      };
    };
  };
}

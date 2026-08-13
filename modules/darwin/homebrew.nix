{
  flake.darwinModules.homebrew = {
    config,
    lib,
    ...
  }: {
    options.custom.system.homebrew.enable = lib.mkEnableOption "system.homebrew";

    config = lib.mkIf config.custom.system.homebrew.enable {
      homebrew = {
        enable = true;
        onActivation = {
          cleanup = "uninstall";
          autoUpdate = false;
          upgrade = false;
        };
        taps = [
          "homebrew/core"
          "homebrew/cask"
          # Homebrew 6.0 enables HOMEBREW_REQUIRE_TAP_TRUST by default; non-official
          # taps must be declared trusted or `brew bundle --force-cleanup` wipes
          # their trust entries and activation fails loading formulae/casks from them.
          { name = "qmk/homebrew-qmk"; trusted = true; }
          { name = "osx-cross/homebrew-avr"; trusted = true; }
          { name = "osx-cross/homebrew-arm"; trusted = true; }
          { name = "nikitabobko/homebrew-tap"; trusted = true; }
          { name = "felixkratz/homebrew-formulae"; trusted = true; }
          { name = "johnsideserf/homebrew-siggy"; trusted = true; }
          { name = "junian/homebrew-dotnet"; trusted = true; }
        ];
        brews = [
          "blueutil"
          "croc"
          "elixir"
          "exercism"
          "mono-libgdiplus"
          "pipx"
          "mole"
          "qmk/qmk/qmk"
          "swiftformat"
          "swiftlint"
          "xcodegen"
          "xcode-build-server"
          "portaudio"
          "tree-sitter"
          "tree-sitter-cli"
          "zsh-vi-mode"
          "xcbeautify"
          "ruby"
          "coreutils"
          "sketchybar"
          "signal-cli"
          "herdr"
          "johnsideserf/siggy/siggy"
        ];
        casks = [
          "dotnet-sdk@10.0"
          "1password"
          "1password-cli"
          "aerospace"
          "alt-tab"
          "betterdisplay"
          "container"
          "domzilla-caffeine"
          "font-hack-nerd-font"
          "ghostty"
          "hammerspoon"
          "hiddenbar"
          "jetbrains-toolbox"
          "leader-key"
          "middleclick"
          "mos"
          "netnewswire"
          "obsidian"
          "omnidisksweeper"
          "openmtp"
          "orbstack"
          "plex"
          "qmk-toolbox"
          "rustdesk"
          "sanesidebuttons"
          "signal"
          "spotify"
          "tailscale-app"
          "visual-studio-code@insiders"
          "vivaldi"
          "wezterm@nightly"
          "whatsapp"
          "zed"
        ];
      };
    };
  };
}

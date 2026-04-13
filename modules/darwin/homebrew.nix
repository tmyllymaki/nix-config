{
  flake.darwinModules.homebrew =
    { config, lib, ... }:
    {
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
            "qmk/homebrew-qmk"
            "osx-cross/homebrew-avr"
            "osx-cross/homebrew-arm"
            "nikitabobko/homebrew-tap"
            "felixkratz/homebrew-formulae"
            "johnsideserf/homebrew-siggy"
          ];
          brews = [
            "blueutil"
            "croc"
            "dotnet"
            "elixir"
            "exercism"
            "mono-libgdiplus"
            "pipx"
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
            "johnsideserf/siggy/siggy"
          ];
          casks = [
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
            "wezterm@nightly"
            "whatsapp"
            "zed"
          ];
        };
      };
    };
}

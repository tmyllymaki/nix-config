{
  flake.hjemModules.guitar = {
    config,
    extras,
    lib,
    pkgs,
    ...
  }: let
    # Hosts (REAPER, Carla, guitarix) only look for plugins through these env
    # vars. nix packages install into <pkg>/lib/{lv2,vst,vst3,clap}; in a
    # profile that surfaces as <profile>/lib/<format>. $HOME/.<format> is where
    # yabridgectl drops Wine bridges and where you can dump downloaded plugins.
    pluginPath = format:
      (lib.makeSearchPath format [
        "$HOME/.nix-profile/lib"
        "/run/current-system/sw/lib"
        "/etc/profiles/per-user/$USER/lib"
      ])
      + ":$HOME/.${format}";
  in {
    options.custom.home.guitar = {
      enable = lib.mkEnableOption "home.guitar";

      windowsPlugins = lib.mkEnableOption "yabridge + Wine for Windows VST3 plugins (NeuralDSP, Amplitube, STL)";
    };

    config = lib.mkIf config.custom.home.guitar.enable {
      packages = with pkgs;
        [
          # DAW. Local build: nixpkgs' reaper is patchelf'd in a way that makes
          # it segfault in ld.so on start, see packages/reaper.nix. JACK mode
          # talks to pipewire-jack, i.e. the same graph as the desktop.
          extras.mypkgs.reaper

          # Native plugin host + amp sims. All of these run in-process with no
          # Wine in the signal path.
          carla
          neural-amp-modeler-lv2 # NAM, loads .nam captures from tone3000
          lsp-plugins # IR loader, gate, EQ, meters
          guitarix

          # Routing / interface control (works with Scarlett 2nd-4th gen).
          qpwgraph
          alsa-scarlett-gui
        ]
        ++ lib.optionals config.custom.home.guitar.windowsPlugins [
          yabridge
          yabridgectl
          # Full Wine for running the (Windows) plugin installers; yabridge
          # itself uses its own wrapped build.
          wineWow64Packages.stagingFull
        ];

      environment.sessionVariables = {
        LV2_PATH = pluginPath "lv2";
        VST_PATH = pluginPath "vst";
        VST3_PATH = pluginPath "vst3";
        CLAP_PATH = pluginPath "clap";
      };
    };
  };
}

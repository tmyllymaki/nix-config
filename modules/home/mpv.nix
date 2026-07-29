{
  flake.hjemModules.mpv = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.home.mpv.enable = lib.mkEnableOption "home.mpv";

    config = lib.mkIf config.custom.home.mpv.enable {
      packages = [
        (pkgs.mpv.override {
          scripts = [
            pkgs.mpvScripts.modernz
            pkgs.mpvScripts.sponsorblock
          ];
        })
      ];

      # modernz icons font needs to be in a fontconfig search path
      # since homebrew fontconfig doesn't search nix store paths
      xdg.data.files."fonts/modernz-icons.ttf".source =
        "${pkgs.mpvScripts.modernz}/share/fonts/truetype/modernz-icons.ttf";

      xdg.config.files."mpv/mpv.conf".text = ''
        hwdec=auto
        volume=80
        ytdl-format=bestvideo+bestaudio
        demuxer-max-bytes=123400KiB
        demuxer-readahead-secs=20
        # modernz sub_margins compat
        watch-later-options-remove=sub-pos
      '';
    };
  };
}

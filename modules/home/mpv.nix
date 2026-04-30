{
  flake.hjemModules.mpv = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.home.mpv.enable = lib.mkEnableOption "home.mpv";

    config = lib.mkIf config.custom.home.mpv.enable {
      packages = [pkgs.mpv];

      xdg.config.files."mpv/mpv.conf".text = ''
        hwdec=auto
        hwdec-codecs=all
        volume=80
        ytdl-format=bestvideo+bestaudio
        demuxer-max-bytes=123400KiB
        demuxer-readahead-secs=20
      '';
    };
  };
}

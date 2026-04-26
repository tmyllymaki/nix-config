{lib, ...}: {
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto";
      hwdec-codecs = "all";
      volume = 80;
      ytdl-format = "bestvideo+bestaudio";
      demuxer-max-bytes = "123400KiB";
      demuxer-readahead-secs = 20;
    };
  };
}

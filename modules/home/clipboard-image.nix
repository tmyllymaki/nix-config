{
  flake.hjemModules.clipboard-image = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs) imagemagick;
    inherit (pkgs.stdenv.hostPlatform) isLinux;
  in {
    options.custom.home.clipboard-image.enable = lib.mkEnableOption "home.clipboard-image";

    config = lib.mkIf config.custom.home.clipboard-image.enable {
      packages = [imagemagick];

      files."fish/functions/compress-image.fish".text = ''
        function compress-image -d "Compress clipboard image for sharing"
          set -l tmp_in (mktemp /tmp/compress-image-XXXXXXXX)
          set -l tmp_out (mktemp /tmp/compress-image-XXXXXXXX.jpg)

          wl-paste >$tmp_in
          or begin
            echo "Nothing on clipboard" >&2
            rm -f $tmp_in $tmp_out
            return 1
          end

          ${imagemagick}/bin/identify $tmp_in >/dev/null 2>&1
          or begin
            echo "Clipboard content is not an image" >&2
            rm -f $tmp_in $tmp_out
            return 1
          end

          ${imagemagick}/bin/convert $tmp_in -quality 85 -resize "1920x1080>" $tmp_out
          or begin
            echo "Failed to compress image" >&2
            rm -f $tmp_in $tmp_out
            return 1
          end

          wl-copy --type image/jpeg <$tmp_out
          or begin
            echo "Failed to copy to clipboard" >&2
            rm -f $tmp_in $tmp_out
            return 1
          end

          echo "Image compressed and ready to paste!"

          rm -f $tmp_in $tmp_out
        end
      '';
    };
  };
}

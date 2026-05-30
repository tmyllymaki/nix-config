{
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    pname = "helium";
    version = "0.12.4.1";

    architectures = {
      "x86_64-linux" = {
        arch = "x86_64";
        hash = "sha256-OgS8HkLBseFrEhNFJxMwp1bg0gzPdfY1VaySAAp7vq0=";
      };
      "aarch64-linux" = {
        arch = "arm64";
        hash = "sha256-y0NY7bLOultaKE+icbVRaQFiO2Epu19vw6RqxRKoC2o=";
      };
    };

    src = let
      inherit (architectures.${pkgs.stdenv.hostPlatform.system}) arch hash;
    in
      pkgs.fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-${arch}.AppImage";
        inherit hash;
      };

    appimage = pkgs.appimageTools.wrapType2 {
      inherit pname version src;
      meta = {
        description = "Helium browser - a fork of ungoogled-chromium with enhanced features";
        homepage = "https://github.com/imputnet/helium";
        license = lib.licenses.bsd3;
        mainProgram = "helium";
        platforms = lib.attrNames architectures;
      };
    };
  in {
    packages.helium = appimage;
  };
}

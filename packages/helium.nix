{
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    pname = "helium";
    version = "0.13.3.1";

    architectures = {
      "x86_64-linux" = {
        arch = "x86_64";
        hash = "sha256-RS+Sn42V+HjCw41N1zayMVIqlgH+i2B2IdVJwBPmw00=";
      };
      "aarch64-linux" = {
        arch = "arm64";
        hash = "sha256-9M76zjCGSdiMPp5liOhtTAE2K8P7B0pEpecnD+d3Rcg=";
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

      extraPkgs = pkgs: with pkgs; [ libsecret ];

      extraInstallCommands = let
        appimageContents = pkgs.appimageTools.extractType2 {
          inherit pname version src;
        };
      in
        ''
          install -Dm 444 ${appimageContents}/helium.desktop -t $out/share/applications
          cp -r ${appimageContents}/usr/share/icons/. $out/share/icons
        '';

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

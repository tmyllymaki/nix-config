{
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: let
    pname = "velocity-bridge";
    version = "3.0.5";

    architectures = {
      "x86_64-linux" = {
        arch = "amd64";
        hash = "sha256-YQw2VpQ+ruDu9AZTL1+j30DyDkMRXz7NRKnQOqfKjdw=";
      };
    };

    src = let
      inherit (architectures.${system} or (throw "Unsupported architecture: ${system}")) arch hash;
    in
      pkgs.fetchurl {
        url = "https://github.com/Trex099/Velocity-Bridge/releases/download/v${version}/Velocity-Bridge_${version}_${arch}.AppImage";
        inherit hash;
      };

    appimage = pkgs.appimageTools.wrapType2 {
      inherit pname version src;

      extraPkgs = pkgs: with pkgs; [
        libnotify
        libayatana-appindicator
      ];

      extraInstallCommands = let
        appimageContents = pkgs.appimageTools.extractType2 {
          inherit pname version src;
        };
      in
        ''
          install -Dm 444 ${appimageContents}/Velocity-Bridge.png \
            -t $out/share/icons/hicolor/256x256/apps
          install -Dm 444 ${appimageContents}/velocity_tauri.png \
            -t $out/share/pixmaps
          install -Dm 444 ${appimageContents}/Velocity-Bridge.desktop -t $out/share/applications
          substituteInPlace $out/share/applications/Velocity-Bridge.desktop \
            --replace-fail "Exec=velocity_tauri" "Exec=$out/bin/${pname}" \
            --replace-fail "Icon=velocity_tauri" "Icon=$out/share/icons/hicolor/256x256/apps/Velocity-Bridge.png"
        '';

      meta = {
        description = "iOS to Linux clipboard and image sync";
        homepage = "https://github.com/Trex099/Velocity-Bridge";
        license = lib.licenses.gpl3Only;
        mainProgram = pname;
        platforms = builtins.attrNames architectures;
      };
    };
  in {
    packages.velocity-bridge = appimage;
  };
}

{
  perSystem = {pkgs, ...}: {
    packages.finner-keyboard = let
      finnerFile = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/ruohola/finner/master/Finner.keylayout";
        sha256 = "sha256-IidFnfJseN2XP5MPN3pjBptftgHyGNmDKwPZwmJxfgo=";
      };
      bundleId = "fi.myllymaki.keyboardlayout.Finner";
    in
      # Packaged as a keyboard layout bundle instead of a bare .keylayout file.
      # The bundle's Info.plist declares Finnish as the intended language, which
      # lets macOS accept Finner as the only enabled layout and allows removing
      # the stock Finnish layout from Input Sources.
      pkgs.stdenv.mkDerivation {
        name = "finner-keyboard-layout";
        dontUnpack = true;
        installPhase = ''
          contents=$out/Finner.bundle/Contents
          mkdir -p $contents/Resources
          cp ${finnerFile} $contents/Resources/Finner.keylayout
          cat > $contents/Info.plist <<'EOF'
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
            <key>CFBundleIdentifier</key>
            <string>${bundleId}</string>
            <key>CFBundleName</key>
            <string>Finner</string>
            <key>CFBundleVersion</key>
            <string>1.0</string>
            <key>KLInfo_Finner</key>
            <dict>
              <key>TISInputSourceID</key>
              <string>${bundleId}</string>
              <key>TISIntendedLanguage</key>
              <string>fi</string>
            </dict>
          </dict>
          </plist>
          EOF
        '';
      };
  };
}

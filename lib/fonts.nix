# Shared font packages for NixOS and nix-darwin.
#
# The Term variant is used because the default spacing draws arrows and
# similar symbols two cells wide, so they overlap the next character in
# terminals. Term narrows them to one cell.
#
# Patch: the upstream IoskeleyMono and Pragmasevka Nerd Font releases have
# isFixedPitch = 0 in the post table, which makes CoreText (macOS) and
# Fontconfig (fc-list :mono) not recognize them as monospace.
# Ghostty/terminal emulators that filter to monospace-only fonts then
# can't find them.
# See: https://github.com/ahatem/IoskeleyMono/issues/19
pkgs: let
  pythonWithFontTools = pkgs.python3.withPackages (ps: [ps.fonttools]);
  fixFixedPitch = drv:
    drv.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pythonWithFontTools];
      postInstall =
        (old.postInstall or "")
        + ''
          for f in "$out/share/fonts/"*/*.ttf; do
            ${pythonWithFontTools}/bin/python3 -c "
          from fontTools.ttLib import TTFont
          font = TTFont('$f')
          if 'post' in font and font['post'].isFixedPitch == 0:
              font['post'].isFixedPitch = 1
              font.save('$f')
          "
          done
        '';
    });
  ioskeley-mono-fixed = fixFixedPitch (pkgs.ioskeley-mono.override {width = "SemiCondensed";}).term-nf;
  pragmasevka-nf = fixFixedPitch (pkgs.stdenvNoCC.mkDerivation rec {
    pname = "pragmasevka-nf";
    version = "1.7.0";
    src = pkgs.fetchzip {
      url = "https://github.com/shytikov/pragmasevka/releases/download/v${version}/Pragmasevka_NF.zip";
      hash = "sha256-QI4CHyZa3WxxGwhAZl+8d1uqcmM2tFgVwvfzGf32pcc=";
      stripRoot = false;
    };
    installPhase = ''
      runHook preInstall
      install -Dm644 -t $out/share/fonts/truetype *.ttf
      runHook postInstall
    '';
  });
  nordwand-mono = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "nordwand-mono";
    version = "1.3.1";
    src = pkgs.fetchzip {
      url = "https://github.com/tywr/Nordwand-Mono/releases/download/${version}/NordwandMono-TTF.zip";
      hash = "sha256-1gxHsMedpzsPxjRYFsTjaVOSgVFxD3VNtC3WQR9j9uI=";
      stripRoot = false;
    };
    installPhase = ''
      runHook preInstall
      install -Dm644 -t $out/share/fonts/truetype *.ttf
      runHook postInstall
    '';
  };
in
  with pkgs; [
    font-awesome
    nerd-fonts.geist-mono
    nerd-fonts.hack
    nerd-fonts.intone-mono
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.jetbrains-mono
    nerd-fonts.lilex
    nordwand-mono
    pragmasevka-nf
    inconsolata
    iosevka-bin
    ioskeley-mono-fixed
    sudo-font
  ]

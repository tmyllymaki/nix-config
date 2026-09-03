# Shared font packages for NixOS and nix-darwin.
#
# The Term variant is used because the default spacing draws arrows and
# similar symbols two cells wide, so they overlap the next character in
# terminals. Term narrows them to one cell.
#
# Patch: the upstream IoskeleyMono Nerd Font release has isFixedPitch = 0
# in the post table, which makes CoreText (macOS) and Fontconfig
# (fc-list :mono) not recognize it as monospace. Ghostty/terminal
# emulators that filter to monospace-only fonts then can't find it.
# See: https://github.com/ahatem/IoskeleyMono/issues/19
pkgs: let
  pythonWithFontTools = pkgs.python3.withPackages (ps: [ps.fonttools]);
  ioskeley-mono-fixed = pkgs.ioskeley-mono.semiCondensed-term-NF.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pythonWithFontTools];
    postInstall = (old.postInstall or "") + ''
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
in
  with pkgs; [
    font-awesome
    nerd-fonts.hack
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    nerd-fonts.jetbrains-mono
    iosevka-bin
    ioskeley-mono-fixed
  ]

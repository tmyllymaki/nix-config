{
  perSystem = {pkgs, ...}: {
    packages.finner-keyboard = let
      finnerFile = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/ruohola/finner/master/Finner.keylayout";
        sha256 = "sha256-IidFnfJseN2XP5MPN3pjBptftgHyGNmDKwPZwmJxfgo=";
      };
    in
      pkgs.stdenv.mkDerivation {
        name = "finner-keyboard-layout";
        dontUnpack = true;
        installPhase = ''
          mkdir -p $out
          cp ${finnerFile} $out/Finner.keylayout
        '';
      };
  };
}

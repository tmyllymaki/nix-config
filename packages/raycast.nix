{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.raycast = pkgs.stdenv.mkDerivation rec {
      pname = "raycast";
      version = "0.70.0";

      src = pkgs.fetchurl {
        url = "https://x-r2.raycast-releases.com/Raycast_Beta_${version}.0_2c8d9531b8_arm64.dmg";
        name = "Raycast.dmg";
        hash = "sha256-SIda8ovLoCztH48HLGRrUjBmTOyMCnqS2coocE/qkBw=";
      };

      nativeBuildInputs = [pkgs.undmg];
      sourceRoot = ".";
      phases = ["unpackPhase" "installPhase"];

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/Applications"
        cp -R "Raycast Beta.app" "$out/Applications/Raycast Beta.app"

        runHook postInstall
      '';

      meta = {
        description = "Raycast launcher";
        homepage = "https://www.raycast.com";
        platforms = ["aarch64-darwin" "x86_64-darwin"];
        license = lib.licenses.unfree;
      };
    };
  };
}

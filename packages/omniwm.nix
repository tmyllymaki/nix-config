{
  perSystem = {
    system,
    pkgs,
    lib,
    ...
  }: {
    packages = lib.optionalAttrs (system == "aarch64-darwin") {
      omniwm = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "OmniWM";
        version = "0.4.7.4";

        src = pkgs.fetchurl {
          url = "https://github.com/BarutSRB/OmniWM/releases/download/v${version}/OmniWM-v${version}.zip";
          sha256 = "sha256-6POMtHn5R1CQcz29QORrJaEuBxMPe7aYTtn0VWpQXIo=";
        };

        dontUnpack = true;
        nativeBuildInputs = [pkgs.libarchive];

        installPhase = ''
          mkdir -p $out/Applications/
          # Using bsdtar instead of unzip as unzip breaks .app codesigning.
          bsdtar -xf $src -C $out/Applications/

          # Symlink executables to bin
          mkdir -p $out/bin
          ln -s $out/Applications/OmniWM.app/Contents/MacOS/OmniWM $out/bin/OmniWM
          ln -s $out/Applications/OmniWM.app/Contents/MacOS/omniwmctl $out/bin/omniwmctl
        '';

        meta = {
          description = "MacOS Niri and Hyprland inspired tiling window manager that's developer signed and notorized (safe for managed enterprise environments). Aiming for parity and extra innovation.";
          homepage = "https://github.com/BarutSRB/OmniWM";
          license = lib.licenses.gpl2Only;
          mainProgram = "OmniWM";
          platforms = ["aarch64-darwin"];
        };
      };
    };
  };
}

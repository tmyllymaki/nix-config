{
  # REAPER from Cockos' tarball, built without stdenv's patchELF.
  #
  # Cockos links the Linux build with -z max-page-size=0x200000 (2 MiB LOAD
  # segments). stdenv's patchELF (patchelf) rewrites the program headers of such
  # a binary and ends up relocating .dynamic into a read-only LOAD segment — the
  # patched binary then dies inside ld.so with SEGV_ACCERR in dl_main, before
  # main() runs. `pkgs.reaper` 7.82 is patched that way and segfaults on start.
  #
  # So leave the ELF untouched: its interpreter stays /lib64/ld-linux-x86-64.so.2,
  # which nix-ld resolves (programs.nix-ld.enable in modules/nixos/base.nix), and
  # hand it the whole search path through the wrapper. That covers libSwell.so
  # plus everything REAPER dlopens: ALSA, pipewire-jack, PulseAudio, GTK, GL,
  # ffmpeg, VLC, lame.
  #
  # version/src/meta come from nixpkgs so a nixpkgs bump still moves REAPER
  # forward; drop this file if the patchelf layout issue gets fixed upstream.
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    inherit (pkgs.reaper) version src meta;

    libraryPath =
      lib.makeLibraryPath (with pkgs; [
        alsa-lib
        curl
        ffmpeg-headless
        fontconfig
        glibc
        gtk3
        lame
        libglvnd
        libpulseaudio
        libx11
        libxcursor
        libxext
        libxi
        libxinerama
        libxrandr
        libxml2_13
        openssl
        pipewire.jack
        stdenv.cc.cc.lib
        vlc
        xdotool
      ])
      # libGL/GLX vendor dispatch needs the driver's own libs, which NixOS keeps
      # out of the store.
      + ":/run/opengl-driver/lib";
  in {
    packages.reaper = pkgs.stdenv.mkDerivation {
      pname = "reaper";
      inherit version src;

      # install-reaper.sh's desktop integration shells out to xdg-desktop-menu /
      # xdg-icon-resource and uses `which`.
      nativeBuildInputs = [pkgs.makeWrapper pkgs.which pkgs.xdg-utils];

      # See the file header.
      dontPatchELF = true;
      dontBuild = true;
      dontStrip = true;

      installPhase = ''
        runHook preInstall

        HOME=$out/share XDG_DATA_HOME=$out/share ./install-reaper.sh \
          --install "$out/opt" \
          --integrate-user-desktop
        rm -f "$out/opt/REAPER/uninstall-reaper.sh"

        # xdg-icon-resource leaves $XDG_DATA_HOME/.icons -> .local/share/icons
        # dangling because HOME is redirected into $out; the real icons land in
        # share/icons/hicolor.
        rm -f "$out/share/.icons"

        mkdir -p "$out/bin"
        makeWrapper "$out/opt/REAPER/reaper" "$out/bin/reaper" \
          --prefix PATH : "${lib.makeBinPath [pkgs.xdg-utils]}" \
          --prefix LD_LIBRARY_PATH : "${libraryPath}" \
          --prefix NIX_LD_LIBRARY_PATH : "${libraryPath}"

        substituteInPlace "$out/share/applications/cockos-reaper.desktop" \
          --replace-fail "Exec=\"$out/opt/REAPER/reaper\"" "Exec=reaper"

        runHook postInstall
      '';

      meta =
        meta
        // {
          mainProgram = "reaper";
        };
    };
  };
}

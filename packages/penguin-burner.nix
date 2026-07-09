{
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    # Q2RTX runtime deps — the prebuilt binary needs these on LD_LIBRARY_PATH
    q2rtxLibs = with pkgs; [
      libidn2
      libpsl
      vulkan-loader
      openssl_1_1
      stdenv.cc.cc.lib
    ];
  in {
    packages.penguin-burner = pkgs.python3Packages.buildPythonApplication rec {
      pname = "penguin-burner";
      version = "0.5.9";
      pyproject = true;

      src = pkgs.fetchFromGitHub {
        owner = "jpietek";
        repo = "PenguinBurner";
        rev = "refs/tags/v${version}";
        hash = "sha256-lFXqRlUlNf1oV55xcdgDLN2BhzcIMPW90FmHWOUV0h4=";
      };

      build-system = with pkgs.python3Packages; [
        setuptools
        wheel
      ];

      dependencies = with pkgs.python3Packages; [
        pyside6
        colorama
        pyqtgraph
      ];

      # pyproject.toml declares PySide6-Essentials (pip name) but
      # nixpkgs provides pyside6. Patch to match for the dep check.
      postPatch = ''
        substituteInPlace pyproject.toml \
          --replace-fail '"PySide6-Essentials' '"pyside6'
      '';

      # NixOS-specific: the daemon and Q2RTX subprocesses need GPU libs
      # and runtime deps. Set them via wrapper so subprocesses inherit them.
      makeWrapperArgs = [
        "--set SDL_DYNAMIC_API ${pkgs.SDL2}/lib/libSDL2.so"
        "--prefix LD_LIBRARY_PATH : /run/opengl-driver/lib"
        "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath q2rtxLibs}"
      ];

      meta = {
        description = "NVIDIA GPU automatic undervolting tool with precision V/F tuning";
        homepage = "https://github.com/jpietek/PenguinBurner";
        license = lib.licenses.gpl3Only;
        mainProgram = "penguin-burner";
        platforms = lib.platforms.linux;
      };
    };
  };
}

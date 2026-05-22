{
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    # Q2RTX runtime deps — prebuilt binary needs these on LD_LIBRARY_PATH
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
      version = "0.1.7";
      pyproject = true;

      src = pkgs.fetchFromGitHub {
        owner = "jpietek";
        repo = "PenguinBurner";
        rev = "refs/tags/v${version}";
        hash = "sha256-zlxybtdCIDV00Ook+yD7xspaCiVSWpTatZ7WL4vrH+s=";
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

      postPatch = ''
        substituteInPlace ui/commands.py \
          --replace-fail '"XDG_RUNTIME_DIR",' '"XDG_RUNTIME_DIR","LD_LIBRARY_PATH",'

        substituteInPlace ui/commands.py \
          --replace-fail '"LD_LIBRARY_PATH",' '"LD_LIBRARY_PATH","SDL_DYNAMIC_API",'

        # Don't forward WAYLAND_DISPLAY — when set alongside gamescope
        # --backend headless, it breaks Q2RTX SDL Vulkan init inside gamescope.
        sed -i '/"WAYLAND_DISPLAY",/d' ui/commands.py
      '';

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

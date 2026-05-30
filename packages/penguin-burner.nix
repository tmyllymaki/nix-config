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
    # nvidia-smi lives in the proprietary userspace portion (.bin) of the
    # driver package; reference its store path so the systemd service gets
    # a pure, Nix-tracked PATH (not /run/current-system)
    nvidiaPackage = pkgs.linuxPackages.nvidia_x11.bin;
  in {
    packages.penguin-burner = pkgs.python3Packages.buildPythonApplication rec {
      pname = "penguin-burner";
      version = "0.2.2";
      pyproject = true;

      src = pkgs.fetchFromGitHub {
        owner = "jpietek";
        repo = "PenguinBurner";
        rev = "refs/tags/v${version}";
        hash = "sha256-JzPlgK9RaVzdg2VNwJq59cW3kA8f1P4ZPWOGps1ybOE=";
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

        # Inject LD_LIBRARY_PATH and PATH into the systemd service so the
        # daemon can find libnvidia-ml.so.1 and nvidia-smi on NixOS
        substituteInPlace runtime_service.py \
          --replace-fail \
            'f"Environment=SUDO_USER={sudo_user}\n"' \
            'f"Environment=SUDO_USER={sudo_user}\n" f"Environment=LD_LIBRARY_PATH=/run/opengl-driver/lib\n" f"Environment=PATH=${nvidiaPackage}/bin\n"'

        sed -i '/f"SUDO_USER={sudo_user}",/ a\            "--setenv", "LD_LIBRARY_PATH=/run/opengl-driver/lib",' runtime_service.py
        sed -i '/"--setenv", "LD_LIBRARY_PATH=\/run\/opengl-driver\/lib",/ a\            "--setenv", "PATH=${nvidiaPackage}/bin",' runtime_service.py
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

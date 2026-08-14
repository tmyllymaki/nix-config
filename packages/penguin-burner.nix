{
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    version = "0.7.8";

    src = pkgs.fetchFromGitHub {
      owner = "jpietek";
      repo = "PenguinBurner";
      rev = "refs/tags/v${version}";
      hash = "sha256-7T01zQPkjq2CHh9PF0kLfpOQ3pHLI0sWRHV9F9WZT5A=";
    };

    python = pkgs.python3Packages.python;

    deps = with pkgs.python3Packages; [
      pyside6
      colorama
      pyqtgraph
    ];

    # Privileged root daemon (Rust). The wheel's setup.py would invoke cargo
    # directly (no network in the Nix sandbox), so it is built separately with
    # buildRustPackage and dropped into the Python package in postInstall.
    penguin-burnerd = pkgs.rustPlatform.buildRustPackage {
      pname = "penguin-burnerd";
      inherit version src;
      sourceRoot = "source/burnerd";
      # importCargoLock: crates are fetched per-checksum from the committed
      # lockfile, so no cargoHash is needed.
      cargoLock.lockFile = "${src}/burnerd/Cargo.lock";
      # Two tests are timing/sandbox sensitive and fail in the Nix sandbox
      # (a frame-time snapshot assertion and a close_range fd test).
      doCheck = false;
      meta = {
        description = "PenguinBurner root daemon (socket API + runtime profile engine)";
        homepage = "https://github.com/jpietek/PenguinBurner";
        license = lib.licenses.gpl3Only;
        mainProgram = "penguin-burnerd";
        platforms = lib.platforms.linux;
      };
    };
  in {
    packages = {
      inherit penguin-burnerd;

      penguin-burner = pkgs.python3Packages.buildPythonApplication {
        pname = "penguin-burner";
        inherit version src;
        pyproject = true;

        build-system =
          (with pkgs.python3Packages; [
            setuptools
            wheel
          ])
          ++ [
            # setup.py compiles the native Vulkan latency layer with cmake
            pkgs.cmake
            pkgs.vulkan-headers
          ];

        dependencies = deps;

        # Skip setup.py's own native builds: the Rust daemon comes from
        # buildRustPackage above, and the NVAPI shim needs MinGW (optional —
        # in-game latency falls back to the Vulkan layer without it).
        env = {
          PENGUIN_BURNER_BUILD_DAEMON = "0";
          PENGUIN_BURNER_BUILD_NVAPI_SHIM = "0";
          # cmake is on PATH only for setup.py's layer build; the generic
          # cmakeConfigurePhase must not try to configure the Python project.
          dontUseCmakeConfigure = "1";
          # find_path for vulkan/vulkan.h in the latency layer build
          CMAKE_INCLUDE_PATH = "${pkgs.vulkan-headers}/include";
        };

        postPatch = ''
          # pyproject.toml declares PySide6-Essentials (pip name) but nixpkgs
          # provides pyside6. Patch to match for the dep check.
          substituteInPlace pyproject.toml \
            --replace-fail '"PySide6-Essentials' '"pyside6'

          # NixOS: the daemon strips LD_LIBRARY_PATH from the scan child, and
          # libcuda.so.1 lives in the NVIDIA driver's run path.
          substituteInPlace stability/cuda_bruteforce.py \
            --replace-fail 'ctypes.util.find_library("cuda") or "libcuda.so.1"' \
              'ctypes.util.find_library("cuda") or "/run/opengl-driver/lib/libcuda.so.1"'
        '';

        postInstall = ''
          mkdir -p "$out/${python.sitePackages}/runtime/daemon_bin"
          cp ${penguin-burnerd}/bin/penguin-burnerd \
            "$out/${python.sitePackages}/runtime/daemon_bin/penguin-burnerd"
        '';

        # GUI/CLI may dlopen libnvidia-ml.so.1 / libnvidia-api.so.1 for GPU
        # discovery; they live in the driver's run path on NixOS.
        #
        # The nix console-script bootstrap adds the package's site-packages
        # in-process, but the GUI spawns `sys.executable -m runtime.daemon_client`
        # children (Qt QProcess, inherited env): export PYTHONPATH so those
        # children can import the package.
        makeWrapperArgs = [
          "--prefix LD_LIBRARY_PATH : /run/opengl-driver/lib"
          "--prefix PYTHONPATH : $out/${python.sitePackages}"
          "--prefix PYTHONPATH : ${lib.makeSearchPath python.sitePackages deps}"
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
  };
}

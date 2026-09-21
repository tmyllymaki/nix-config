{
  flake.darwinModules.shell = {
    config,
    lib,
    pkgs,
    extras,
    ...
  }: {
    options.custom.system.shell = {
      enable = lib.mkEnableOption "system.shell";
    };

    config = lib.mkIf config.custom.system.shell.enable {
      environment.systemPackages =
        [
          extras.neovim-nightly
        ]
        ++ (with pkgs; [
          alejandra
          atuin
          btop
          cmake
          eza
          fd
          fish
          fnm
          fzf
          gh
          git
          iperf
          jujutsu
          mergiraf
          mise
          ncdu
          nh
          nixd
          pandoc
          pipx
          ripgrep
          starship
          topgrade
          uv
          wget
          yadm
          yazi
          zmx
          zoxide
        ]);

      fonts.packages = import ../../lib/fonts.nix pkgs;

      programs.fish.enable = true;
      programs.zsh.enable = true;

      system.activationScripts.postActivation.text = let
        finnerPath = "${extras.mypkgs.finner-keyboard}/Finner.bundle";
        targetDir = "/Library/Keyboard Layouts";
        targetPath = "${targetDir}/Finner.bundle";
        legacyPath = "${targetDir}/Finner.keylayout";
      in ''
        if [ ! -d "${finnerPath}" ]; then
          echo "Finner keyboard layout bundle not found at ${finnerPath}."
          exit 1
        fi

        # The bare .keylayout from earlier generations has no language attached,
        # so macOS keeps forcing the stock Finnish layout on. Remove it.
        if [ -L "${legacyPath}" ]; then
          echo "Removing legacy ${legacyPath}..."
          $DRY_RUN_CMD rm -f "${legacyPath}"
        fi

        # Only relink when the store path actually changed, so a rebuild that
        # does not touch the layout leaves /Library/Keyboard Layouts alone.
        if [ "$(readlink "${targetPath}" 2>/dev/null)" = "${finnerPath}" ]; then
          echo "Finner keyboard layout already up to date."
        else
          if [ ! -d "${targetDir}" ]; then
            echo "Creating ${targetDir} directory..."
            $DRY_RUN_CMD mkdir -p "${targetDir}"
          fi

          echo "Linking Finner keyboard layout to ${targetPath}..."
          # -n, not -h: activation runs with Nix's GNU coreutils ahead of /bin,
          # and GNU ln has no -h (BSD-only alias for -n).
          $DRY_RUN_CMD ln -sfn "${finnerPath}" "${targetPath}"
        fi
      '';
    };
  };
}

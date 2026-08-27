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

      raycastApp = lib.mkOption {
        type = lib.types.str;
        default = "Raycast";
        example = "Raycast Beta";
        description = ''
          Name of the installed Raycast application bundle. Restarted after the
          Finner keyboard layout is linked so it picks the layout up.
        '';
      };
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
          nixd
          pandoc
          pipx
          ripgrep
          starship
          topgrade
          wget
          yadm
          yazi
          zoxide
          zmx
        ]);

      fonts.packages = import ../../lib/fonts.nix pkgs;

      programs.fish.enable = true;
      programs.zsh.enable = true;

      system.activationScripts.postActivation.text = let
        raycastApp = config.custom.system.shell.raycastApp;
        finnerPath = "${extras.mypkgs.finner-keyboard}/Finner.keylayout";
        targetDir = "/Library/Keyboard Layouts";
        targetPath = "${targetDir}/Finner.keylayout";
      in ''
        if [ ! -d "${targetDir}" ]; then
          echo "Creating ${targetDir} directory..."
          $DRY_RUN_CMD mkdir -p "${targetDir}"
        fi

        if [ ! -f "${finnerPath}" ]; then
          echo "Finner keyboard layout file not found at ${finnerPath}."
          exit 1
        fi

        echo "Linking Finner keyboard layout to ${targetPath}..."
        if [ -L "${targetPath}" ]; then
          $DRY_RUN_CMD rm "${targetPath}"
        fi
        $DRY_RUN_CMD ln -sf "${finnerPath}" "${targetPath}"

        if pkill -x "${raycastApp}" 2>/dev/null; then
          sleep 2
        fi
        su - ${config.custom.user.name} -c "open -a '${raycastApp}'" 2>/dev/null || true
      '';
    };
  };
}

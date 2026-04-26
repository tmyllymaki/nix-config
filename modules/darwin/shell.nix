{
  flake.darwinModules.shell = {
    config,
    lib,
    pkgs,
    extras,
    ...
  }: {
    options.custom.system.shell.enable = lib.mkEnableOption "system.shell";

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
          mpv
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
        ]);

      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.hack
        nerd-fonts.iosevka-term
        nerd-fonts.iosevka
        iosevka-bin
      ];

      programs.fish.enable = true;
      programs.zsh.enable = true;

      system.activationScripts.postActivation.text = let
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
      '';
    };
  };
}

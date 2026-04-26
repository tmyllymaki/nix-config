{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ../common.nix
    ../../home-manager/modules/git.nix
    ../../home-manager/modules/vscode.nix
    ../../home-manager/modules/fish.nix
    ../../home-manager/modules/nvim.nix
    ../../home-manager/modules/fzf.nix
    ../../home-manager/modules/starship.nix
    ../../home-manager/modules/bat.nix
    ../../home-manager/modules/gnome.nix
    ../../home-manager/modules/firefox.nix
    #../../home-manager/modules/dotnet.nix
  ];

  home.username = "tm";
  home.homeDirectory = "/home/tm";

  home.packages = with pkgs; [
    kitty
    discord
    obsidian
    fh
    signal-desktop
  ];

  nixpkgs.config.permittedInsecurePackages =
    lib.optional (pkgs.obsidian.version == "1.5.3") "electron-25.9.0";

  programs.ssh = {
    enable = true;
    extraConfig = ''
      IdentityAgent ~/.1password/agent.sock
    '';
  };

  programs.emacs.enable = true;

  programs.nix-index-database.comma.enable = true;
  programs.nix-index.enable = true;

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
  };

  fonts.fontconfig.enable = true;
}

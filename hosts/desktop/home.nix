{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ../common.nix
    ../../home-manager/modules/gnome.nix
    ../../home-manager/modules/git.nix
    ../../home-manager/modules/fish.nix
    ../../home-manager/modules/nvim.nix
    ../../home-manager/modules/fzf.nix
    ../../home-manager/modules/starship.nix
    ../../home-manager/modules/bat.nix
    ../../home-manager/modules/firefox.nix
    ../../home-manager/modules/dotnet.nix
    ../../home-manager/modules/wezterm.nix
  ];

  home = {
    username = "tm";
    homeDirectory = "/home/tm";

    packages = with pkgs; [
      kitty
      discord
      fh
      signal-desktop
      webcord
      beeper
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "firefox";
    };
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      IdentityAgent ~/.1password/agent.sock
    '';
  };

  programs.nix-index-database.comma.enable = true;
  programs.nix-index.enable = true;

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  fonts.fontconfig.enable = true;
}

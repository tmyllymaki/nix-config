{
  config,
  pkgs,
  nixpkgs,
  lib,
  outputs,
  ...
}: let
  nixFlakes = pkgs.writeScriptBin "nixFlakes" ''
    exec ${pkgs.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
  '';
in {
  imports = [
    ../common.nix
    ../../home-manager/modules/fish.nix
    ../../home-manager/modules/nvim.nix
    ../../home-manager/modules/fzf.nix
    ../../home-manager/modules/starship.nix
    ../../home-manager/modules/bat.nix
    ../../home-manager/modules/rider-config.nix
    ../../home-manager/modules/regolith/regolith.nix
    ../../home-manager/modules/dconf.nix
  ];

  home = {
    username = "tm";
    homeDirectory = "/home/tm";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    comma
    ctags
    fd
    gitflow
    ibm-plex
    imagemagick
    jetbrains-mono
    mpv
    ngrok
    nixfmt
    stow
    wget
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "host.example.internal" = {
        user = "oiwa.myllymaki";
        identityFile = "~/.ssh/fresh.pub";
      };
      "host.example.internal" = {
        user = "tmyllymaki";
        identityFile = "~/.ssh/id_ed25519.pub";
      };
    };
  };

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Timo Myllymäki";
    userEmail = "timo.myllymaki@pinja.com";
    extraConfig = {pull.rebase = true;};
  };

  fonts.fontconfig.enable = true;
}

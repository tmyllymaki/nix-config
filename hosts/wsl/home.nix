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
  ];

  home = {
    username = "tm";
    homeDirectory = "/home/tm";
  };

  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;

    shellAliases = {
      ssh = "ssh.exe";
      ssh-add = "ssh-add.exe";
    };
  };

  home.packages = with pkgs; [
    comma
    ctags
    fd
    wget
    stow
    emacs29-pgtk
  ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "host.example.internal" = {
        user = "oiwa.myllymaki";
        identityFile = "~/.ssh/fresh";
      };
      "host.example.internal" = {
        user = "tmyllymaki";
        identityFile = "~/.ssh/id_ed25519";
      };
      "lerp.latenkone.fi" = {
        user = "devops";
        identityFile = "~/.ssh/id_rsa";
      };
    };
  };

  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Timo Myllymäki";
    userEmail = "timo.myllymaki@pinja.com";
    extraConfig = {
      pull.rebase = true;
      core.sshCommand = "'/mnt/c/Windows/System32/OpenSSH/ssh.exe'";
    };
  };

  fonts.fontconfig.enable = true;
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
}

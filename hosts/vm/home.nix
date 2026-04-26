{
  pkgs,
  lib,
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
    ../../home-manager/modules/firefox.nix
    #../../home-manager/modules/dotnet.nix
    ../../home-manager/modules/rider-config.nix
    # ../../home-manager/modules/dconf.nix
    # ../../home-manager/modules/gnome.nix
  ];
  home.username = "tm";
  home.homeDirectory = "/home/tm";

  home.packages = with pkgs; [
    fh
  ];

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ../../programs/kitty;
    environment = {
      TERM = "xterm-256color";
    };
  };

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
    };
  };

  xresources.extraConfig = builtins.readFile ../../programs/Xresources;

  xdg.configFile."i3/config".text = builtins.readFile ../../programs/i3;
  xdg.enable = true;

  programs.rofi = {
    enable = true;
    theme = ../../programs/rofi;
    extraConfig = {
      show-icons = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "tty";

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };

  xsession = {
    enable = true;
    initExtra = ''
      dbus-update-activation-environment --systemd DISPLAY
      eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
      export SSH_AUTH_SOCK
      xset s off -dpms # disable screen saver
    '';
  };

  services.gnome-keyring = {
    enable = true;
    components = ["pkcs11" "secrets" "ssh"];
  };

  programs.i3status = {
    enable = true;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };
}

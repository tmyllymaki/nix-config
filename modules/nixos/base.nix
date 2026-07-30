{
  flake.nixosModules.base = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: {
    options.custom.system.base.enable = lib.mkEnableOption "system.base";

    config = lib.mkIf config.custom.system.base.enable {
      nix = {
        optimise.automatic = true;
        nixPath = ["nixpkgs=${inputs.nixpkgs}"];
        registry.nixpkgs.flake = inputs.nixpkgs;
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
          ];
          substituters = [
            "https://attic.xuyh0120.win/lantian"
            "https://noctalia.cachix.org"
            "https://nix-community.cachix.org/"
            "https://cache.nixos.org/"
          ];
          trusted-public-keys = [
            "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
      };

      nixpkgs.config.allowAliases = false;

      environment.etc."nix/nixpkgs-config.nix".text = ''
        {
          allowAliases = false;
          allowUnfree = true;
        }
      '';

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 7d --keep 3";
        flake = "/etc/nixos";
      };

      time.timeZone = "Europe/Helsinki";

      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "fi_FI.UTF-8";
        LC_IDENTIFICATION = "fi_FI.UTF-8";
        LC_MEASUREMENT = "fi_FI.UTF-8";
        LC_MONETARY = "fi_FI.UTF-8";
        LC_NAME = "fi_FI.UTF-8";
        LC_NUMERIC = "fi_FI.UTF-8";
        LC_PAPER = "fi_FI.UTF-8";
        LC_TELEPHONE = "fi_FI.UTF-8";
        LC_TIME = "fi_FI.UTF-8";
      };

      console.keyMap = "fi";

      networking.networkmanager.enable = true;

      programs.fish.enable = true;
      programs.nix-ld.enable = true;
      programs._1password.enable = true;
      programs._1password-gui.enable = true;
      programs._1password-gui.polkitPolicyOwners = ["tm"];
      programs.command-not-found.enable = false;

      environment.shells = [pkgs.fish];
      environment.systemPackages = with pkgs; [
        alejandra
        cliphist
        direnv
        ghostty
        git
        jq
        pavucontrol
        pwvucontrol
        ripgrep
        tree
        unzip
        wget
        wl-clipboard
        nixd
      ];

      systemd.services.llama-cpp-server = {
        # If you plan to run it as a service
        environment = {
          LD_LIBRARY_PATH = "${pkgs.linuxPackages.nvidia_x11}/lib";
        };
      };

      virtualisation.docker.enable = true;
      hardware.nvidia-container-toolkit.enable = true;

      fonts.packages = import ../../lib/fonts.nix pkgs;

      security.rtkit.enable = true;
      security.polkit.enable = true;

      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
      services.flatpak.enable = true;
      services.power-profiles-daemon.enable = true;
      services.tailscale.enable = true;
      services.upower.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      environment.sessionVariables = {
        NH_FLAKE = "/etc/nixos";
        NIXOS_OZONE_WL = "1";
        STEAM_FORCE_DESKTOPUI_SCALING = "1.5";
      };
    };
  };
}

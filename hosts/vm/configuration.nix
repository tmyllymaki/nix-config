{
  config,
  lib,
  nixpkgs,
  pkgs,
  ...
}: {
  imports = [
    ../../programs/non-free.nix
    ./hardware-configuration.nix
    ../../programs/dotnet.nix
  ];
  nixpkgs.config.packageOverrides = pkgs: {
    iosevka-ss03 = pkgs.iosevka.override {set = "ss03";};
    #onedrive = unstable.onedrive;
  };
  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.xserver.videoDrivers = ["vmware"];
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.consoleMode = "0";
  networking.firewall.enable = false;

  users.users.tm = {
    isNormalUser = true;
    createHome = true;
    extraGroups = ["wheel" "docker" "vboxusers" "video" "audio" "disk" "networkmanager"];
    home = "/home/tm";
    uid = 1000;
    shell = pkgs.fish;
    hashedPassword = "***REMOVED***";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmTIzff+A0lJ0AlmZ8HOXPZAA4bPKYHI7Rowi2PYOgV tm"
    ];
  };

  environment.shells = with pkgs; [fish];

  programs.fish.enable = true;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    nixPath = ["nixpkgs=${nixpkgs}"];
    registry.nixpkgs.flake = nixpkgs;
    package = pkgs.nixUnstable;
    settings = {
      substituters = [
        "https://nix-community.cachix.org/"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = ["tm"];

  fonts.packages = with pkgs; [
    font-awesome
    iosevka
    fira-code
    montserrat
    # iosevka-ss03
  ];

  environment.systemPackages = with pkgs; [
    wget
    spotify
    # docker-compose
    direnv
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    tailscale
    gnome.gnome-tweaks
    (jetbrains.plugins.addPlugins jetbrains.rider [
      "github-copilot"
      "ideavim"
    ])
    (writeShellScriptBin "xrandr-auto" ''
      xrandr --output Virtual1 --auto
    '')
  ];

  # services.tailscale.enable = true;
  virtualisation = {
    docker = {
      enable = true;
      rootless.enable = true;
    };
    vmware.guest.enable = true;
  };

  networking.hostName = "nixvm"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Select internationalisation properties.
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    # interval = { Weekday = 0; Hour = 0; Minute = 0; };
    options = "--delete-older-than 30d";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    dpi = 192;

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      defaultSession = "none+i3";
      lightdm.enable = true;
      autoLogin = {
        enable = true;
        user = "tm";
      };

      # sessionCommands = ''
      #   ${pkgs.xorg.xset}/bin/xset r rate 200 40
      # '';
    };

    windowManager.i3.enable = true;
  };

  # Enable the GNOME Desktop Environment.
  programs.dconf.enable = true;

  services.xserver = {
    layout = "fi";
    xkbVariant = "nodeadkeys";
    xkbOptions = "caps:swapescape";
  };

  # Configure console keymap
  console.keyMap = "fi";

  networking.extraHosts = ''${builtins.readFile ./extrahosts} '';

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";

  security.pam.services.lightdm.enableGnomeKeyring = true;
  security = {
    sudo.wheelNeedsPassword = false;
  };

  programs.seahorse.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # programs.dconf.enable = true;

  system.stateVersion = "23.05";
}

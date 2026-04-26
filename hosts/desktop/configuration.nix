{
  config,
  lib,
  nixpkgs,
  pkgs,
  nvtopPackages,
  pkgs-local,
  ...
}: {
  imports = [
    ../../programs/non-free.nix
    ../synology.nix
  ];
  nixpkgs.config.packageOverrides = pkgs: {
    iosevka-ss03 = pkgs.iosevka.override {set = "ss03";};
    #onedrive = unstable.onedrive;
  };

  nixpkgs.overlays = [
    # GNOME 46: triple-buffering-v4-46
    (final: prev: {
      gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
        mutter = gnomePrev.mutter.overrideAttrs (old: {
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.gnome.org";
            owner = "vanvugt";
            repo = "mutter";
            hash = "sha256-C2VfW3ThPEZ37YkX7ejlyumLnWa9oij333d5c4yfZxc=";
            rev = "triple-buffering-v4-46";
          };
        });
      });
    })
  ];

  time.hardwareClockInLocalTime = true;

  nixpkgs.config.allowAliases = false;

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

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 3";
    flake = "/home/tm/dotfiles";
  };

  programs.fish.enable = true;
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = ["tm"];
  programs.command-not-found.enable = false;
  # programs.nix-index-database.comma.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.sessionVariables = {
    STEAM_FORCE_DESKTOPUI_SCALING = "1.5";
  };

  programs.gamemode.enable = true;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    nixPath = ["nixpkgs=${nixpkgs}"];
    registry.nixpkgs.flake = nixpkgs;
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

  fonts.packages = with pkgs; [
    font-awesome
    iosevka
    jetbrains-mono
    # iosevka-ss03
  ];

  environment.systemPackages =
    [
      pkgs.wget
      pkgs.spotify
      # docker-compose
      pkgs.direnv
      pkgs.vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      pkgs.wget
      pkgs.git
      pkgs.tailscale
      pkgs.warp-terminal
      pkgs.gnome-tweaks
      pkgs.nvtopPackages.nvidia
    ]
    ++ [
      pkgs.gnomeExtensions.dash-to-dock
      pkgs.gnomeExtensions.tray-icons-reloaded
      pkgs.gnomeExtensions.search-light
      pkgs.gnomeExtensions.no-overview
      pkgs.gnomeExtensions.gtile
      pkgs.gnomeExtensions.ddterm
      # pkgs-local.gnomeExtensions.ddterm
    ]
    ++ [
      # pkgs.libsForQt5.polonium
    ];

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gnome-music
      gedit
      cheese
      epiphany
      yelp
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-contacts
      gnome-initial-setup
    ]);

  services.tailscale.enable = true;
  services.mullvad-vpn.enable = true;

  virtualisation = {
    docker = {
      enable = true;
      rootless.enable = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nix-desktop"; # Define your hostname.

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;
  #services.displayManager.defaultSession = "plasma";
  # services.displayManager.sddm.wayland.enable = false;
  #environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fi";
    variant = "nodeadkeys";
    options = "caps:escape_shifted_capslock";
  };

  # Configure console keymap
  console.keyMap = "fi";

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.polkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  programs.dconf.enable = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # supported GPUs is at:
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # package = config.boot.kernelPackages.nvidiaPackages.latest;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
  services.xserver.deviceSection = ''
    Option "Coolbits" "28"
  '';
  # services.xserver.config = ''
  #   Section "Device"
  #     Driver "nvidia"
  #     Option "Coolbits" "31"
  #     Identifier "Device-nvidia[0]"
  #   EndSection
  # '';

  services.sunshine = {
    enable = true;
    autoStart = false;
    openFirewall = true;
    capSysAdmin = true;
  };

  services.flatpak.enable = true;

  system.stateVersion = "23.05";
}

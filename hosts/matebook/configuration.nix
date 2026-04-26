{
  config,
  lib,
  nixpkgs,
  pkgs,
  ...
}: let
  nixpkgs-tars = "https://github.com/NixOS/nixpkgs/archive/";
in {
  imports = [../../programs/non-free.nix];
  nixpkgs.config.packageOverrides = pkgs: {
    iosevka-ss03 = pkgs.iosevka.override {set = "ss03";};
    #onedrive = unstable.onedrive;
  };

  users.users.tm = {
    isNormalUser = true;
    createHome = true;
    extraGroups = ["wheel" "docker" "vboxusers" "video" "audio" "disk" "networkmanager"];
    home = "/home/tm";
    uid = 1000;
    shell = pkgs.fish;
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    # interval = { Weekday = 0; Hour = 0; Minute = 0; };
    options = "--delete-older-than 30d";
  };

  environment.shells = with pkgs; [fish];

  programs.fish.enable = true;
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = ["tm"];
  programs.command-not-found.enable = false;
  # programs.nix-index-database.comma.enable = true;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
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

  fonts.packages = with pkgs; [
    font-awesome
    iosevka
    # iosevka-ss03
  ];

  environment.systemPackages = with pkgs;
    [
      wget
      spotify
      # docker-compose
      direnv
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      git
      tailscale
      gnome.gnome-tweaks
    ]
    ++ [
      gnomeExtensions.dash-to-dock
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.search-light
      gnomeExtensions.no-overview
      gnomeExtensions.gtile
    ];

  environment.gnome.excludePackages =
    (with pkgs; [gnome-photos gnome-tour gedit])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      epiphany # web browser
      geary # email reader
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      yelp # Help view
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

  #services.fprintd = {
  #enable = true;
  #tod = {
  #enable = true;
  #driver = pkgs.libfprint-2-tod1-goodix;
  #};
  #};

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixtop"; # Define your hostname.
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.

  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  services.desktopManager.plasma6.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.defaultSession = "plasma";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fi";
    variant = "nodeadkeys";
    options = "caps:swapescape";
  };

  # Configure console keymap
  console.keyMap = "fi";

  # Enable sound with pipewire.
  sound.enable = true;
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

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.naturalScrolling = true;
  services.xserver.libinput.touchpad.middleEmulation = true;
  services.xserver.libinput.touchpad.tapping = true;

  programs.dconf.enable = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  # specialisation = {
  #   nvidia.configuration = {
  #     # Nvidia Configuration
  #     services.xserver.videoDrivers = ["nvidia"];
  #     hardware.opengl.enable = true;

  #     # Optionally, you may need to select the appropriate driver version for your specific GPU.
  #     hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  #     # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
  #     hardware.nvidia.modesetting.enable = true;
  #     hardware.nvidia.open = false;
  #     hardware.nvidia.powerManagement.enable = false;
  #     hardware.nvidia.powerManagement.finegrained = false;
  #     hardware.nvidia.nvidiaSettings = true;

  #     hardware.nvidia.prime = {
  #       sync.enable = true;

  #       # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
  #       nvidiaBusId = "PCI:1:0:0";

  #       # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
  #       intelBusId = "PCI:0:2:0";
  #     };
  #   };
  # };

  system.stateVersion = "23.05";
}

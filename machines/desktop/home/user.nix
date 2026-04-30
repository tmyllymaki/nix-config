{
  flake.nixosMachineModules.desktop = {
    config,
    pkgs,
    ...
  }: {
    users.users.tm = {
      isNormalUser = true;
      createHome = true;
      uid = 1000;
      home = "/home/tm";
      shell = pkgs.fish;
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "docker"
      ];
      hashedPassword = "***REMOVED***";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmTIzff+A0lJ0AlmZ8HOXPZAA4bPKYHI7Rowi2PYOgV tm"
      ];
    };

    hjem.users.tm = {
      directory = config.users.users.tm.home;
      clobberFiles = true;

      custom.quickenable.hjem.modules = [
        "git"
        "base"
        "desktop"
	"atuin"
	"llm-agents"
	"bat"
	"dotnet"
	"mpv"
	"rider-config"
	"starship"
	"wezterm"
	"zed"
      ];
    };
  };
}

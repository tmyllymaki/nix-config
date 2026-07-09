{
  flake.nixosModules.rustdesk-server = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.custom.system.rustdesk-server;
  in {
    options.custom.system.rustdesk-server = {
      enable = lib.mkEnableOption "system.rustdesk-server";

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open TCP 21115-21119 and UDP 21116 in the firewall.";
      };

      relayHosts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["rustdesk.example.com"];
        description = "IP addresses or DNS names of the RustDesk relay server(s).";
      };

      alwaysUseRelay = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Set ALWAYS_USE_RELAY=Y env var on the signal server (for NAT traversal).";
      };
    };

    config = lib.mkIf cfg.enable {
      services.rustdesk-server = {
        enable = true;
        openFirewall = cfg.openFirewall;
        signal.relayHosts = cfg.relayHosts;
      };

      systemd.services.rustdesk-signal.environment.ALWAYS_USE_RELAY =
        lib.mkIf cfg.alwaysUseRelay "Y";
    };
  };
}

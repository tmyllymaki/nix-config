{
  flake.hjemModules.ssh = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
    agentSock =
      if isDarwin
      then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      else "~/.1password/agent.sock";
  in {
    options.custom.home.ssh.enable = lib.mkEnableOption "home.ssh";

    # The key for each host is not chosen here, so this public repository holds
    # no host names or keys. ssh uses the first value it finds, so the private
    # includes come before the catch-all agent setting.
    #   ~/.ssh/1Password/config  written by 1Password from SSH bookmarks
    #   ~/.ssh/config.d/*        hand-written, unmanaged host-to-key mappings
    config = lib.mkIf config.custom.home.ssh.enable {
      files.".ssh/config" = {
        clobber = true;
        text =
          ''
            Include ~/.ssh/1Password/config
            Include ~/.ssh/config.d/*
          ''
          + lib.optionalString isDarwin ''
            Include ~/.colima/ssh_config
          ''
          + ''

            Host *
              IdentityAgent "${agentSock}"
          '';
      };
    };
  };
}

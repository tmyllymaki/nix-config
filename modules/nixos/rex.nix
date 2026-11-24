# Rex: the `rex` command plus a personal server for each user, so the Mac app
# can reach this machine as a remote host over SSH (ssh://tm@nix-desktop).
#
# Rex's flake ships a NixOS module, but it only runs the shared server (as the
# `rex` account) or the root login server. The personal server lives in its
# home-manager module, which hjem can't use, so the user service below mirrors
# that one (home-manager-module.nix in the flake).
#
# Lingering keeps the server running while logged out; machines/desktop sets
# users.users.tm.linger. A switch doesn't restart the running server, because
# that ends every session. After an update: systemctl --user restart rex
{
  flake.nixosModules.rex = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: let
    rex = inputs.rex.packages.${pkgs.stdenv.hostPlatform.system}.rex;
  in {
    options.custom.system.rex.enable = lib.mkEnableOption "system.rex";

    config = lib.mkIf config.custom.system.rex.enable {
      # Also links share/terminfo into /run/current-system/sw, where login
      # shells' TERMINFO_DIRS finds xterm-rex.
      environment.systemPackages = [rex];

      # Makes ssh from a Rex terminal send TERM=xterm-256color to hosts that
      # lack the xterm-rex entry. NixOS ignores /etc/ssh/ssh_config.d.
      programs.ssh.extraConfig = lib.mkAfter ''
        Include ${rex}/share/rex/ssh_config.d/50-rex.conf
      '';

      systemd.user.services.rex = {
        description = "Rex Server";
        documentation = ["https://superlogical.com"];
        after = ["network-online.target"];
        wantedBy = ["default.target"];
        # A restart ends every session; restart by hand when ready.
        restartIfChanged = false;

        environment = {
          # Drop the minimal PATH NixOS gives units, which terminals would
          # inherit; the user manager's default PATH covers the system and
          # per-user profiles.
          PATH = lib.mkForce null;
          # Units don't get the login shell's TERMINFO_DIRS. The trailing
          # colon keeps ncurses' default search for other entries.
          TERMINFO_DIRS = "${rex}/share/terminfo:";
          # Go refuses to start if GODEBUG names a removed behaviour.
          GODEBUG = "";
          # Only valid together with Delegate below.
          REX_CGROUP_DELEGATED = "1";
        };

        serviceConfig = {
          Type = "notify";
          NotifyAccess = "main";
          # No --listen or --state-dir: the server must use the same socket
          # as every `rex` command, in $XDG_RUNTIME_DIR/rex.
          ExecStart = "${lib.getExe rex} server run --log-format text";
          Restart = "on-failure";
          RestartSec = "5s";
          # SIGTERM only the server so it can save sessions before closing
          # terminals.
          KillMode = "mixed";
          # One terminal hitting the OOM killer must not stop the unit.
          OOMPolicy = "continue";
          OOMScoreAdjust = 0;
          # Lets the server put each terminal in its own cgroup.
          Delegate = true;
          DelegateSubgroup = "server";
        };
      };
    };
  };
}

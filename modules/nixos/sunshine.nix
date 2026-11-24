# Sunshine game streaming for Moonlight (Steam Deck).
#
# Each stream session creates a KWin virtual output sized to the client
# (krfb-virtualmonitor), switches the desktop to it and turns the physical
# monitor off. Ending the session restores the monitor. Plasma only.
{
  flake.nixosModules.sunshine = {
    config,
    lib,
    pkgs,
    ...
  }: let
    physOutput = "DP-1"; # from: kscreen-doctor -o
    physMode = "3840x2160@144"; # restored after streaming
    faugusGame = "wow-forever"; # gameid in ~/.config/faugus-launcher/games.json

    # KWin prefixes virtual outputs with "Virtual-".
    vmName = "sunshine-vm";
    vmOutput = "Virtual-${vmName}";

    streamStart = pkgs.writeShellApplication {
      name = "stream-start";
      runtimeInputs = with pkgs; [kdePackages.krfb kdePackages.libkscreen coreutils gnugrep util-linux];
      text = ''
        W=''${SUNSHINE_CLIENT_WIDTH:-1280}
        H=''${SUNSHINE_CLIENT_HEIGHT:-800}
        FPS=''${SUNSHINE_CLIENT_FPS:-60}

        # The VNC side is unused; a random password keeps it closed.
        setsid krfb-virtualmonitor --resolution "''${W}x''${H}" --name ${vmName} \
          --password "$(head -c12 /dev/urandom | base64)" --port 5905 >/dev/null 2>&1 &

        for _ in $(seq 20); do kscreen-doctor -o | grep -q "${vmOutput}" && break; sleep 0.5; done
        kscreen-doctor "output.${vmOutput}.addCustomMode.$W.$H.$((FPS * 1000)).full"
        kscreen-doctor "output.${vmOutput}.mode.''${W}x''${H}@$FPS"
        kscreen-doctor "output.${physOutput}.disable"
      '';
    };

    streamStop = pkgs.writeShellApplication {
      name = "stream-stop";
      runtimeInputs = with pkgs; [kdePackages.libkscreen procps];
      text = ''
        kscreen-doctor "output.${physOutput}.enable" "output.${physOutput}.mode.${physMode}" || true
        pkill -f krfb-virtualmonitor || true
      '';
    };

    wowStop = pkgs.writeShellScript "wow-stop" ''
      ${pkgs.procps}/bin/pkill -f Wow.exe || true
      sleep 3
      ${pkgs.procps}/bin/pkill -f Battle.net || true
    '';
  in {
    options.custom.system.sunshine.enable = lib.mkEnableOption "system.sunshine";

    config = lib.mkIf config.custom.system.sunshine.enable {
      environment.systemPackages = [streamStart streamStop pkgs.kdePackages.krfb];

      services.sunshine = {
        enable = true;
        # Without CUDA, Sunshine cannot load libcuda for NVENC and falls back to
        # Vulkan encoding, which flickers on this NVIDIA card.
        package = pkgs.sunshine.override {cudaSupport = true;};
        autoStart = true;
        # CAP_SYS_ADMIN is only needed for kms capture.
        capSysAdmin = false;
        openFirewall = true;

        settings = {
          capture = "kwin"; # kms cannot see krfb-virtualmonitor outputs
          global_prep_cmd = builtins.toJSON [
            {
              do = lib.getExe streamStart;
              undo = lib.getExe streamStop;
            }
          ];
        };

        # Declarative apps.json: apps added in the web UI are replaced on restart.
        applications.apps = [
          {name = "Desktop";}
          {
            name = "WoW Forever";
            cmd = "${lib.getExe pkgs.faugus-launcher} --game ${faugusGame}";
            auto-detach = "true";
            prep-cmd = [
              {
                do = "";
                undo = "${wowStop}";
              }
            ];
          }
        ];
      };
    };
  };
}

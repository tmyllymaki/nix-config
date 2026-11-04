{
  flake.nixosModules.audio = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.system.audio.enable = lib.mkEnableOption "system.audio";

    config = lib.mkIf config.custom.system.audio.enable {
      # Everything here assumes services.pipewire is enabled (see base.nix).

      # pipewire-jack replaces a standalone jackd, so JACK clients (REAPER in
      # JACK mode, Ardour, Carla, wineasio) share the same graph as the rest of
      # the desktop. Also sets LD_LIBRARY_PATH so libjack clients find it.
      services.pipewire.jack.enable = true;

      # Default graph quantum is 1024 samples = ~21 ms per buffer @48k, which
      # feels mushy for live playing. 128 samples = 2.7 ms. max-quantum caps
      # what a stream may negotiate, otherwise a browser can drag the whole
      # graph back up mid-session.
      services.pipewire.extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 128;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 512;
        };
      };

      # Force the same buffer size on JACK clients, so a DAW asking for 1024
      # doesn't silently undo the setting above.
      services.pipewire.extraConfig.jack."91-jack-node-latency" = {
        "jack.properties"."node.latency" = "128/48000";
      };

      # JACK clients (REAPER) get auto-patched to the default sink/source, and
      # the box has several sound cards — without this REAPER lands on the
      # onboard/USB-audio device instead of the interface. Names are per-unit
      # (they embed the Scarlett's serial); if the interface changes, update
      # them from `pw-dump | grep node.name`.
      services.pipewire.wireplumber.extraConfig."51-default-nodes" = {
        "default.configured.audio.sink" = {
          name = "alsa_output.usb-Focusrite_Scarlett_Solo_USB_Y7BCK4V157DEEE-00.pro-output-0";
        };
        "default.configured.audio.source" = {
          name = "alsa_input.usb-Focusrite_Scarlett_Solo_USB_Y7BCK4V157DEEE-00.pro-input-0";
        };
      };

      # WirePlumber suspends idle ALSA nodes after 5 s: audible pops and a delay
      # on the first note after a pause. Keep the interface always running.
      services.pipewire.wireplumber.extraConfig."99-disable-suspend" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {"node.name" = "~alsa_input.*";}
              {"node.name" = "~alsa_output.*";}
            ];
            actions."update-props"."session.suspend-timeout-seconds" = 0;
          }
        ];
      };

      # pipewire.nix only grants realtime limits to the @pipewire group; user
      # processes (REAPER, Carla, Wine) need them for their own RT threads.
      # Takes effect on next login.
      #
      # PAM limits alone are not enough: apps launched from the desktop menu run
      # as transient app-*.service units under the user manager, which does not
      # go through a pam_limits session. Without the DefaultLimit* below those
      # processes keep the kernel defaults (8 MiB memlock, rtprio 0) and yabridge
      # reports "you have not yet set up realtime privileges".
      systemd.user.settings.Manager = {
        DefaultLimitMEMLOCK = "infinity";
        DefaultLimitRTPRIO = 95;
        DefaultLimitNICE = -19;
      };

      security.pam.loginLimits = [
        {
          domain = "@audio";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
        {
          domain = "@audio";
          item = "rtprio";
          type = "-";
          value = "95";
        }
        {
          domain = "@audio";
          item = "nice";
          type = "-";
          value = "-19";
        }
      ];

      # USB autosuspend is the classic source of xruns and dropouts on
      # class-compliant interfaces. Off globally (this is a desktop), plus a
      # targeted udev rule for Focusrite (vendor 1235) so a replug never
      # re-enables it before the kernel param applies.
      boot.kernelParams = ["usbcore.autosuspend=-1"];
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1235", TEST=="power/control", ATTR{power/control}="on"
      '';

      # power-profiles-daemon is enabled in base.nix and owns the CPU governor.
      # Pick "Performance" in the KDE power applet before playing; do not also
      # set powerManagement.cpuFreqGovernor, they fight over it.
    };
  };
}

# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{lib, ...}:
with lib.hm.gvariant; {
  dconf.settings = {
    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };

    "org/gnome/desktop/input-sources" = {
      current = mkUint32 0;
      per-window = false;
      sources = [(mkTuple ["xkb" "fi+nodeadkeys"])];
      xkb-options = ["caps:escape_shifted_capslock"];
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "fingers";
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Shift><Super>q"];
      maximize = [];
      minimize = ["<Super>comma"];
      move-to-monitor-down = [];
      move-to-monitor-left = [];
      move-to-monitor-right = [];
      move-to-monitor-up = [];
      move-to-workspace-1 = ["<Shift><Super>exclam"];
      move-to-workspace-2 = ["<Shift><Super>quotedbl"];
      move-to-workspace-3 = ["<Shift><Super>numbersign"];
      move-to-workspace-4 = ["<Shift><Super>currency"];
      move-to-workspace-down = [];
      move-to-workspace-up = [];
      switch-group = ["<Alt>section"];
      switch-group-backward = ["<Shift><Alt>section"];
      switch-input-source = [];
      switch-input-source-backward = [];
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
      switch-to-workspace-down = ["<Primary><Super>Down" "<Primary><Super>j"];
      switch-to-workspace-left = [];
      switch-to-workspace-right = [];
      switch-to-workspace-up = ["<Primary><Super>Up" "<Primary><Super>k"];
      toggle-maximized = ["<Super>m"];
      unmaximize = [];
    };

    "org/gnome/desktop/wm/preferences" = {
      auto-raise = false;
      focus-mode = "click";
      num-workspaces = 4;
      titlebar-font = "Noto Sans Display 11";
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      center-new-windows = true;
      dynamic-workspaces = false;
      edge-tiling = true;
      experimental-features = [];
      workspaces-only-on-primary = true;
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = ["<Super>Left"];
      toggle-tiled-right = ["<Super>Right"];
    };

    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      area-screenshot-clip = ["<Shift><Alt>s"];
      rotate-video-lock-static = [];
    };

    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = false;
      sleep-inactive-ac-timeout = 3600;
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "suspend";
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = false;
    };

    "org/gnome/shell/extensions/bluetooth-quick-connect" = {
      show-battery-value-on = true;
    };

    "org/gnome/shell/keybindings" = {
      open-application-menu = [];
      show-screenshot-ui = ["<Shift><Alt>s"];
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
      switch-to-application-5 = [];
      switch-to-application-6 = [];
      switch-to-application-7 = [];
      switch-to-application-8 = [];
      switch-to-application-9 = [];
      toggle-message-tray = ["<Super>v"];
      toggle-overview = [];
    };

    "org/gnome/system/location" = {
      enabled = false;
    };

    "com/github/amezin/ddterm" = {
      audible-bell = false;
      background-color = "rgb(0,43,54)";
      bold-color = "#000000";
      bold-color-same-as-fg = true;
      bold-is-bright = false;
      cursor-background-color = "#000000";
      cursor-colors-set = false;
      cursor-foreground-color = "rgb(154,153,150)";
      custom-font = "JetBrainsMono Nerd Font 12";
      ddterm-toggle-hotkey = ["F11"];
      foreground-color = "rgb(131,148,150)";
      hide-animation-duration = 0.1;
      hide-when-focus-lost = false;
      highlight-background-color = "#000000";
      highlight-colors-set = false;
      highlight-foreground-color = "rgb(154,153,150)";
      new-tab-button = false;
      notebook-border = false;
      override-window-animation = true;
      palette = ["rgb(0,0,0)" "rgb(205,0,0)" "rgb(0,205,0)" "rgb(205,205,0)" "rgb(0,0,238)" "rgb(205,0,205)" "rgb(0,205,205)" "rgb(229,229,229)" "rgb(127,127,127)" "rgb(255,0,0)" "rgb(0,255,0)" "rgb(255,255,0)" "rgb(92,92,255)" "rgb(255,0,255)" "rgb(0,255,255)" "rgb(255,255,255)"];
      shortcut-next-tab = ["<Primary>Tab"];
      shortcut-page-close = ["<Shift><Control>w"];
      shortcut-prev-tab = ["<Primary><Shift>Tab"];
      shortcut-switch-to-tab-1 = ["<Control>1"];
      shortcut-switch-to-tab-2 = ["<Control>2"];
      shortcut-switch-to-tab-3 = ["<Control>3"];
      shortcut-switch-to-tab-4 = ["<Control>4"];
      shortcut-switch-to-tab-5 = ["<Control>5"];
      shortcut-switch-to-tab-6 = ["<Control>6"];
      shortcut-toggle-maximize = ["F1"];
      shortcut-win-new-tab = ["<Shift><Control>t"];
      shortcuts-enabled = true;
      show-animation = "linear";
      show-animation-duration = 0.1;
      tab-close-buttons = true;
      tab-expand = true;
      tab-policy = "automatic";
      tab-position = "bottom";
      tab-switcher-popup = false;
      theme-variant = "dark";
      transparent-background = false;
      use-system-font = false;
      use-theme-colors = true;
      window-above = true;
      window-maximize = true;
      window-monitor = "primary";
      window-position = "top";
      window-size = 1.0;
      window-stick = true;
    };
  };
}

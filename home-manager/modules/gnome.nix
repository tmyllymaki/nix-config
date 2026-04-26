{
  pkgs,
  config,
  lib,
  vars,
  ...
}: {
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      disabled-extensions = [];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-show-weekday = true;
      clock-show-date = true;
      enable-hot-corners = false;
    };

    "org/gnome/desktop/datetime" = {automatic-timezone = true;};

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

    "org/gnome/settings-daemon/plugins/media-keys" = {
      area-screenshot-clip = ["<Shift><Alt>s"];
      rotate-video-lock-static = [];
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

    "org/gnome/shell/extensions/dash-to-dock" = {
      background-opacity = 0.80000000000000004;
      click-action = "minimize";
      dash-max-icon-size = 48;
      dock-fixed = false;
      dock-position = "BOTTOM";
      extend-height = false;
      height-fraction = 0.90000000000000002;
      hot-keys = false;
      isolate-locations = false;
      isolate-monitors = false;
      isolate-workspaces = false;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "primary";
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
    "org/gnome/shell/app-switcher" = {
      current-workspace-only = false;
    };
    "org/gnome/desktop/input-sources" = {
      xkb-options = "['caps:escape_shifted_capslock']";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
      ];
      enabled-extensions = [
        "trayIconsReloaded@selfmade.pl"
        "search-light@icedman.github.com"
        "dash-to-dock@micxgx.gmail.com"
        "no-overview@fthx"
        "gTile@vibou"
        "ddterm@amezin.github.com"
      ];
    };
    "org/gnome/shell/extensions/search-light" = {
      shortcut-search = ["<Super>d"];
    };
    "org/gnome/shell/extensions/dash-to-dock" = {
      intellihide-mode = "ALL_WINDOWS";
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      send-events = "enabled";
    };

    "com/github/amezin/ddterm" = {
      audible-bell = false;
      background-color = "rgb(23,20,33)";
      bold-color = "#000000";
      bold-color-same-as-fg = true;
      bold-is-bright = false;
      cursor-background-color = "#000000";
      cursor-colors-set = false;
      cursor-foreground-color = "rgb(154,153,150)";
      custom-font = "JetBrainsMono Nerd Font 12";
      ddterm-toggle-hotkey = ["F11"];
      foreground-color = "rgb(208,207,204)";
      hide-animation-duration = 0.1;
      hide-when-focus-lost = false;
      highlight-background-color = "#000000";
      highlight-colors-set = false;
      highlight-foreground-color = "rgb(154,153,150)";
      new-tab-button = false;
      notebook-border = false;
      override-window-animation = true;
      palette = ["rgb(23,20,33)" "rgb(192,28,40)" "rgb(38,162,105)" "rgb(162,115,76)" "rgb(63,149,255)" "rgb(163,71,186)" "rgb(42,161,179)" "rgb(208,207,204)" "rgb(94,92,100)" "rgb(246,97,81)" "rgb(51,209,122)" "rgb(233,173,12)" "rgb(42,123,222)" "rgb(192,97,203)" "rgb(51,199,222)" "rgb(255,255,255)"];
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

  gtk = {
    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk3 = {extraConfig = {gtk-application-prefer-dark-theme = 1;};};
    gtk4 = {extraConfig = {gtk-application-prefer-dark-theme = 1;};};
  };

  xdg.configFile."autostart/1password.desktop".text = ''
    [Desktop Entry]
    Name=1Password
    Exec=1password --silent
    Terminal=false
    Type=Application
    Icon=1password
    StartupWMClass=1Password
    Comment=Password manager and secure wallet
    MimeType=x-scheme-handler/onepassword;
    Categories=Office;
  '';
}

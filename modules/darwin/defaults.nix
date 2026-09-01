{
  flake.darwinModules.defaults = {
    config,
    lib,
    ...
  }: {
    options.custom.system.defaults.enable = lib.mkEnableOption "system.defaults";

    config = lib.mkIf config.custom.system.defaults.enable {
      # This wipes existing mappings like Raycast hyper key
      system.keyboard.enableKeyMapping = false;

      system.defaults.trackpad.Dragging = true;

      system.defaults.CustomUserPreferences = {
        "com.apple.finder" = {
          AppleShowAllFiles = true;
          AppleShowAllExtensions = true;
          ShowStatusBar = true;
          ShowPathbar = true;
          QuitMenuItem = true;
          ShowSidebar = true;
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = false;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          FXPreferredViewStyle = "Nlsv";
          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          DisableAllAnimations = true;
          NewWindowTarget = "PfLo";
          NewWindowTargetPath = "~/";
          WarnOnEmptyTrash = false;
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DontWriteUSBStores = true;
        };
        "com.apple.dock" = {
          autohide = true;
          autohide-delay = 0;
          autohide-time-modifier = 0;
          orientation = "bottom";
          tilesize = 36;
          show-recents = false;
          show-process-indicators = true;
        };
        "com.apple.activitymonitor" = {
          OpenInMainWindow = true;
          IconType = 5;
          SortColumn = "CPUUsage";
          SortDirection = 0;
        };
        "com.apple.safari" = {
          UniversalSearchEnabled = false;
          SuppressSearchSuggestions = true;
          ShowFullURLInSmartSearchField = true;
        };
        "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          ScheduleFrequency = 1;
          AutomaticDownload = true;
          CriticalUpdateInstall = true;
        };
      };
    };
  };
}

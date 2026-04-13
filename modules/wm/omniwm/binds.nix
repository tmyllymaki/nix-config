{
  flake.hjemModules.omniwm =
    { config, lib, ... }:
    {
      config = lib.mkIf config.custom.home.omniwm.enable {
        xdg.config.files."omniwm/settings.json".value = {
          hotkeysEnabled = true;

          hotkeyBindings = [
            # Workspace switching
            {
              binding = "Command+1";
              id = "switchWorkspace.0";
            }
            {
              binding = "Command+Shift+1";
              id = "moveToWorkspace.0";
            }
            {
              binding = "Command+2";
              id = "switchWorkspace.1";
            }
            {
              binding = "Command+Shift+2";
              id = "moveToWorkspace.1";
            }
            {
              binding = "Command+3";
              id = "switchWorkspace.2";
            }
            {
              binding = "Command+Shift+3";
              id = "moveToWorkspace.2";
            }
            {
              binding = "Command+4";
              id = "switchWorkspace.3";
            }
            {
              binding = "Command+Shift+4";
              id = "moveToWorkspace.3";
            }
            {
              binding = "Command+5";
              id = "switchWorkspace.4";
            }
            {
              binding = "Command+Shift+5";
              id = "moveToWorkspace.4";
            }
            {
              binding = "Command+6";
              id = "switchWorkspace.5";
            }
            {
              binding = "Command+Shift+6";
              id = "moveToWorkspace.5";
            }
            {
              binding = "Command+7";
              id = "switchWorkspace.6";
            }
            {
              binding = "Command+Shift+7";
              id = "moveToWorkspace.6";
            }
            {
              binding = "Command+8";
              id = "switchWorkspace.7";
            }
            {
              binding = "Command+Shift+8";
              id = "moveToWorkspace.7";
            }
            {
              binding = "Command+9";
              id = "switchWorkspace.8";
            }
            {
              binding = "Command+Shift+9";
              id = "moveToWorkspace.8";
            }
            {
              binding = "Unassigned";
              id = "workspaceBackAndForth";
            }

            # Focus
            {
              binding = "Command+H";
              id = "focus.left";
            }
            {
              binding = "Command+J";
              id = "focus.down";
            }
            {
              binding = "Command+K";
              id = "focus.up";
            }
            {
              binding = "Command+L";
              id = "focus.right";
            }
            {
              binding = "Unassigned";
              id = "focusPrevious";
            }

            # Window state
            {
              binding = "Command+Shift+F";
              id = "toggleFullscreen";
            }
            {
              binding = "Unassigned";
              id = "toggleNativeFullscreen";
            }

            # Move window
            {
              binding = "Command+Shift+J";
              id = "move.down";
            }
            {
              binding = "Command+Shift+K";
              id = "move.up";
            }

            # Column management
            {
              binding = "Command+Shift+H";
              id = "moveColumn.left";
            }
            {
              binding = "Command+Shift+L";
              id = "moveColumn.right";
            }
            {
              binding = "Option+I";
              id = "focusColumnFirst";
            }
            {
              binding = "Option+A";
              id = "focusColumnLast";
            }

            {
              binding = "Option+.";
              id = "cycleColumnWidthForward";
            }
            {
              binding = "Option+,";
              id = "cycleColumnWidthBackward";
            }
            {
              binding = "Option+Shift+F";
              id = "toggleColumnFullWidth";
            }
            {
              binding = "Option+Shift+B";
              id = "balanceSizes";
            }

            # Resize
            {
              binding = "Option+-";
              id = "resizeGrow.left";
            }
            {
              binding = "Option+=";
              id = "resizeGrow.right";
            }
            {
              binding = "Option+Shift+-";
              id = "resizeGrow.up";
            }
            {
              binding = "Option+Shift+=";
              id = "resizeGrow.down";
            }

            # UI / misc
            {
              binding = "Control+Option+Space";
              id = "openCommandPalette";
            }
            {
              binding = "Unassigned";
              id = "toggleWorkspaceLayout";
            }
          ];
        };
      };
    };
}

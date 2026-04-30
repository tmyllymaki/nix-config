{
  flake.hjemModules.wezterm = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs.stdenv) isLinux;
  in {
    options.custom.home.wezterm.enable = lib.mkEnableOption "home.wezterm";

    config = lib.mkIf config.custom.home.wezterm.enable {
      packages = [pkgs.wezterm];

      environment.sessionVariables.TERM = "wezterm";

      xdg.config.files."wezterm/wezterm.lua".text = ''
        local w = require('wezterm')
        local config = w.config_builder()
        local os_name = '${if isLinux then "linux" else "macos"}'

        local function is_vim(pane)
          return pane:get_user_vars().IS_NVIM == 'true'
        end

        local direction_keys = {
          h = 'Left',
          j = 'Down',
          k = 'Up',
          l = 'Right',
        }

        local function split_nav(resize_or_move, key)
          return {
            key = key,
            mods = resize_or_move == 'resize' and 'META' or 'CTRL',
            action = w.action_callback(function(win, pane)
              if is_vim(pane) then
                win:perform_action({
                  SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
                }, pane)
              else
                if resize_or_move == 'resize' then
                  win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
                else
                  win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
                end
              end
            end),
          }
        end

        config.hide_mouse_cursor_when_typing = os_name == 'macos'
        if os_name == 'macos' then
          config.window_decorations = 'RESIZE'
        end

        config.color_scheme = 'onedarkpro'
        config.cursor_blink_rate = 0
        config.font = w.font('FiraCode Nerd Font')
        config.font_size = 12
        config.use_fancy_tab_bar = true
        config.tab_bar_at_bottom = true
        config.hide_tab_bar_if_only_one_tab = true
        config.window_padding = {
          top = 0,
          bottom = 0,
          left = 0,
          right = 0,
        }
        config.debug_key_events = true
        config.inactive_pane_hsb = {
          saturation = 0.7,
          brightness = 0.6,
        }
        config.front_end = 'WebGpu'
        config.webgpu_power_preference = 'HighPerformance'

        config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
        config.keys = {
          {
            key = '\\',
            mods = 'LEADER',
            action = w.action.SplitPane({ direction = 'Right', size = { Percent = 30 } }),
          },
          {
            key = '-',
            mods = 'LEADER',
            action = w.action.SplitPane({ direction = 'Down', size = { Percent = 20 } }),
          },
          split_nav('move', 'h'),
          split_nav('move', 'j'),
          split_nav('move', 'k'),
          split_nav('move', 'l'),
          split_nav('resize', 'h'),
          split_nav('resize', 'j'),
          split_nav('resize', 'k'),
          split_nav('resize', 'l'),
          {
            key = 'n',
            mods = 'META',
            action = w.action.SpawnCommandInNewTab({
              args = { '${pkgs.fish}/bin/fish' },
              cwd = w.home_dir,
            }),
          },
          {
            key = 'LeftArrow',
            mods = 'META',
            action = w.action.ActivateTabRelative(-1),
          },
          {
            key = 'RightArrow',
            mods = 'META',
            action = w.action.ActivateTabRelative(1),
          },
          { key = '-', mods = 'SUPER', action = w.action.DecreaseFontSize },
          { key = '0', mods = 'SUPER', action = w.action.ResetFontSize },
          { key = '=', mods = 'SUPER', action = w.action.IncreaseFontSize },
          { key = 'c', mods = 'SUPER', action = w.action.CopyTo('Clipboard') },
          { key = 'v', mods = 'SUPER', action = w.action.PasteFrom('Clipboard') },
          { key = '[', mods = 'LEADER', action = w.action.ActivateCopyMode },
        }

        return config
      '';
    };
  };
}

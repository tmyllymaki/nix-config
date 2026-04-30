{
  flake.hjemModules.base = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (pkgs.stdenv) isLinux isDarwin;
    shellAliases =
      {
        copy =
          if isDarwin
          then "pbcopy"
          else "xclip -selection clipboard";
        paste =
          if isDarwin
          then "pbpaste"
          else "xclip -o -selection clipboard";
        cat = "bat";
        gogit = "cd ~/git";
        "!!" = "eval \\$history[1]";
        ls = "${pkgs.lsd}/bin/lsd --group-directories-first";
        la = "ls -a";
        ll = "ls -l --git";
        l = "ls -laH";
        lg = "ls -lG";
        nix-apply =
          if isDarwin
          then "home-manager switch --flake ~/git/dotfiles/.#mac"
          else "nh os switch -H desktop";
      }
      // lib.optionalAttrs isLinux {
        restart-gui = "sudo systemctl restart display-manager.service";
      };

    aliasLines = lib.mapAttrsToList (name: value: "alias ${name} '${value}'") shellAliases;

    fishFunctions = {
      "fish/functions/groot.fish".text = ''
        function groot --description "cd to the root of the current git repository"
          set -l git_repo_root_dir (git rev-parse --show-toplevel 2>/dev/null)
          if test -n "$git_repo_root_dir"
            cd "$git_repo_root_dir"
          else
            echo "Not in a git repository."
          end
        end
      '';

      "fish/functions/login.fish".text = ''
        function login --description "Select a 1Password item via fzf and open it in browser"
          set -l selected (op item list --categories login --format json | ${pkgs.jq}/bin/jq -r '.[].title' | fzf --height 40% --layout reverse | xargs op item get --format=json | ${pkgs.jq}/bin/jq -r '.id, .urls[0].href')
          if test -z "$selected"
            commandline -f repaint
            return
          end
          set -l id $selected[1]
          set -l url $selected[2]
          if string match -e -- '\?' "$url"
            set -f fill_session_url "$url&$id=$id"
          else
            set -f fill_session_url "$url?$id=$id"
          end
          ${if isLinux then "xdg-open" else "open"} "$fill_session_url"
        end
      '';

      "fish/functions/nix-clean.fish".text = ''
        function nix-clean
          nix-env --delete-generations old
          nix-store --gc
          nix-channel --update
          nix-env -u --always
          if test -f /etc/NIXOS
            for link in /nix/var/nix/gcroots/auto/*
              rm (readlink "$link")
            end
          end
          nix-collect-garbage -d
        end
      '';

      "fish/functions/nix-shell.fish".text = ''
        function nix-shell
          for ARG in $argv
            if test "$ARG" = --run
              command nix-shell $argv
              return $status
            end
          end
          command nix-shell $argv --run "exec fish"
        end
      '';

      "fish/functions/pr.fish".text = ''
        function pr
          set -l PROJECT_PATH (git config --get remote.origin.url)
          set -l PROJECT_PATH (string replace "git@github.com:" "" "$PROJECT_PATH")
          set -l PROJECT_PATH (string replace "https://github.com/" "" "$PROJECT_PATH")
          set -l PROJECT_PATH (string replace ".git" "" "$PROJECT_PATH")
          set -l GIT_BRANCH (git branch --show-current || echo "")
          set -l MASTER_BRANCH (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

          if test -z "$GIT_BRANCH"
            echo "Error: not a git repository"
          else
            ${if isLinux then "xdg-open" else "open"} "https://github.com/$PROJECT_PATH/compare/$MASTER_BRANCH...$GIT_BRANCH"
          end
        end
      '';

      "fish/functions/fzf-history-widget-wrapped.fish".text = ''
        function fzf-history-widget-wrapped
          fzf-history-widget
          _prompt_move_to_bottom
        end
      '';

      "fish/functions/fzf-file-widget-wrapped.fish".text = ''
        function fzf-file-widget-wrapped
          fzf-file-widget
          _prompt_move_to_bottom
        end
      '';

      "fish/functions/fzf-project-widget.fish".text = ''
        function _project_jump_get_icon
          set -l remote "$(git --work-tree $argv[1] --git-dir $argv[1]/.git ls-remote --get-url 2> /dev/null)"
          if string match -r "github.com" "$remote" >/dev/null
            set_color --bold normal
            echo -n ""
          else if string match -r gitlab "$remote" >/dev/null
            set_color --bold FC6D26
            echo -n ""
          else
            set_color --bold F74E27
            echo -n "󰊢"
          end
        end

        function _project_jump_format_project
          set -l repo "$HOME/work/$argv[1]"
          set -l branch (git --work-tree $repo --git-dir $repo/.git branch --show-current)
          set_color --bold cyan
          echo -n "$argv[1]"
          echo -n " $(_project_jump_get_icon $repo)"
          set_color --bold f74e27
          echo "  $branch"
        end

        function _project_jump_parse_project
          set -f selected $argv[1]
          if test "$selected" = ""
            read -f selected
          end
          if test "$selected" = ""
            return
          end
          set -l dir (string trim "$(string match -r ".*(?=\s*󰊢||)" "$selected")")
          echo "$HOME/work/$dir"
        end

        function _project_jump_get_projects
          for dir in (command ls "$HOME/work")
            if test -d "$HOME/work/$dir"
              echo "$(_project_jump_format_project $dir)"
            end
          end
        end

        function _project_jump_get_readme
          set -l dir (_project_jump_parse_project "$argv[1]")
          if test -f "$dir/README.md"
            ${pkgs.glow}/bin/glow -p -s dark -w 150 "$dir/README.md"
          else
            echo
            echo (set_color --bold) "README.md not found"
            echo
            ${pkgs.lsd}/bin/lsd --icon=always --group-directories-first -F --color=always $dir
          end
        end

        argparse 'format=' -- $argv
        if set -ql _flag_format
          _project_jump_get_readme $_flag_format
        else
          set -l selected (_project_jump_get_projects | fzf --ansi --preview-window 'right,70%' --preview "fzf-project-widget --format {}" --bind "space:execute(echo 'pickfile:{}')+abort")
          set -l proj_dir (string replace -r "^pickfile:" "" "$selected" || true)
          if test -n "$proj_dir"
            cd (_project_jump_parse_project "$proj_dir")
          end
          commandline -f repaint
          if test "$proj_dir" != "" -a "$(string length "$proj_dir")" != "$(string length "$selected")"
            set -l selected_file (fzf --preview-window 'right,70%' --preview "${pkgs.bat}/bin/bat --color=always {}")
            if test -n "$selected_file"
              $EDITOR "$selected_file"
            end
          end
        end
      '';

      "fish/functions/fzf-vim-widget.fish".text = ''
        function fzf-vim-widget
          set -l commandline (__fzf_parse_commandline)
          set -l dir $commandline[1]
          set -l fzf_query $commandline[2]
          set -l prefix $commandline[3]

          test -n "$FZF_CTRL_T_COMMAND"; or set -l FZF_CTRL_T_COMMAND "
          command find -L \$dir -mindepth 1 \\( -path \$dir'*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' \\) -prune \
          -o -type f -print \
          -o -type d -print \
          -o -type l -print 2> /dev/null | sed 's@^\./@@'"

          test -n "$FZF_TMUX_HEIGHT"; or set FZF_TMUX_HEIGHT 40%
          begin
            set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS"
            eval "$FZF_CTRL_T_COMMAND | "(__fzfcmd)' -m --query "'$fzf_query'"' | while read -l r; set result $result $r; end
          end
          if test -z "$result"
            _prompt_move_to_bottom
            commandline -f repaint
            return
          end
          set -l filepath_result
          for i in $result
            set filepath_result "$filepath_result$prefix"
            set filepath_result "$filepath_result$(string escape $i)"
            set filepath_result "$filepath_result "
          end
          _prompt_move_to_bottom
          commandline -f repaint
          $EDITOR $result
        end
      '';
    };
  in {
    options.custom.home.base.enable = lib.mkEnableOption "home.base";

    config = lib.mkIf config.custom.home.base.enable {
      packages = with pkgs; [
        atuin
        eza
        fd
        fish
        fzf
        jujutsu
        neovim
        ripgrep
        yazi
        zoxide
        gh
        glow
        lsd
	gcc
	bun
	nodejs
      ] ++ lib.optionals isLinux [xclip];

      environment.sessionVariables = {
        BROWSER = "zen-browser";
        EDITOR = "nvim";
        VISUAL = "nvim";
        DOTNET_CLI_TELEMETRY_OPTOUT = "1";
        CARGO_NET_GIT_FETCH_WITH_CLI = "true";
        GIT_MERGE_AUTOEDIT = "no";
        NEXT_TELEMETRY_DISABLED = "1";
        NPM_CONFIG_PREFIX = "$HOME/.npm-packages";
        NPM_CONFIG_CACHE = "$HOME/.cache/npm";
        PATH = "$HOME/.npm-packages/bin:$PATH";
      };

      files =
        {
          ".npmrc".text = ''
            prefix=''${HOME}/.npm-packages
            cache=''${HOME}/.cache/npm
          '';
          ".ssh/config".text = ''
            Host *
              IdentityAgent ~/.1password/agent.sock
          '';
        }
        // fishFunctions;

      xdg.config.files."fish/config.fish".text = ''
        status is-interactive; and begin
          # TokyoNight Moon theme
          set -l foreground c8d3f5
          set -l selection 2d3f76
          set -l comment 636da6
          set -l red ff757f
          set -l orange ff966c
          set -l yellow ffc777
          set -l green c3e88d
          set -l purple fca7ea
          set -l cyan 86e1fc
          set -l pink c099ff
          set -g fish_color_normal $foreground
          set -g fish_color_command $cyan
          set -g fish_color_keyword $pink
          set -g fish_color_quote $yellow
          set -g fish_color_redirection $foreground
          set -g fish_color_end $orange
          set -g fish_color_option $pink
          set -g fish_color_error $red
          set -g fish_color_param $purple
          set -g fish_color_comment $comment
          set -g fish_color_selection --background=$selection
          set -g fish_color_search_match --background=$selection
          set -g fish_color_operator $green
          set -g fish_color_escape $pink
          set -g fish_color_autosuggestion $comment
          set -g fish_pager_color_progress $comment
          set -g fish_pager_color_prefix $cyan
          set -g fish_pager_color_completion $foreground
          set -g fish_pager_color_description $comment
          set -g fish_pager_color_selected_background --background=$selection

          set -g fish_prompt_pwd_dir_length 20
          ${lib.concatStringsSep "\n  " aliasLines}

          ${pkgs.fzf}/bin/fzf --fish | source

          for mode in insert default normal
            bind -M $mode \ce fzf-vim-widget
            bind -M $mode \a fzf-project-widget
            bind -M $mode \ct fzf-file-widget-wrapped
            bind -M $mode \cR fzf-history-widget-wrapped
          end

          fish_vi_key_bindings
          bind -M insert jk "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

          set -gx OP_PLUGIN_ALIASES_SOURCED 1
          alias gh "op plugin run -- gh"

          ${pkgs.zoxide}/bin/zoxide init fish | source
          ${pkgs.direnv}/bin/direnv hook fish | source
          ${pkgs.atuin}/bin/atuin init fish | source

          if test "$TERM" != dumb
            ${pkgs.starship}/bin/starship init fish | source
          end
        end
      '';
    };
  };
}

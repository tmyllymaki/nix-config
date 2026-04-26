{
  pkgs,
  lib,
  vars,
  ...
}: let
  inherit (pkgs) stdenv;
  inherit (stdenv) isLinux;
  op_sudo_password_script = pkgs.writeScript "opsudo.bash" ''
    #!${pkgs.bash}/bin/bash
    op item get "System Password" --fields password
  '';
  op-shell-plugins = ["gh"];
in {
  home.sessionVariables = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    CARGO_NET_GIT_FETCH_WITH_CLI = "true";
    GIT_MERGE_AUTOEDIT = "no";
    NEXT_TELEMETRY_DISABLED = "1";
    SUDO_ASKPASS = "${op_sudo_password_script}";
    PATH = "$HOME/.npm-packages/bin:$PATH";
  };

  home.packages = with pkgs;
    []
    ++ lib.lists.optionals isLinux [xclip];

  programs.gh.enable = true;

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "foreign-env";
        inherit (pkgs.fishPlugins.foreign-env) src;
      }
    ];

    shellAliases =
      {
        copy = vars.copyCmd;
        paste = vars.pasteCmd;
        cat = "bat";
        gogit = "cd ~/git";
        "!!" = "eval \\$history[1]";
        ls = "${pkgs.lsd}/bin/lsd --group-directories-first";
        la = "ls -a";
        ll = "ls -l --git";
        l = "ls -laH";
        lg = "ls -lG";
        sudo = "sudo -A";
        nix-apply =
          if pkgs.stdenv.isDarwin
          then "home-manager switch --flake ~/git/dotfiles/.#mac"
          else "sudo nixos-rebuild switch --flake ~/dotfiles/.#matebook";
      }
      // pkgs.lib.optionalAttrs isLinux {
        restart-gui = "sudo systemctl restart display-manager.service";
      };

    shellInit = ''
      set -g fish_prompt_pwd_dir_length 20

      # Source nix files, required to set fish as default shell, otherwise
      # it doesn't have the nix env vars
      if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]
        fenv source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
      end
    '';

    interactiveShellInit = ''
      fish_vi_key_bindings
      bind -M insert jk "if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char force-repaint; end"

      export OP_PLUGIN_ALIASES_SOURCED=1
      ${lib.concatMapStrings
        (plugin: ''alias ${plugin}="op plugin run -- ${plugin}"'')
        op-shell-plugins}
    '';

    functions = {
      nix-clean = ''
        nix-env --delete-generations old
        nix-store --gc
        nix-channel --update
        nix-env -u --always
        if test -f /etc/NIXOS
            for link in /nix/var/nix/gcroots/auto/*
                rm $(readlink "$link")
            end
        end
        nix-collect-garbage -d
      '';
      groot = {
        description = "cd to the root of the current git repository";
        body = ''
          set -l git_repo_root_dir (git rev-parse --show-toplevel 2>/dev/null)
          if test -n "$git_repo_root_dir"
            cd "$git_repo_root_dir"
          else
            echo "Not in a git repository."
          end
        '';
      };
      nix-shell = {
        wraps = "nix-shell";
        body = ''
          for ARG in $argv
            if [ "$ARG" = --run ]
              command nix-shell $argv
              return $status
            end
          end
          command nix-shell $argv --run "exec fish"
        '';
      };
      pr = ''
        set -l PROJECT_PATH (git config --get remote.origin.url)
        set -l PROJECT_PATH (string replace "git@github.com:" "" "$PROJECT_PATH")
        set -l PROJECT_PATH (string replace "https://github.com/" "" "$PROJECT_PATH")
        set -l PROJECT_PATH (string replace ".git" "" "$PROJECT_PATH")
        set -l GIT_BRANCH (git branch --show-current || echo "")
        set -l MASTER_BRANCH (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

        if test -z "$GIT_BRANCH"
          echo "Error: not a git repository"
        else
          ${
          if isLinux
          then "xdg-open"
          else "open"
        } "https://github.com/$PROJECT_PATH/compare/$MASTER_BRANCH...$GIT_BRANCH"
        end
      '';
      login = {
        description = "Select a 1Password item via fzf and open it in browser";
        body = ''
          set -l selected (op item list --categories login --format json | ${pkgs.jq}/bin/jq -r '.[].title' | fzf --height 40% --layout reverse | xargs op item get --format=json | ${pkgs.jq}/bin/jq -r '.id, .urls[0].href')
          if [ -z "$selected" ]
            commandline -f repaint
            return
          end
          set -l id $selected[1]
          set -l url $selected[2]
          # if it has a ? then append query string with &
          if string match -e -- '\?' "$url"
            set -f fill_session_url "$url&$id=$id"
          else
            # otherwise append query string with ?
            set -f fill_session_url "$url?$id=$id"
          end
          ${
            if isLinux
            then "xdg-open"
            else "open"
          } "$fill_session_url"
        '';
      };
    };
  };
}

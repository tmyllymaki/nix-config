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
        glow -p -s dark -w 150 "$dir/README.md"
    else
        echo
        echo (set_color --bold) "README.md not found"
        echo
        lsd --icon=always --group-directories-first -F --color=always $dir
    end
end

function fzf-project-widget
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
            set -l selected_file (fzf --preview-window 'right,70%' --preview "bat --color=always {}")
            if test -n "$selected_file"
                $EDITOR "$selected_file"
            end
        end
    end
end

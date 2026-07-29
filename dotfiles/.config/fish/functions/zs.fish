function zs --description "zmx session picker for projects"
    if test (count $argv) -eq 1
        zmx attach $argv[1]
        return
    end

    set -l output (
        begin
            zmx list --short 2>/dev/null | string replace -r '^(.+)$' '● $1  (active)'
            ls -d ~/projects/git/*/ 2>/dev/null | xargs -n1 basename | string replace -r '^(.+)$' '○ $1'
        end | fzf \
            --print-query \
            --expect=ctrl-n \
            --prompt="zmx> " \
            --header="Enter: attach | Ctrl-N: new session from query"
    )
    or return 1

    set -l query $output[1]
    set -l key $output[2]
    set -l selected $output[3]

    set -l session_name

    if test "$key" = ctrl-n -a -n "$query"
        set session_name $query
    else if test -n "$selected"
        set session_name (string match -r '(?:●|○)\s+(\S+)' -- $selected)[2]
    else if test -n "$query"
        set session_name $query
    else
        return 130
    end

    # If it matches a project dir, cd there first
    set -l project_dir ~/projects/git/$session_name
    if test -d "$project_dir"
        cd $project_dir
    end

    zmx attach $session_name
end

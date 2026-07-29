# Git worktree helper with auto-cd support
# Wraps the tree-me script and automatically cd's to new worktrees
function tree-me --wraps='command tree-me' --description 'Git worktree helper with auto-cd'
    set -l output (command tree-me $argv 2>&1)
    set -l exit_code $status

    # Print output, filtering out the TREE_ME_CD line
    for line in $output
        if not string match -q "TREE_ME_CD:*" -- $line
            echo $line
        end
    end

    # If successful, check for cd path
    if test $exit_code -eq 0
        set -l cd_path (string match -r "TREE_ME_CD:(.*)" -- $output | tail -1)
        if test -n "$cd_path"
            # Extract just the path (second element after the match)
            set -l path (string replace "TREE_ME_CD:" "" -- $cd_path)
            if test -n "$path" -a -d "$path"
                cd "$path"
            end
        end
    end

    return $exit_code
end

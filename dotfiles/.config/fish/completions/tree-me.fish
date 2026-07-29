# Completions for tree-me git worktree helper

# Disable file completions
complete -c tree-me -f

# Subcommands
complete -c tree-me -n "__fish_use_subcommand" -a checkout -d "Checkout existing branch in new worktree"
complete -c tree-me -n "__fish_use_subcommand" -a co -d "Checkout existing branch in new worktree"
complete -c tree-me -n "__fish_use_subcommand" -a create -d "Create new branch in worktree"
complete -c tree-me -n "__fish_use_subcommand" -a pr -d "Checkout GitHub PR in worktree"
complete -c tree-me -n "__fish_use_subcommand" -a cd -d "Fuzzy-select a worktree to cd into"
complete -c tree-me -n "__fish_use_subcommand" -a list -d "List all worktrees"
complete -c tree-me -n "__fish_use_subcommand" -a ls -d "List all worktrees"
complete -c tree-me -n "__fish_use_subcommand" -a remove -d "Remove a worktree"
complete -c tree-me -n "__fish_use_subcommand" -a rm -d "Remove a worktree"
complete -c tree-me -n "__fish_use_subcommand" -a prune -d "Remove worktree administrative files"
complete -c tree-me -n "__fish_use_subcommand" -a help -d "Show help"

# Helper function to get worktree branches
function __fish_tree_me_worktree_branches
    git worktree list 2>/dev/null | string match -r '\[([^\]]+)\]' -g
end

# Helper function to get all git branches
function __fish_tree_me_all_branches
    git branch -a 2>/dev/null | string replace -r '^\*?\s*(remotes/origin/)?' '' | string trim | sort -u
end

# Branch completions for checkout/co (existing branches)
complete -c tree-me -n "__fish_seen_subcommand_from checkout co" -a "(__fish_tree_me_all_branches)" -d "Branch"

# Branch completions for remove/rm (worktree branches only)
complete -c tree-me -n "__fish_seen_subcommand_from remove rm" -a "(__fish_tree_me_worktree_branches)" -d "Worktree branch"

# Base branch completion for create (second argument)
complete -c tree-me -n "__fish_seen_subcommand_from create; and test (count (commandline -opc)) -ge 3" -a "(__fish_tree_me_all_branches)" -d "Base branch"

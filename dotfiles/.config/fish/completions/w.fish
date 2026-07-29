# Completions for w (alias for tree-me git worktree helper)

# Disable file completions
complete -c w -f

# Subcommands
complete -c w -n "__fish_use_subcommand" -a checkout -d "Checkout existing branch in new worktree"
complete -c w -n "__fish_use_subcommand" -a co -d "Checkout existing branch in new worktree"
complete -c w -n "__fish_use_subcommand" -a create -d "Create new branch in worktree"
complete -c w -n "__fish_use_subcommand" -a pr -d "Checkout GitHub PR in worktree"
complete -c w -n "__fish_use_subcommand" -a cd -d "Fuzzy-select a worktree to cd into"
complete -c w -n "__fish_use_subcommand" -a list -d "List all worktrees"
complete -c w -n "__fish_use_subcommand" -a ls -d "List all worktrees"
complete -c w -n "__fish_use_subcommand" -a remove -d "Remove a worktree"
complete -c w -n "__fish_use_subcommand" -a rm -d "Remove a worktree"
complete -c w -n "__fish_use_subcommand" -a prune -d "Remove worktree administrative files"
complete -c w -n "__fish_use_subcommand" -a help -d "Show help"

# Branch completions for checkout/co (existing branches)
complete -c w -n "__fish_seen_subcommand_from checkout co" -a "(__fish_tree_me_all_branches)" -d "Branch"

# Branch completions for remove/rm (worktree branches only)
complete -c w -n "__fish_seen_subcommand_from remove rm" -a "(__fish_tree_me_worktree_branches)" -d "Worktree branch"

# Base branch completion for create (second argument)
complete -c w -n "__fish_seen_subcommand_from create; and test (count (commandline -opc)) -ge 3" -a "(__fish_tree_me_all_branches)" -d "Base branch"

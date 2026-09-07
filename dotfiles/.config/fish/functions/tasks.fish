function tasks --description "Show open tasks from Obsidian Tasks.md"
    grep -n '\- \[ \]' $OBSIDIAN_VAULT/Tasks.md
end

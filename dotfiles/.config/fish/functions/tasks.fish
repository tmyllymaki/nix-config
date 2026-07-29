function tasks --description "Show open tasks from Obsidian Tasks.md"
    grep -n '\- \[ \]' ~/projects/Obsidian/Work/Tasks.md
end
